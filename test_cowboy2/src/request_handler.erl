-module(request_handler).
-behaviour(cowboy_handler).

-export([init/2]).

-export([terminate/3]).


init(Req0, State) ->
	Persoon = interface:getPersoon(),
	
	case (Persoon == undefined) of
		false ->
			io:format("loading page~n", []),
			io:format("loading list:~n", []),
			List = interface:get(),
			io:format("END loading list~n", []),
			Gebruiker = interface:getNaamPersoon(),
			ID = interface:getPersoon(),
			{Tijd, Dag, LogCount} = interface:getTijdEnLog(),
			Week = interface:getHuidigeWeek(),
			ReqProps =
				[
				{<<"tijd">>, Tijd},
				{<<"dag">>, convertDag(Dag)},
				{<<"week">>, Week},
				{<<"logcount">>, LogCount},
				{<<"gebruiker">>, Gebruiker},
				{<<"gebruiker_id">>, ID}
				],
			io:format("interface List ~p~n", [List]), %print out to console
	
			{ok, Body} = index_dtl:render([{"list", List}, {<<"req">>, ReqProps}]),	
			Req = cowboy_req:reply(200,
			 	#{<<"content-type">> => <<"text/html">>},
				Body,
				Req0),
			{ok, Req, State};
		true ->
		 	List = interface:getLoginInfo(),
			io:format("ListInfo: ~p~n", [List]),
			{ok, Body} = login_dtl:render([{"list", List}]),
	
			Req = cowboy_req:reply(200,
				#{<<"content-type">> => <<"text/html">>},
				Body,
				Req0),
			{ok, Req, State}
	end.

terminate(_Reason, _Req, _State) ->
	ok.
	
convertDag(Dag) ->
	case Dag of
		1 -> <<"Maandag">>;
		2 -> <<"Dinsdag">>;
		3 -> <<"Woensdag">>;
		4 -> <<"Donderdag">>;
		5 -> <<"Vrijdag">>;
		6 -> <<"Zaterdag">>;
		7 -> <<"Zondag">>
	end.

%isEmpty([]) -> true;
%isEmpty(_) -> false.
