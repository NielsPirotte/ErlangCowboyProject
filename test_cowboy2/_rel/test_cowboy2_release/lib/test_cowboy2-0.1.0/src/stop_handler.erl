-module(stop_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).

init(Req0, State) ->
	interface:toggle_stop(),
	io:format("toggling stop~n", []),
  	Req = cowboy_req:reply(303,
		 	#{<<"location">> => <<"./logs">>},
			Req0),
	{ok, Req, State}.
	
terminate(_Reason, _Req, _State) -> ok.
