{ lib, ... }:
lib.mapAttrsToList
  (name: opts: {
    alert = name;
    expr = opts.condition;
    for = opts.time or "2m";
    labels = opts.labels or {};
    annotations.description = opts.description;
    annotations.summary = opts.summary;
  })
  ({
  })
