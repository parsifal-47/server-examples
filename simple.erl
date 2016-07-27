#!/usr/bin/env escript
-mode(compile).

-export([service/1]).

-define(Options, [
    binary,
    {backlog, 128},
    {active, false},
    {buffer, 65536},
    {keepalive, true},
    {reuseaddr, true}
]).

-define(Timeout, 5000).

main([Port]) ->
    {ok, ListenSocket} = gen_tcp:listen(list_to_integer(Port), ?Options),
    accept(ListenSocket).

accept(ListenSocket) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} -> erlang:spawn(?MODULE, service, [Socket]), accept(ListenSocket);
        {error, closed} -> ok
    end.

service(Socket) ->
    case gen_tcp:recv(Socket, 0, ?Timeout) of
        {ok, _Binary} -> gen_tcp:send(Socket, <<"ok">>), service(Socket);
        _ -> gen_tcp:close(Socket)
    end.