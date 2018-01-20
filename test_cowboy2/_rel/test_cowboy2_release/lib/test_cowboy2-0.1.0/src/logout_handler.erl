-module(logout_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).


init(Req0, State) ->
	%Login
  	interface:setPersoon(undefined),
  	Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State}.

terminate(_Reason, _Req, _State) -> ok.
