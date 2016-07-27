[
 {make_install, [{git, "git@github.aws.rtapi.net:cb/server-examples.git"},
                 {branch, "master"},
                 {dir, "tcp_worker"}]},
 {pool, [{size, {var, "workers", 25000}},
         {worker_type, tcp_worker},
         {worker_start, {linear, {500, rps}}}],
  [
   {connect_sync, "service-host", 4444},
   {loop, [{rate, {ramp, linear, {1, rps}, {{var, "max", 10}, rps}}},
           {time, {{numvar, "time", 20}, min}}],
    [
        {request_sync}
    ]}
  ]}
].
