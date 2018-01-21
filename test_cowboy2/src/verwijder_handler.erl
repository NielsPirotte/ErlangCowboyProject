-module(verwijder_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).

init(Req0, State) ->
	%Haal index op van request
	#{index := Index} = cowboy_req:match_qs([{index, int}], Req0),
        %Verwijder index uit lijst
        interface:remove(Index),	
	%Ga naar home
    	Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State}.

terminate(_Reason, _Req, _State) -> ok.
