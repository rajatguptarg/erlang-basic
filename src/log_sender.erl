%%%-------------------------------------------------------------------
%%% @author rajat
%%% @copyright (C) 2018
%%% @doc
%%%
%%% @end
%%% Created : 20. Dec 2018 23:24
%%%-------------------------------------------------------------------
-module(log_sender).
-author("rajat").

-behavior(gen_server).

-record(cat, {name, color=green, description}).

%% API
-export([start_link/0]).
-export([init/1, handle_call/3, handle_cast/2]).

-export([order_cat/4, return_cat/2, close_shop/1, code_change/3, handle_info/2, terminate/2]).


start_link() -> gen_server:start_link(?MODULE, [], []).

%%% Server functions
init([]) -> {ok, []}. %% no treatment of info here!

handle_call({order, Name, Color, Description}, _From, Cats) ->
    if Cats =:= [] ->
        {reply, make_cat(Name, Color, Description), Cats};
        Cats =/= [] ->
            {reply, hd(Cats), tl(Cats)}
    end;
handle_call(terminate, _From, Cats) ->
    {stop, normal, ok, Cats}.

handle_cast({return, Cat = #cat{}}, Cats) ->
    {noreply, [Cat|Cats]}.

%% Synchronous call
order_cat(Pid, Name, Color, Description) ->
    gen_server:call(Pid, {order, Name, Color, Description}).

%% This call is asynchronous
return_cat(Pid, Cat = #cat{}) ->
    gen_server:cast(Pid, {return, Cat}).

%% Synchronous call
close_shop(Pid) ->
    gen_server:call(Pid, terminate).

handle_info(Msg, Cats) ->
    io:format("Unexpected message: ~p~n",[Msg]),
    {noreply, Cats}.

terminate(normal, Cats) ->
    [io:format("~p was set free.~n",[C#cat.name]) || C <- Cats],
    ok.

code_change(_OldVsn, State, _Extra) ->
    %% No change planned. The function is there for the behaviour,
    %% but will not be used. Only a version on the next
    {ok, State}.

%%% Private functions
make_cat(Name, Col, Desc) ->
    #cat{name=Name, color=Col, description=Desc}.
