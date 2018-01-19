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
  	interface:setPersoon(PID),
  	request_handler:init(Req0, State).

terminate(_Reason, _Req, _State) -> ok.
