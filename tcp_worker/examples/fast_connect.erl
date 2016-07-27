[
 {make_install, [{git, "git@github.aws.rtapi.net:cb/server-examples.git"},
                 {branch, "master"},
                 {dir, "tcp_worker"}]},
 {pool, [{size, {var, "workers", 20000000}},
         {worker_type, tcp_worker},
         {worker_start, {pow, 2, 200, {3, sec}}}],
  [
   {connect, "service-host", 4444},
   {request},
   {wait_finish}
  ]}
].