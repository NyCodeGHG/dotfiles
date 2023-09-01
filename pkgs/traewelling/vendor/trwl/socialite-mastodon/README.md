# Socialite for Mastodon

https://github.com/tootsuite/mastodon

## Install
```
composer require revolution/socialite-mastodon
```

### config/services.php

```
    'mastodon' => [
        'domain'        => env('MASTODON_DOMAIN'),
        'client_id'     => env('MASTODON_ID'),
        'client_secret' => env('MASTODON_SECRET'),
        'redirect'      => env('MASTODON_REDIRECT'),
        //'read', 'write', 'follow'
        'scope'         => ['read'],
    ],
```

### .env
```
MASTODON_DOMAIN=https://mastodon.social
MASTODON_ID=
MASTODON_SECRET=
MASTODON_REDIRECT=https://example.com/callback

```

## Create App and get the client_id & client_secret

1. Go to your Mastodon's user preferences page.
2. Go to development page.
3. Create new application.
4. Get `Client key` and `Client secret`

## Usage

### Use one instance
routes/web.php
```
Route::get('/', 'MastodonController@index');
Route::get('callback', 'MastodonController@callback');
```

MastodonController

```php
namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Socialite;

class MastodonController extends Controller
{
    public function index()
    {
        return Socialite::driver('mastodon')->redirect();
    }

    public function callback()
    {
        $user = Socialite::driver('mastodon')->user();
        dd($user);
    }
}

```

Set scopes
```php
return Socialite::driver('mastodon')
           ->setScopes(config('services.mastodon.scope', ['read']))
           ->redirect();
```

### Customize domain example

Mastodon API for Laravel
https://github.com/kawax/laravel-mastodon-api

```php
    public function login(Request $request)
    {
        //input domain by user
        $domain = $request->input('domain');

        //get app info. domain, client_id, client_secret ...
        //Server is Eloquent Model
        $server = Server::where('domain', $domain)->first();

        if (empty($server)) {
            //create new app
            $info = Mastodon::domain($domain)->createApp('my-app', 'https://example.com/callback', 'read');

            //save app info
            $server = Server::create([
                'domain'        => $domain,
                'client_id'     => $info['client_id'],
                'client_secret' => $info['client_secret'],
            ]);
        }

        //change config
        config(['services.mastodon.domain' => $domain]);
        config(['services.mastodon.client_id' => $server->client_id]);
        config(['services.mastodon.client_secret' => $server->client_secret]);

        session(['mastodon_domain' => $domain]);
        session(['mastodon_server' => $server]);

        return Socialite::driver('mastodon')->redirect();
    }
    
    public function callback()
    {
        $domain = session('mastodon_domain');
        $server = session('mastodon_server');
    
        config(['services.mastodon.domain' => $domain]);
        config(['services.mastodon.client_id' => $server->client_id]);
        config(['services.mastodon.client_secret' => $server->client_secret]);
    
        $user = Socialite::driver('mastodon')->user();
        dd($user);
    }
```


## LICENCE
MIT
