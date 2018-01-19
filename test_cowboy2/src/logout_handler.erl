-module(logout_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).


init(Req0, State) ->
	%Login
  	interface:setPersoon(undefined),
  	request_handler:init(Req0, State).

terminate(_Reason, _Req, _State) -> ok.
