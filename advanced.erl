#!/usr/bin/env escript
-mode(compile).

-export([reader/0]).

-define(Options, [
    binary,
    {backlog, 128},
    {active, false},
    {buffer, 65536},
    {keepalive, true},
    {reuseaddr, true}
]).

-define(SmallTimeout, 50).
-define(Readers, 200).

main([Port]) ->
    {ok, ListenSocket} = gen_tcp:listen(list_to_integer(Port), ?Options),
    Readers = [erlang:spawn(?MODULE, reader, []) || _X <- lists:seq(1, ?Readers)],
    accept(ListenSocket, Readers, []).

accept(ListenSocket, [], Reversed) -> accept(ListenSocket, lists:reverse(Reversed), []);
accept(ListenSocket, [Reader | Rest], Reversed) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} -> Reader ! Socket, accept(ListenSocket, Rest, [Reader | Reversed]);
        {error, closed} -> ok
    end.

reader() -> reader([]).

read_socket(S) ->
    case gen_tcp:recv(S, 0, 0) of
        {ok, _Binary} -> gen_tcp:send(S, <<"ok">>), true;
        {error, timeout} -> true;
        _ -> gen_tcp:close(S), false
    end.

reader(Sockets) ->
    Sockets2 = lists:filter(fun read_socket/1, Sockets),
    receive
        S -> reader([S | Sockets2])
    after ?SmallTimeout -> reader(Sockets)
    end.
