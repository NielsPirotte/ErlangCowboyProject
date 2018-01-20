-module(verwijder_handler).
-behaviour(cowboy_handler).

-export([init/2]).
%-export([handle/2]).
-export([terminate/3]).

%init(_, Req, _Opts) ->
%	{ok, Req, #state{}}.

init(Req0, State) ->
	#{index := Index} = cowboy_req:match_qs([{index, int}], Req0),
        %verwijder index uit lijst
        interface:remove(Index),	
	
    	Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State}.

terminate(_Reason, _Req, _State) -> ok.
