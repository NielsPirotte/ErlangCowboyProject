-module(reserveer_handler).
-behaviour(cowboy_handler).

-export([init/2]).
%-export([handle/2]).
-export([terminate/3]).


%init(_, Req, _Opts) ->
%	{ok, Req, #state{}}.

init(Req0, State) ->
	%Reservatie
	#{van := Van, naar := Naar, duration := Duratie, datum := Datum, tijdstip := Tijdstip, mode := Auto, passagier := Passagier} = 
		cowboy_req:match_qs([van, naar, duration, datum, tijdstip, mode, passagier], Req0),
	
	io:format("Van: ~s~n Naar: ~s~n Duratie: ~s~n Datum: ~s~n Tijdstip: ~s~n mode: ~s~n passagier: ~s~n", [Van, Naar, Duratie, Datum, Tijdstip, Auto, Passagier]),
	
	Tijd = [fixDatum(Datum), <<" - ">>, Tijdstip],
	
	Record = [Tijd, Van, Naar, Auto, Passagier],
	
	Hoelaat = getTimeInfo(Tijdstip),
	{DayOfWeek, Week} = getDateInfo(Datum),
	interface:insert(Record, DayOfWeek, Hoelaat,Hoelaat+1,Van,Naar,toInt(Duratie),toBool(Passagier), Week),
	%Naar home
	Req = cowboy_req:reply(303,
			 	#{<<"location">> => <<"./">>},
				Req0),
		{ok, Req, State}.
	

terminate(_Reason, _Req, _State) ->
	ok.
	
getDateInfo(ParsedDate) ->
	[StrMonth, StrDay, StrYear] = string:split(binary_to_list(ParsedDate),"/", all),
	{Day, _} = string:to_integer(StrDay),
	{Month, _} = string:to_integer(StrMonth),
	{Year, _} = string:to_integer(StrYear),
	Date = {Year, Month, Day},
	{calendar:day_of_the_week(Date), interface:week(Date)}.
	
fixDatum(ParsedDate) -> 
	[StrMonth, StrDay, StrYear] = string:split(binary_to_list(ParsedDate),"/", all),
	[list_to_binary(StrDay), <<"/">>, list_to_binary(StrMonth), <<"/">>, list_to_binary(StrYear)].
	
getTimeInfo(ParsedTime) ->
	[StrUur, _] = string:split(binary_to_list(ParsedTime), ":", all),
	{Uur, _} = string:to_integer(StrUur),
	Uur.
	
toBool(String) when String == "True" -> true;
toBool(_String) -> false.

toInt(StrDuur) -> 
	{Duur,  _} = string:to_integer(binary_to_list(StrDuur)),
	%Omzetting naar geschaalde uren
	trunc(Duur*10/6).
	
