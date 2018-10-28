-module(dice_roller_root).

-export([init/2]).

init(#{method := <<"POST">>} = Req, _Opts) ->
    io:format("Is POST!~n"),
    case cowboy_req:read_body(Req) of
        {ok, Data, Req2} ->
            io:format("Got data!~n"),
            reply_roll(roll:roll(binary_to_list(Data)), Req2);
        _ ->
            io:format("No data!~n"),
            cowboy_req:reply(403, Req)
    end;
init(Req, _Opts) ->
    io:format("Is NOT POST!~n"),
    cowboy_req:reply(403, Req).

reply_roll({ok, X}, Req) ->
    io:format("Format ok!~n"),
    cowboy_req:reply(200, #{
        <<"content-type">> => <<"text/plain">>
    }, integer_to_binary(X), Req);
reply_roll(_, Req) ->
    io:format("Format error!~n"),
    cowboy_req:reply(403, Req).