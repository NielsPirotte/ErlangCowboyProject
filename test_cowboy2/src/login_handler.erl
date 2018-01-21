-module(login_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).

init(Req0, State) ->
	%Haal login id op uit request
	#{persoon := Persoon} = 
		cowboy_req:match_qs([{persoon, [],undefined}], Req0),
	
	%Zet om naar een geldig PID
  	PID = list_to_pid(binary_to_list(Persoon)),
  	
  	case geldig(PID) of
  	true ->
  		interface:setPersoon(PID),
  		Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State};
  	false ->
  		io:format("Persoon niet geldig!~n",[]),
  		Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State}
	end.

terminate(_Reason, _Req, _State) -> ok.

%Check als PID geldig is
geldig(Persoon) when is_pid(Persoon) -> true;
geldig(_) -> false.
