-module(prop_roll).

-include_lib("proper/include/proper.hrl").

non_const() -> ?LET([N,S,M], [integer(2,100), integer(1, 10), integer(1,5)],
    {die, N, S, M}).

const() -> ?LET(C, integer(1,100), {const, C}).

die() -> oneof([const(), non_const()]).

dice() -> ?LET(N, integer(1,10), vector(N, die())).

prop_is_ok() ->
    ?FORALL(Dice, dice(),
        begin
            Spec = roll:to_string(Dice),
            case roll:roll(Spec) of
                {ok, _} -> true;
                _ -> false
            end
        end).

prop_in_range() ->
    ?FORALL(Die, die(),
        begin
            Spec = roll:to_string(Die),
            {ok, Res} = roll:roll(Spec),
            Res >= min_val(Die) andalso Res =< max_val(Die)
        end).

min_val({const, C}) -> C;
min_val({die, _, S, M}) -> S * M.

max_val({const, C}) -> C;
max_val({die, N, S, M}) -> N * S * M.