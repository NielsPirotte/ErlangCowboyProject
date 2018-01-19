-module(log_handler).
-behaviour(cowboy_handler).

-export([init/2]).
%-export([handle/2]).
-export([terminate/3]).

%init(_, Req, _Opts) ->
%	{ok, Req, #state{}}.

init(Req0, State) ->
	%Testing
  	List = toplevel:getLogs(),
	{ok, Body} = logs_dtl:render([{"list", List}]),
	Req = cowboy_req:reply(200,
        #{<<"content-type">> => <<"text/html">>},
        %<<"Hello Erlang!">>,
	Body,
        Req0),
	%Test = cowboy_req:binding(test, Req),
	%io:fwrite("De ingeladen parameter is ~s~n", [Test]),
    	{ok, Req, State}.

terminate(_Reason, _Req, _State) -> ok.
