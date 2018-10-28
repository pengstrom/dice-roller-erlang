-module(roll).

-export([roll/1, to_string/1]).

roll("") -> {error, invalid};
roll(Spec) ->
    Dice = parse(Spec),
    #{valid := Valid, value := Res} = lists:foldl(fun roller/2, #{valid => true, value => 0, rolls => []}, Dice),
    case Valid of
        false -> {error, invalid};
        _ -> {ok, Res}
    end.

to_string(Dice) when is_list(Dice) ->
    Specs = lists:map(fun to_string/1, Dice),
    string:join(Specs, " + ");
to_string({const, C}) -> format("~p", [C]);
to_string({die, N, S, M}) ->
    Nf = "d~p",
    {Sf, Sv} = case S of
        1 -> {"", []};
        _ -> {"~p", [S]}
    end,
    {Mf, Mv} = case M of
        1 -> {"", []};
        _ -> {"x~p", [M]}
    end,
    Format = Sf ++ Nf ++ Mf,
    Values = Sv ++ [N] ++ Mv,
    format(Format, Values).

format(F, V) ->
    lists:flatten(io_lib:format(F, V)).

roller(error, #{rolls := Rolls} = Acc) -> Acc#{valid => false, rolls => [none|Rolls]};
roller(Die, #{rolls := Rolls, value := Value} = Acc) ->
    X = sample(Die),
    Acc#{rolls => [X|Rolls], value => Value + X}.

sample({const, C}) -> C;
sample({die, N, S, M}) ->
    X = lists:sum([rand:uniform(N) || _ <- lists:seq(1,S)]),
    X * M.

parse(Spec) ->
    DiceUntrimmed = string:split(Spec, "+"),
    Dice = lists:map(fun string:trim/1, DiceUntrimmed),
    lists:map(fun parse_die/1, Dice).

parse_die(DieSpec) ->
    case string:split(DieSpec, "d") of
        [Cs] -> case string:to_integer(Cs) of
            {C, _} -> {const, C};
            _ -> error
        end;
        [[], NM] -> case parse_sides_mult(NM) of
            {none, _} -> error;
            {N, M} -> {die, N, 1, M}
        end;
        [Ss, NM] ->
            S = parse_int(Ss),
            case parse_sides_mult(NM) of
                {none, _} -> error;
                {N, M} -> {die, N, S, M}
            end;
        _ -> error
        end.

parse_int(X) ->
    case string:to_integer(X) of
        {error, _} -> none;
        {Y, _} -> Y
    end.
                    
parse_sides_mult(NM) ->
    case string:split(NM, "x") of
        [Ns] ->
            {parse_int(Ns), 1};
        [Ns, Ms] ->
                {parse_int(Ns), parse_int(Ms)};
        _ -> {none, none}
    end.