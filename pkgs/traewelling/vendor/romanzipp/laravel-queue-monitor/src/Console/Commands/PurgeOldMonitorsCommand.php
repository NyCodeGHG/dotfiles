<?php

namespace romanzipp\QueueMonitor\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Facades\DB;
use romanzipp\QueueMonitor\Console\Commands\Concerns\HandlesDateInputs;
use romanzipp\QueueMonitor\Enums\MonitorStatus;
use romanzipp\QueueMonitor\Services\QueueMonitor;

class PurgeOldMonitorsCommand extends Command
{
    use HandlesDateInputs;

    protected $signature = 'queue-monitor:purge {--before=} {--beforeDays=} {--beforeInterval=} {--only-succeeded} {--queue=} {--dry}';

    public function handle(): int
    {
        $beforeDate = self::parseBeforeDate($this);
        if (null === $beforeDate) {
            $this->error('Needs at least --before or --beforeDays arguments');

            return 1;
        }

        $query = QueueMonitor::getModel()
            ->newQuery()
            ->where('started_at', '<', $beforeDate);

        $queues = array_filter(explode(',', $this->option('queue') ?? ''));

        if (count($queues) > 0) {
            $query->whereIn('queue', array_map('trim', $queues));
        }

        if ($this->option('only-succeeded')) {
            $query->where('status', '=', MonitorStatus::SUCCEEDED);
        }

        $count = $query->count();

        $this->info(
            sprintf('Purging %d jobs before %s.', $count, $beforeDate->format('Y-m-d H:i:s'))
        );

        $query->chunk(200, function (Collection $models, int $page) use ($count) {
            $this->info(
                sprintf('Deleted chunk %d / %d', $page, abs($count / 200))
            );

            if ($this->option('dry')) {
                return;
            }

            DB::table(QueueMonitor::getModel()->getTable())
                ->whereIn('id', $models->pluck('id'))
                ->delete();
        });

        return 1;
    }
}
