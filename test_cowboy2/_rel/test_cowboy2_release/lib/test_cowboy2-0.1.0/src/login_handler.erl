-module(login_handler).
-behaviour(cowboy_handler).

-export([init/2]).
%-export([handle/2]).
-export([terminate/3]).

%init(_, Req, _Opts) ->
%	{ok, Req, #state{}}.

init(Req0, State) ->
	%Login
	#{persoon := Persoon} = 
		cowboy_req:match_qs([{persoon, [],undefined}], Req0),
		
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

geldig(Persoon) when is_pid(Persoon) -> true;
geldig(_) -> false.
