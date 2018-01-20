%%%-------------------------------------------------------------------
%%% @author Simon
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 02. nov 2017 11:35
%%%-------------------------------------------------------------------
-module(familie).
-author("Laurens").



%% API
-include("records.hrl").
-export([start/0, init/0,loop/8, float_to_integer/1]).

start()->
  PID = spawn(?MODULE, init, []),
  PID.


init()->

  loop("","",[],[],"", intelligentie:start(), [], []).

loop(Pa,Ma,Kinderen,Resources,Fnaam,Intelligentie,Autos,Fietsen)->
  receive
    {nieuweWeek,PID}-> 
    	clearPersonen([Pa, Ma|Kinderen], PID),
    	loop(Pa,Ma,Kinderen,Resources,Fnaam,Intelligentie,Autos,Fietsen);
    {getPersonen, PID} -> 
    	PID!getInfoPersonen([Pa, Ma|Kinderen], Fnaam, []),
    	loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {updateData, PID} -> PIDF = self(),PID!{updateDataFamilie,Fnaam,PIDF,Pa,Ma,Kinderen,Resources} , loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {sms,Message}-> erlang:display(Message),loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {insertMoeder, Moeder,PID} -> PID!{log,"insertMoeder", Moeder},self()!{updateData,PID},loop(Pa ,Moeder, Kinderen , Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {insertVader, Vader, PID} -> PID!{log,"insertVader", Vader},self()!{updateData,PID},loop(Vader,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {insertKind , Kind , PID} -> PID!{log,"insertKind", Kind}, self()!{updateData,PID}, loop(Pa, Ma, [Kind|Kinderen], Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {insertAuto, Resource , PID}->PID!{log,"insertResource", Resource},self()!{updateData,PID} , loop(Pa,Ma,Kinderen,[Resource|Resources],Fnaam,Intelligentie, [Resource|Autos], Fietsen);
    {insertFiets, Resource , PID}->PID!{log,"insertResource", Resource},self()!{updateData,PID} , loop(Pa,Ma,Kinderen,[Resource|Resources],Fnaam,Intelligentie, Autos, [Resource|Fietsen]);
    {insertFnaam, FamilieN, PID}-> PID!{log,"insertFnaam",FamilieN},self()!{updateData,PID},loop(Pa,Ma,Kinderen,Resources,FamilieN, Intelligentie, Autos, Fietsen);
    {checkAfspraak,Tijd,PID}->
      if(Pa == "") -> Dag = getDag(Tijd),TijdVar = Tijd-(Dag-1)*24, if(TijdVar == 0.0)->PID!{log,"geenPa",Tijd};%erin gezet om na het uur te loggen ipv om de 0.1
                                                                      true-> PID!{niks} %%erlang verwacht iets in de true statement, dit doet niks
                                                                    end;
        true -> Pa!{getAfspraak , Tijd,PID}
      end,
      if(Ma == "")->Dag2 = getDag(Tijd),TijdVar2 = Tijd-(Dag2-1)*24, if(TijdVar2==0.0)->PID!{log,"geenMa",Tijd};
                                                                       true-> PID!{niks}
                                                                     end;
        true-> Ma!{getAfspraak , Tijd,PID}
      end,
      if(Kinderen==[])->Dag3 = getDag(Tijd),TijdVar3 = Tijd-(Dag3-1)*24, if(TijdVar3==0.0)->PID!{log,"geenKinderen",Tijd};
                                                                           true-> PID!{niks}
                                                                         end;
        true->getKind(Kinderen,Tijd,PID)
      end,
      loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {checkPersoon,PID,Persoon,Van ,Tot ,HeenLocatie,TerugLocatie,IsPassagier,Familie}->
      case Persoon of
        Pa -> PID!{erin,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam,Intelligentie, Autos, Fietsen);
        Ma -> PID!{erin,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
        _ -> Var = checkKind(Kinderen,Persoon),
          if(Var == false)-> PID!{erin,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,false,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);%zit niet in de familie
            true->PID!{erin,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen)
          end
      end;
    {checkPersoonPol,PID,Persoon,Van ,Tot ,HeenLocatie,TerugLocatie,IsPassagier,Familie}->
      case Persoon of
        Pa -> PID!{erinPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam,Intelligentie, Autos, Fietsen);
        Ma -> PID!{erinPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
        _ -> Var = checkKind(Kinderen,Persoon),
          if(Var == false)-> PID!{erinPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,false,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);%zit niet in de familie
            true->PID!{erinPol,Persoon,Van,Tot,HeenLocatie,TerugLocatie,IsPassagier,true,Familie},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen)
          end
      end;
    {addAfspraak,Van, Tot, Locatie1, Locatie2, Passagiers, Persoon, PID}->Intelligentie!{maakAfspraak, Van, Tot, Locatie1, Locatie2, Passagiers, Persoon, PID}, loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {generateFixedAgenda,Dag, PID}->Intelligentie!{setAutos,Autos }, Intelligentie!{setFietsen,Fietsen }, Intelligentie!{setChauffeurs, [Pa, Ma]},Intelligentie!{generateFixedAgenda,Dag, PID}
      ,loop(Pa,Ma,Kinderen,Resources,Fnaam,Intelligentie,Autos,Fietsen);
    {nieuweAfspraak, Van, Tot, Locatie1, Locatie2, Passagiers, Persoon, PID }-> Intelligentie!{nieuweAfspraak, Van, Tot, Locatie1, Locatie2, Passagiers, Persoon, PID}, loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen);
    {setResources}-> Intelligentie!{setResources, Autos, Fietsen, [Pa, Ma]},loop(Pa,Ma,Kinderen,Resources,Fnaam, Intelligentie, Autos, Fietsen)
  end.


%if(Pa == "Unbound") ->PID!{log,"geenPa",Tijd},loop(Pa,Ma,Kinderen,Resources,Fnaam);
%true -> Pa!{getAfspraak , Tijd,PID},loop(Pa,Ma,Kinderen,Resources,Fnaam)
%end,
%if(Ma == "Unbound")->PID!{log,"geenMa",Tijd},loop(Pa,Ma,Kinderen,Resources,Fnaam);
%true-> Ma!{getAfspraak , Tijd,PID},loop(Pa,Ma,Kinderen,Resources,Fnaam)
%end,
%if(Kinderen ==[])->PID!{log,"geenKinderen",Tijd},loop(Pa,Ma,Kinderen,Resources,Fnaam);
%true->getKind(Kinderen,Tijd,PID),loop(Pa,Ma,Kinderen,Resources,Fnaam)
%end;

getKind([],_,_)->[];
getKind([X],Tijd,PID)->X!{getAfspraak , Tijd,PID};
getKind([X|XS],Tijd,PID)->X!{getAfspraak , Tijd,PID}, getKind(XS,Tijd,PID).

checkKind([],_)->false;
checkKind([X],Persoon)-> if(X==Persoon)-> true;
                           true -> false
                         end;
checkKind([X|XS],Persoon)-> if(X==Persoon)-> true;
                              true -> checkKind(XS,Persoon)
                            end.
clearPersonen([], _PID)-> [];
clearPersonen([K], PID)-> if(K == []) -> [];
                            true -> K!{clearAgenda, PID}
                          end;
clearPersonen([K|Personen], PID)-> if(K == []) -> clearPersonen(Personen, PID);
                                    true -> K!{clearAgenda, PID}, clearPersonen(Personen, PID)
                                   end.
float_to_integer(N) when is_float(N) ->
  Integer = trunc(N),
  case N == Integer of
    true ->
      true;
    false ->
      false
  end.
%%os:timestamp() voor tijd te krijgen
%%time.now-diff(t1,t2);

%{getLocatie , Auto , ReisLocatie , PIDVN ,PID} -> ets:insert(log,{"getLocatie voor ga naar" , self() , Auto , ReisLocatie , PIDVN})
%, PID!{gaNaar3 , self() , ReisLocatie,PIDVN , Auto,Locatie} , loop(Locatie,Rijbewijs,Naam,Agenda)
getDag(Tijd) when (Tijd< 0) -> 0;
getDag(Tijd) when ((Tijd/24)<1)-> 1;
getDag(Tijd) when ((Tijd/24)<2)-> 2;
getDag(Tijd) when ((Tijd/24)<3)-> 3;
getDag(Tijd) when ((Tijd/24)<4)-> 4;
getDag(Tijd) when ((Tijd/24)<5)-> 5;
getDag(Tijd) when ((Tijd/24)<6)-> 6;
getDag(Tijd) when ((Tijd/24)<7)-> 7.

getInfoPersonen([[], _], _ , Out) -> Out;
getInfoPersonen([_, []], _, Out) -> Out;
getInfoPersonen([P], FName, Out) ->
	P!{getInfo, self()},
		 receive
		 	Naam -> 
		 		ProcessID = pid_to_binary(P),
		 		[[ProcessID,list_to_binary(FName), list_to_binary(Naam)]|Out]
		 end;
getInfoPersonen([P|Ps], FName, Out) ->
	P!{getInfo, self()},
	receive
		Naam -> 
			ProcessID = pid_to_binary(P),
			getInfoPersonen(Ps, FName, [[ProcessID, list_to_binary(FName), list_to_binary(Naam)]|Out])
	end.
	
pid_to_binary(PID)-> list_to_binary(pid_to_list(PID)).
	
