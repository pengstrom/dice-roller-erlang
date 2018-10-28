-module(roll_server).

-behaviour(gen_server).

-define(SERVER, ?MODULE).

%% API
-export([stop/0, start_link/0, roll/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-record(state, {count}).

%start(Name) ->
   %_sup:start_child(Name).

stop() ->
   gen_server:stop(?SERVER),
   ok.

start_link() ->
   gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

roll(Spec) ->
    gen_server:call(?SERVER, {roll, Spec}).


%% Callbacks

init(_Args) ->
   {ok, #state{count=1}}.

handle_call(stop, _From, State) ->
   {stop, normal, stopped, State};

handle_call({roll, Spec}, _From, #state{count = Count} = State) ->
    Res = roll:roll(binary_to_list(Spec)),
    {reply, {Res, Count}, State#state{count = Count + 1}};

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(_Msg, State) ->
   {noreply, State}.

handle_info(_Info, State) ->
   {noreply, State}.

terminate(_Reason, _State) ->
   ok.

code_change(_OldVsn, State, _Extra) ->
   {ok, State}.