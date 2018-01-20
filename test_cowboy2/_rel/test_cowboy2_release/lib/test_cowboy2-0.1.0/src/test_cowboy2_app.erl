-module(test_cowboy2_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
	Dispatch = cowboy_router:compile([
		{'_', [
			{"/test/:test", hello_handler, []},
			{"/", request_handler, []},
			{"/reserveer", reserveer_handler, []},
			{"/verwijder", verwijder_handler, []},
			{"/logs", log_handler, []},
			{"/login", login_handler, []},
			{"/logout", logout_handler, []},
			{"/stop", stop_handler, []},
			{"/info", cowboy_static, {priv_file, test_cowboy2, "www/info.html"}}
		]}
	]),
	{ok, _} = cowboy:start_clear(my_http_listener, 
		[{port, 8080}],
		#{env => #{dispatch => Dispatch}}
	),
  	%Start interface
  	interface:start(),
  	
	test_cowboy2_sup:start_link().

stop(_State) ->
	ok.
