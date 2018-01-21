-module(log_handler).
-behaviour(cowboy_handler).

-export([init/2]).
-export([terminate/3]).

init(Req0, State) ->
	%Haal alle Logs op uit interface
  	List = interface:getLogs(),
  	
  	%Render body
	{ok, Body} = logs_dtl:render([{"list", List}]),
	
	%Verstuur antwoord
	Req = cowboy_req:reply(200,
        	#{<<"content-type">> => <<"text/html">>},
		Body,
        	Req0),
    	{ok, Req, State}.

terminate(_Reason, _Req, _State) -> ok.
