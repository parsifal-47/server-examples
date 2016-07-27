#!/usr/bin/env escript
-mode(compile).

-export([responder/0, service/2]).

-define(Options, [
    binary,
    {backlog, 128},
    {active, false},
    {buffer, 65536},
    {keepalive, true},
    {send_timeout, 0},
    {reuseaddr, true}
]).

-define(SmallTimeout, 50).
-define(Timeout, 5000).
-define(Responders, 200).

main([Port]) ->
    {ok, ListenSocket} = gen_tcp:listen(list_to_integer(Port), ?Options),
    Responders = [erlang:spawn(?MODULE, responder, []) || _X <- lists:seq(1, ?Responders)],
    accept(ListenSocket, Responders, []).

accept(ListenSocket, [], Reversed) -> accept(ListenSocket, lists:reverse(Reversed), []);
accept(ListenSocket, [Responder | Rest], Reversed) ->
    case gen_tcp:accept(ListenSocket) of
        {ok, Socket} -> erlang:spawn(?MODULE, service, [Socket, Responder]), accept(ListenSocket, Rest, [Responder | Reversed]);
        {error, closed} -> ok
    end.

responder() ->
    receive
        S -> gen_tcp:send(S, <<"ok">>), responder()
    after ?SmallTimeout -> responder()
    end.

service(Socket, Responder) ->
    case gen_tcp:recv(Socket, 0, ?Timeout) of
        {ok, _Binary} -> Responder ! Socket, service(Socket, Responder);
        _ -> gen_tcp:close(Socket)
    end.
