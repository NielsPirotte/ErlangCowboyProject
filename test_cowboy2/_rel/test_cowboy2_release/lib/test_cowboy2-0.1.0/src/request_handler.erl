-module(request_handler).
-behaviour(cowboy_handler).

-export([init/2]).

-export([terminate/3]).


init(Req0, State) ->
	%Check als iemand is ingelogd
	Persoon = interface:getPersoon(),
	
	case (Persoon == undefined) of
		%Laat homepage
		false ->
			%Haal alle afspraken op van deze persoon
			List = interface:get(),
			%Haal overige informatie op uit interface
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
			
			%Render body
			{ok, Body} = index_dtl:render([{"list", List}, {<<"req">>, ReqProps}]),
			%Verstuur antwoord
			Req = cowboy_req:reply(200,
			 	#{<<"content-type">> => <<"text/html">>},
				Body,
				Req0),
			{ok, Req, State};
		%Laat inlog-pagina
		true ->
			%Haal alle login namen op uit alle families
		 	List = interface:getLoginInfo(),
			io:format("ListInfo: ~p~n", [List]),
			
			%Render body
			{ok, Body} = login_dtl:render([{"list", List}]),
			%Verstuur antwoord
			Req = cowboy_req:reply(200,
				#{<<"content-type">> => <<"text/html">>},
				Body,
				Req0),
			{ok, Req, State}
	end.

terminate(_Reason, _Req, _State) ->
	ok.

%Zet dag(integer) om naar bijhorende bitstring 
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
