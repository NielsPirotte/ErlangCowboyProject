-module(interface).

-export([start/0, init/0, loop/4, get/0, insert/9, remove/1, stop/0, setPersoon/1, getPersoon/0, getNaamPersoon/0, getLoginInfo/0, getTijdEnLog/0, maakAfspraak/7, getHuidigeWeek/0, week/1, toggle_stop/0, getLogs/0]).

start() ->
  Pid = spawn(?MODULE, init, []),
  register(interface, Pid),
  Pid.

init() ->
  AfsprakenTabel = ets:new(afspraken, [duplicate_bag]),
  toplevel:generateData(),
  %Dus momenteel begint de huidige week op 1jan2018
  loop(AfsprakenTabel, 0, undefined, 0).

loop(A, Aantal, Persoon, Week) ->
  receive
    {get, PID} ->
      PID!ets:match(A, {'$2', Persoon, '$1', '_', '_', '_', '_', '_', '_', '_', '_'}),
      loop(A, Aantal, Persoon, Week);
    {insert, Record, DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier, WeekAfspraak} ->
    	HuidigeDag = getDag(),
    	if((WeekAfspraak < Week) or ((WeekAfspraak == Week) and (DayOfWeek<HuidigeDag))) ->
    		%Afspraak niet invoeren
    		io:format("De afspraak datum is al voorbij!~n", []),
    		voorbij;
    	true ->
      		ets:insert(A, {Aantal, Persoon, Record, DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier, WeekAfspraak}),
      		if(WeekAfspraak == Week) -> 
      			%Reserveer
      			interface!{maakAfspraak, DayOfWeek, VertrekU, AankomstU, binary_to_list(Van), binary_to_list(Naar), Duratie, Passagier};
      		true -> continue
      		end
      	end,
        loop(A, Aantal + 1, Persoon, Week);
    {remove, Index} ->
      Check = ets:delete(A, Index),
      if (Check) -> loop(A, Aantal -1, Persoon, Week);
       true -> loop(A, Aantal, Persoon, Week)
      end;
    {setPersoon, NPersoon} ->
    	loop(A, Aantal, NPersoon, Week);
    {getPersoon, PID} ->
    	PID!Persoon,
    	loop(A, Aantal, Persoon, Week);
    {getNaamPersoon, PID} ->
    	if(Persoon == undefined) -> 
    		PID!undefined,
    		loop(A, Aantal, Persoon, Week);
    		true ->
    			Persoon!{getInfo, self()},
    			receive
    				Naam -> 
    					PID!Naam,
    					loop(A, Aantal, Persoon, Week)
		    	after
		    		6000 ->
		    			loop(A, Aantal, Persoon, Week)
		    	end
	end;
    {maakAfspraak, Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier} -> 
    	toplevel:maakAfspraak(Persoon, Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier),
    	loop(A, Aantal, Persoon, Week);
    	%verhoog week bekijk alle afspraken met een bepaalde week en voor deze uit
    {nieuweWeek} -> 
    	Check = ets:match(A, {'_', '_', '_', '$1', '$2', '$3', '$4', '$5', '$6', '$7', Week+1}),
    	io:format("te reserveren: ~p~n", [Check]),
    	reserveerAfspraken(Check),
    	loop(A, Aantal, Persoon, Week+1);
    {getWeek, PID} -> 
    	PID!Week, 
    	loop(A, Aantal, Persoon, Week);
    {stop} -> 
    	{ok, true}
  end.

get() ->
  interface!{get, self()},
  receive
    Result -> format(Result, [])
  end.
  
maakAfspraak(Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier) ->
	interface!{maakAfspraak, Dag,Van,Tot,binary_to_list(Heenlocatie),binary_to_list(Teruglocatie),Duratie,Passagier}.
  
setPersoon(Persoon) ->
	interface!{setPersoon, Persoon}.

getPersoon() ->
	interface!{getPersoon, self()},
	receive
		undefined -> undefined;
		PID -> pid_to_binary(PID)
	end.
	
getNaamPersoon() ->
	interface!{getNaamPersoon, self()},
	receive
		Result -> Result
	end.
	
getLoginInfo() ->
	toplevel:getLoginInfo().

getTijdEnLog() -> 
	toplevel:getTijdEnLog().
	

insert(Record, DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier, WeekAfspraak) ->
	if(WeekAfspraak == voorbij) -> io:format("Afspraakdatum is voorbij! Selecteer nieuwe datum.~n", []);
	true ->
  		interface!{insert, Record, DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier, WeekAfspraak}
  	end.

remove(Index) ->
  interface!{remove, Index}.

stop() ->
  interface!{stop}.

format([], []) -> [];
format([[R, Index]], Out) -> [R++[Index]|Out];
format([[R, Index]|Rs], Out) -> format(Rs, [R++[Index]|Out]).

pid_to_binary(PID)-> list_to_binary(pid_to_list(PID)).

getHuidigeWeek() ->
	interface!{getWeek, self()},
	receive
		Result -> Result
	end.

%Moet opgevraagd worden wanneer een nieuwe afspraak in de interface wordt gemaakt
week(Datum) ->
	RefDatum = {{2018,1,1}, {0,0,0}},
	{Dagen, _} = calendar:time_difference(RefDatum, {Datum, {0,0,0}}),
	io:format("interface week-Dagen: ~p~n", [Dagen]),
	if(Dagen < 0) -> voorbij;
		true ->
			Dagen div 7
	end.

%Reserveert afspraken van een lijst uit de afspraken in de interface
reserveerAfspraken([]) -> 
	io:format("Geen nieuwe afspraken via webinterface~n", []), no_reservation_possible;
reserveerAfspraken([X]) -> 
	[DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier] = X,
	interface:maakAfspraak(DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier);
reserveerAfspraken([X|Xs]) ->
	{DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier} = X,
	interface:maakAfspraak(DayOfWeek, VertrekU, AankomstU, Van, Naar, Duratie, Passagier),
	reserveerAfspraken(Xs);
reserveerAfspraken(_) -> 
	io:format("error input~n", []), no_reservation_possible.

toggle_stop() ->
	toplevel!{toggle_stop}.
	
getDag() ->
	toplevel!{getDag, self()},
	receive
		Result -> Result
	end.
	
getLogs() ->
	toplevel:getLogs().
