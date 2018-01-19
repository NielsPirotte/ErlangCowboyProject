%%%-------------------------------------------------------------------
%%% @author laure
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 17. nov 2017 11:59
%%%-------------------------------------------------------------------
-module(toplevel).
-author("laure").



%% API
-export([start/0,init/0, generateData/0,loop/4,getDag/1, getAgenda/0, maakAfspraak/8, verwijderAfspraak/1, getLogs/0,  getLoginInfo/0, getTijdEnLog/0]).
%%overschakelen naar dagen is 24*7 uren doen! intern dan met dit 'groot' getal maar extern deze deling uitvoeren naar dagen !
generateData() ->
  PID = toplevel:start(),
  PIDPa = persoon:start(),
  PIDPa!{setNaam, "papa", PID},
  PIDPa!{setRijbewijs, true, PID},
  PIDMa = persoon:start(),
  PIDMa!{setNaam, "mama", PID},
  PIDMa!{setRijbewijs, true, PID},
  PIDZo = persoon:start(),
  PIDZo!{setNaam, "zoon", PID},
  PIDDo = persoon:start(),
  PIDDo!{setNaam, "dochter", PID},
  PIDA = auto:start(),
  PIDA!{setNaam, "ford", PID},
  PIDA2 = auto:start(),
  PIDA2!{setNaam, "opel", PID},
  PIDFi = fiets:start(),
  PIDFi!{setNaam, "fiets", PID},
  PIDFi2 = fiets:start(),
  PIDFi2!{setNaam, "fiets2", PID},
  PID!{insert,"thuis","werk",1500},
  PID!{insert, "werk", "thuis", 1500},
  PID!{insert,"thuis","school",1000},
  PID!{insert, "school", "thuis", 1000},
  PID!{insert, "thuis", "sportclub", 500},
  PID!{insert, "sportclub", "thuis", 500},
  PID!{insert, "thuis", "dansles",500},
  PID!{insert, "dansles", "thuis", 500},
  PID!{insert, "werk", "afspraak", 500},
  PID!{insert, "afspraak", "werk", 500},
  PID!{insert, "thuis", "vriend", 500},
  PID!{insert, "vriend", "thuis", 500},

  observer:start(),

  PIDFam = familie:start(),
  PIDFam!{insertVader, PIDPa, PID},
  PIDFam!{insertKind , PIDZo , PID},
  PIDFam!{insertMoeder, PIDMa,PID},
  PIDFam!{insertKind, PIDDo,PID},
  PIDFam!{insertAuto, PIDA , PID},
  PIDFam!{insertAuto, PIDA2 , PID},
  PIDFam!{insertFiets, PIDFi , PID},
  PIDFam!{insertFiets, PIDFi2 , PID},
  PIDFam!{insertFnaam, "Janssens", PID},
  PIDFam!{setResources},

  PID!{setFamilie , PIDFam},
  %PIDZo!{getAfspraak,9,PID}.
  PIDTest = persoon:start(),
  PIDTest!{setNaam, "test", PID},
  PIDTest2 = persoon:start(),
  PIDTest2!{setNaam, "test2", PID},
  PIDFam2 = familie:start(),
  %PIDFam2!{insertKind, PIDTest,PID},
  PIDFam2!{insertFnaam,"testFamilie2",PID},
  PID!{setFamilie,PIDFam2},
  PID!{maakAfspraak, PIDMa,1,8, 15, "werk", "thuis", false},
  PID!{maakAfspraak,PIDPa,1,9,17,"werk","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDZo,1,9,16,"school","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDDo,1,9,16,"school","thuis",false},%zit in geen familie
  PID!{maakAfspraak, PIDZo,1,19, 20, "sportclub", "thuis", true},
  PID!{maakAfspraak, PIDDo,1,21, 23, "dansles", "thuis", true},

  PID!{maakAfspraak, PIDMa,2,8, 15, "werk", "thuis", false},
  PID!{maakAfspraak,PIDPa,2,9,17,"werk","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDZo,2,9,16,"school","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDDo,2,9,16,"school","thuis",false},%zit in geen familie
  PID!{maakAfspraak, PIDZo,2,19, 21, "sportclub", "thuis", true},
  PID!{maakAfspraak, PIDDo,2,21, 23, "dansles", "thuis", true},

  PID!{maakAfspraak, PIDMa,3,8, 15, "werk", "thuis", false},
  PID!{maakAfspraak,PIDPa,3,9,17,"werk","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDZo,3,9,12,"school","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDDo,3,9,12,"school","thuis",false},%zit in geen familie
  PID!{maakAfspraak, PIDZo,3,19, 21, "sportclub", "thuis", true},
  PID!{maakAfspraak, PIDDo,3,21, 23, "dansles", "thuis", true},


  PID!{maakAfspraak, PIDMa,4,8, 15, "werk", "thuis", false},
  PID!{maakAfspraak,PIDPa,4,9,17,"werk","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDZo,4,9,16,"school","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDDo,4,9,16,"school","thuis",false},%zit in geen familie
  PID!{maakAfspraak, PIDZo,4,19, 21, "sportclub", "thuis", true},
  PID!{maakAfspraak, PIDDo,4,21, 23, "dansles", "thuis", true},

  PID!{maakAfspraak, PIDMa,5,8, 15, "werk", "thuis", false},
  PID!{maakAfspraak,PIDPa,5,9,17,"werk","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDZo,5,9,16,"school","thuis",false},%zit in familie testFam2
  PID!{maakAfspraak,PIDDo,5,9,16,"school","thuis",false},%zit in geen familie
  PID!{maakAfspraak, PIDZo,5,19, 21, "sportclub", "thuis", true},
  PID!{maakAfspraak, PIDDo,5,21, 23, "dansles", "thuis", true},


  erlang:send_after(500,PID,{maakAfspraak, PIDMa,2,8, 15, "werk", "thuis", false}),
  erlang:send_after(55000, PID,{maakAfspraak, PIDZo, 3, 13, 16, "vriend", "thuis", false}),
  erlang:send_after(55000, PID,{maakAfspraak, PIDDo, 3, 13, 16, "vriend", "thuis", true}),
  PID!{veranderStop , false},
  erlang:send_after(1000000, PID,{veranderStop,true}).






start()->
  Pid= spawn(?MODULE,init ,[]),
  register(toplevel, Pid),
  Pid.

init()->
  ets:new(locaties , [duplicate_bag,named_table,public]),
  ets:new(log,[named_table,duplicate_bag,public]),
  ets:new(objecten,[ordered_set,named_table,public]),
  ets:insert(objecten,{"passagier",passagier,"unbound","unbound",nul}),
  loop(-0.1,true, 0,[]).

loop(Tijd, Stop, Logcount,Families)->
  receive
    {insert , Loc1 , Loc2 , Duur}-> ets:insert(locaties,{Loc1,Loc2 , Duur}),loop(Tijd, Stop, Logcount,Families);
    {families, PID} ->
    		PID!getInfoFamilies(Families, []), 
    		loop(Tijd, Stop, Logcount,Families);
    {getTijdEnLog, PID} ->
    		PID!{Tijd,Logcount},
    		loop(Tijd, Stop, Logcount,Families);
    {lookup,Loc1} -> self()!{bericht,ets:lookup(locaties,Loc1)},loop(Tijd, Stop, Logcount,Families);
    {bericht,Message}-> erlang:display(Message),loop(Tijd, Stop, Logcount,Families);
    {add, PID} ->
      PID!{updateData, self()},
      loop(Tijd,Stop, Logcount,Families);
    {updateDataP, Naam, PIDPersoon, Locatie, Rijbewijs} ->
      ets:insert(objecten, {PIDPersoon, persoon, Naam, Locatie, Rijbewijs}),
      loop(Tijd, Stop, Logcount,Families);
    {updateDataA, Naam, PID, Locatie,VN} -> ets:insert(objecten, {PID, auto, Naam , Locatie,VN}),
      loop(Tijd, Stop, Logcount,Families);
    {updateDataF, Naam, PID, Locatie,VN} -> ets:insert(objecten, {PID, fiets, Naam , Locatie,VN}),
      loop(Tijd, Stop, Logcount,Families);
    {updateDataFamilie,FNaam,PID,Pa,Ma,Kinders,Res}->ets:insert(objecten,{PID,FNaam, Pa, Ma, Kinders,Res}),loop(Tijd, Stop, Logcount,Families);
    {getobject , PID}-> self()!{bericht,ets:lookup(objecten,PID)},
      loop(Tijd, Stop, Logcount,Families);
    {setTijd , Nieuwetijd}-> if(Nieuwetijd == 168.0)->
      PID = self(),self()!{getTijd},getFamilies(Families,0.0,PID),self()!{addTijd}, getFamilies3(Families, self()),loop(0.0, Stop, Logcount,Families);
                               true ->PID = self(),self()!{getTijd},getFamilies(Families,Nieuwetijd,PID),self()!{addTijd},loop(Nieuwetijd, Stop, Logcount,Families)
                             end;
    {addTijd} -> if(Stop == false) ->NTijd = trunc(Tijd+0.1,1),erlang:send_after(100,self(),{setTijd,NTijd}),loop(Tijd, Stop, Logcount,Families);
                   true ->self()!{log,"tijd gestopt", Tijd},loop(Tijd,Stop,Logcount,Families)
                 end;
    {getTijd}->  IntTijd = float_to_integer(Tijd),Dag = getDag(Tijd),TijdVar = Tijd-(Dag-1)*24,if(IntTijd == true)->io:format("dag: ~p uur: :~p  \n",[Dag,TijdVar]),self()!{log,"setTijd",Tijd},
      if(TijdVar==0.0)-> erlang:display("nieuwe dag"),getFamilies2(Families,self(),Dag),loop(Tijd, Stop, Logcount,Families);
        true->loop(Tijd, Stop, Logcount,Families) %%pas gaan pollen op dagwissel
      end;
                                                                                                 true->loop(Tijd, Stop, Logcount,Families)
                                                                                               end;

    {gaNaar , Bestuurder, Vervoer , ReisDuur, ReisLocatie,PIDVN} ->
      PIDVN!{setToplevel , self()},
      PIDVN!{setBestuurder , Bestuurder},
      PIDVN!{setVervoer , Vervoer},
      PIDVN!{setDuur,ReisDuur},
      PIDVN!{setLocatie , ReisLocatie},
      PIDVN!{gaNaarErgens}, loop(Tijd,Stop, Logcount,Families);

    {getReisDuur , _Van , ReisLocatie, PersLocatie, PIDVN,Vervoer,Pers} -> if(PersLocatie == ReisLocatie) -> io:format("~p is al op Bestemming: ~p \n",[Pers,PersLocatie]),loop(Tijd,Stop, Logcount,Families);
                                                                            true ->ReisDuur = getDuur(ReisLocatie,ets:lookup(locaties,PersLocatie)),
                                                                              self()!{gaNaar ,Pers, Vervoer , ReisDuur , ReisLocatie,PIDVN} , loop(Tijd,Stop, Logcount,Families)
                                                                          end;
    {log, String, Value }-> NieuweLogcount = Logcount +1,
      ets:insert(log, {Logcount, String, Value}), loop(Tijd, Stop,NieuweLogcount,Families);
    {getLocatiePers,PID}-> [{PID,_, _Naam, Locatie, _Rijbewijs}] = ets:lookup(objecten,PID),
      erlang:display(Locatie), loop(Tijd, Stop, Logcount,Families);
    {setFamilie , NieuweFam}->self()!{log,"insert nieuwe familie",NieuweFam},loop(Tijd,Stop,Logcount,[NieuweFam|Families]);
    {veranderStop , NieuweStop} -> self()!{log , "veranderstop", NieuweStop},

      if(NieuweStop ==false )-> if(Families ==[])->self()!{log,"geen familie erin , dus tijd gaat niet omhoog",NieuweStop},loop(Tijd, NieuweStop,Logcount,Families);
                                  true->self()!{addTijd},self()!{log,"Er is een familie",NieuweStop},loop(Tijd, NieuweStop,Logcount,Families)
                                end;
        true ->loop(Tijd, NieuweStop,Logcount,Families)
      end;

    {maakAfspraak,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier}->
      self()!{checkPersoon,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Families},
      loop(Tijd, Stop, Logcount,Families);

    {checkPersoon,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Fam}->
      %%als men alle families overlopen heeft gaat deze Fam leeg zijn
      if(Fam == []) -> io:format("~p zit in geen enkele familie \n",[Persoon]), loop(Tijd, Stop, Logcount,Families);
        true-> Laatste = lists:last(Fam),
          Laatste!{checkPersoon,self(),Persoon,Van ,Tot ,HeenLocatie,TerugLocatie,IsPassagier,Fam},
          loop(Tijd, Stop, Logcount,Families)
      end;
    {erin,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Erin,Fam}->
      %%enkel deze code nog aanpassen voor naar intelligentie te gaan! code kan volledig zelfstandig tot hier geraken
      %%met lists:last(Fam) kan je familie opvragen waar de persoon bijhoort en zo kan men uit die familie de intelligentiePID eruit halen!
      if(Erin == true)-> lists:last(Fam)!{addAfspraak, Van, Tot, HeenLocatie, TerugLocatie, IsPassagier, Persoon, self()},loop(Tijd, Stop, Logcount,Families);
        true->FamZonder=lists:delete(lists:last(Fam),Fam),self()!{checkPersoon,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,FamZonder},loop(Tijd, Stop, Logcount,Families)
      %%weeral gaan checken maar de laatste familie eruit gegooit!
      end;
    {nieuweAfspraak, Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier}->
      self()!{checkPersoonPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Families},
      loop(Tijd, Stop, Logcount,Families);
    {checkPersoonPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Fam}->
      %%als men alle families overlopen heeft gaat deze Fam leeg zijn
      if(Fam == []) -> io:format("~p zit in geen enkele familie \n",[Persoon]), loop(Tijd, Stop, Logcount,Families);
        true-> Laatste = lists:last(Fam),
          Laatste!{checkPersoonPol,self(),Persoon,Van ,Tot ,HeenLocatie,TerugLocatie,IsPassagier,Fam},
          loop(Tijd, Stop, Logcount,Families)
      end;
    {erinPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,Erin,Fam}->
      %%enkel deze code nog aanpassen voor naar intelligentie te gaan! code kan volledig zelfstandig tot hier geraken
      %%met lists:last(Fam) kan je familie opvragen waar de persoon bijhoort en zo kan men uit die familie de intelligentiePID eruit halen!
      if(Erin == true)->lists:last(Fam)!{nieuweAfspraak, Van, Tot, HeenLocatie, TerugLocatie, IsPassagier, Persoon, self()},loop(Tijd, Stop, Logcount,Families);
        true->FamZonder=lists:delete(lists:last(Fam),Fam),self()!{checkPersoon,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,FamZonder},loop(Tijd, Stop, Logcount,Families)
      %%weeral gaan checken maar de laatste familie eruit gegooit!
      end;
    {maakAfspraak,Persoon,Dag,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier}-> DagTL = getDag(Tijd),
      if(Dag == DagTL)-> if(Van<Tot)->
        self()!{nieuweAfspraak, Persoon,(Dag-1)*24+Van,(Dag-1)*24+Tot,HeenLocatie,TerugLocatie,IsPassagier},loop(Tijd, Stop, Logcount,Families);
                           true->self()!{nieuweAfspraak, Persoon,(Dag-1)*24+Van,Dag*24+Tot,HeenLocatie,TerugLocatie,IsPassagier},loop(Tijd, Stop, Logcount,Families)
                         end;
        true->if(Van<Tot)->
          self()!{maakAfspraak,Persoon,(Dag-1)*24+Van,(Dag-1)*24+Tot,HeenLocatie,TerugLocatie,IsPassagier},loop(Tijd, Stop, Logcount,Families);
                true->self()!{maakAfspraak,Persoon,(Dag-1)*24+Van,Dag*24+Tot,HeenLocatie,TerugLocatie,IsPassagier},loop(Tijd, Stop, Logcount,Families)
              end
      end

  end.

getDuur(_,[])-> [];
getDuur(Loc2,[{_,Locatie2,Duur}])->if(Locatie2 == Loc2) -> Duur;
                                     true -> []
                                   end;
getDuur(Loc2 , [{_,Locatie2 , Duur}|XS])-> if(Locatie2 == Loc2) -> Duur;
                                             true -> getDuur(Loc2,XS)
                                           end.
getFamilies([],_,PID)->PID!{bericht,"nog geen familie toegevoegd!"},PID!{log,"getFamilie","geen families"};
getFamilies([X],Tijd,PID)->X!{checkAfspraak,Tijd,PID};
getFamilies([X|XS],Tijd,PID)->X!{checkAfspraak,Tijd,PID},getFamilies(XS,Tijd,PID).

getFamilies2([],PID,_)->PID!{niks};%%error control voor lege familie
getFamilies2([X],PID,Dag)->X!{generateFixedAgenda,Dag, PID};
getFamilies2([X|XS],PID,Dag)->X!{generateFixedAgenda,Dag, PID},getFamilies2(XS,PID,Dag).

getFamilies3([],PID)->PID!{niks};%%error control voor lege familie
getFamilies3([X],PID)->X!{nieuweWeek, PID};
getFamilies3([X|XS],PID)->X!{nieuweWeek, PID},getFamilies3(XS,PID).

%%http://www.qlambda.com/2013/10/erlang-truncate-floating-point-number.html
trunc(F, N) ->
  Prec = math:pow(10, N),
  trunc(round(F*Prec))/Prec.


%%https://www.codesd.com/item/how-to-check-if-a-float-is-an-integer-in-erlang.html
float_to_integer(N) when is_float(N) ->
  Integer = trunc(N),
  case N == Integer of
    true ->
      true;
    false ->
      false
  end;

float_to_integer(N) when is_integer(N) ->
  true.
getDag(Tijd) when (Tijd< 0) -> 0;
getDag(Tijd) when ((Tijd/24)<1)-> 1;
getDag(Tijd) when ((Tijd/24)<2)-> 2;
getDag(Tijd) when ((Tijd/24)<3)-> 3;
getDag(Tijd) when ((Tijd/24)<4)-> 4;
getDag(Tijd) when ((Tijd/24)<5)-> 5;
getDag(Tijd) when ((Tijd/24)<6)-> 6;
getDag(Tijd) when ((Tijd/24)<7)-> 7.

getAgenda() ->
	ets:match(afspraken, '$1').
	
maakAfspraak(Persoon,Dag,Van,Tot,Heenlocatie,Teruglocatie, Duratie, Passagier) ->
	ets:insert(locaties,{Heenlocatie, Teruglocatie, Duratie}),
	ets:insert(locaties,{Teruglocatie, Heenlocatie, Duratie}),
	toplevel!{maakAfspraak, Persoon, Dag, Van, Tot, Heenlocatie, Teruglocatie,Passagier},
	io:format("~p~n~p~n~p~n~p~n~p~n~p~n~p~n~p~n",[maakAfspraak, Persoon, Dag, Van, Tot, Heenlocatie, Teruglocatie,Passagier]),
	receive
		Result -> Result
	end.
	
verwijderAfspraak(index) ->
	toplevel!{verwijder, index, self()},
	receive
		Result -> Result
	end.
	
getLogs() ->
  	List = ets:match(log, '$1'),
  	format(List, []).
  	
getTijdEnLog() ->
	toplevel!{getTijdEnLog, self()},
	receive
		Result -> Result
	end.
  	
getLoginInfo() ->
	toplevel!{families, self()},
	receive
		Result -> Result
	end.
	
getInfoFamilies([], Out) -> Out;
getInfoFamilies([F], Out) ->
	 F!{getPersonen, self()},
	 receive
	   	[] ->	  
	   		%io:format("(318):~n",[]),
	   		Out;
	 	[P|Ps] -> 
	 		%io:format("(319):~p~n",[lists:append([R|Rs],Out)]),
	 		[P|Ps] ++ Out
	 	%Result -> io:format("Error toplevel(319): ~p~n",[Result])
	 end;
getInfoFamilies([F|Fs], Out) ->
	io:format("check fam: ~p~n",[F]),
	F!{getPersonen, self()},
	receive
		[] -> 
			%io:format("(326):~n",[]),
			getInfoFamilies(Fs, Out);
		[P|Ps] ->
			%io:format("(327):~p~n",[lists:append([R|Rs],Out)]), 
			getInfoFamilies(Fs, [P|Ps]++Out)
		%Result -> io:format("Error toplevel(326): ~p~n",[Result])
	end.
	
  	
format([], []) -> [];
format([[{_, Log, Data}]], Out) ->
	LogToBinary = list_to_binary(Log),
	DataToString = io_lib:format("~p",[Data]), 
	[[LogToBinary]++DataToString|Out];
format([[{_, Log, Data}]|Rs], Out) -> 
	LogToBinary = list_to_binary(Log),
	DataToString = io_lib:format("~p",[Data]), 
	format(Rs, [[LogToBinary]++DataToString|Out]).
	


