-module(interface).

-export([start/0, init/0, loop/3, get/0, insert/1, remove/1, stop/0, setPersoon/1, getPersoon/0, getNaamPersoon/0, getLoginInfo/0, getTijdEnLog/0, maakAfspraak/7]).

start() ->
  Pid = spawn(?MODULE, init, []),
  register(interface, Pid),
  Pid.

init() ->
  AfsprakenTabel = ets:new(afspraken, [duplicate_bag]),
  toplevel:generateData(),
  loop(AfsprakenTabel, 0, undefined).

loop(A, Aantal, Persoon) ->
  receive
    {get, PID} ->
      PID!ets:match(A, {'$2', '$1'}),
      loop(A, Aantal, Persoon);
    {insert, Record} ->
      ets:insert(A, {Aantal, Record}),
      loop(A, Aantal + 1, Persoon);
    {remove, Index} ->
      Check = ets:delete(A, Index),
      if (Check) -> loop(A, Aantal -1, Persoon);
       true -> loop(A, Aantal, Persoon)
      end;
    {setPersoon, NPersoon} ->
    	loop(A, Aantal, NPersoon);
    {getPersoon, PID} -> 
    	PID!Persoon,
    	loop(A, Aantal, Persoon);
    {getNaamPersoon, PID} ->
    	if(Persoon == undefined) -> 
    		PID!undefined,
    		loop(A, Aantal, Persoon);
    		true ->
    			Persoon!{getInfo, self()},
    			receive
    				Naam -> 
    					PID!Naam,
    					loop(A, Aantal, Persoon)
		    	after
		    		6000 ->
		    			loop(A, Aantal, Persoon)
		    	end
	end;
    {maakAfspraak, Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier} -> 
    	toplevel:maakAfspraak(Persoon, Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier);
    {stop} -> {ok, true}
  end.

get() ->
  interface!{get, self()},
  receive
    Result -> format(Result, [])
  end.
  
maakAfspraak(Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier) ->
	interface!{maakAfspraak, Dag,Van,Tot,Heenlocatie,Teruglocatie,Duratie,Passagier}.
  
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

insert(Record) ->
  interface!{insert, Record}.

remove(Index) ->
  interface!{remove, Index}.

stop() ->
  interface!{stop}.

format([], []) -> [];
format([[R, Index]], Out) -> [R++[Index]|Out];
format([[R, Index]|Rs], Out) -> format(Rs, [R++[Index]|Out]).

pid_to_binary(PID)-> list_to_binary(pid_to_list(PID)).


