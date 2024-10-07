:-ensure_loaded(mqtt_prolog_messages).
:-ensure_loaded('RTXengine/RTXengine').
:-ensure_loaded(warehouse_config).
:-use_module(library(http/json)).

:-dynamic mqtt_dispatcher_handler/1.
create_dispatcher_client:-
    load_mqtt_library,
    not(mqtt_dispatcher_handler(_)),
    mqtt_broker(Broker_URL),
    mqtt_create_client(client_dispatcher,Broker_URL,Handler),
    % the Handler is the C/C++ void *pointer inside the DLL.
    assert(mqtt_dispatcher_handler(Handler)),
    mqtt_connect(Handler,_Result),
    !;
    true.

assert_command(Command):-
    create_dispatcher_client,
    get_time(TimeStamp),
    assert(command(Command, TimeStamp)),
    send_pending_commands.

assert_command(Command, TS):-
    create_dispatcher_client,
    % get_time(TimeStamp),
    assert(command(Command, TS)),
    send_pending_commands.

client_dispatcher_on_connect_success(_Handle):-
   writeln(dispatcher_on_connect_success),
   send_pending_commands.

client_dispatcher_on_publish_success(_Topic, JsonMessageSent, _Handler ):-
    % writeln(on_publish_success(JsonMessageSent)),
    atom_json_dict(JsonMessageSent, JsonDict, []),
    StringName        = JsonDict.name,
    StringValue = JsonDict.value,
    number_string(NumberValue, StringValue),
    atom_string(AtomName, StringName),
    % writeln( mqtt(AtomName, NumberValue)  ),
    retract(command((AtomName, NumberValue), _TS)),
    send_pending_commands.

send_pending_commands :-
    command( (Name, Value), _TS), %e.g. (Command, Value)=(motor_x, 1)
    number_string(Value, StringValue),
    JSONTerm = json([name=Name, value=StringValue]),
    atom_json_term(JSONcommand, JSONTerm, []), % {"name":"motor_x", "value":"1"}
    mqtt_dispatcher_handler(Handler),
    mqtt_publish(Handler, 'actuator', JSONcommand, 1, _Result),
    !;
    true.

%******************************************************%
%Se o plano tiver acabado BO, fim
defrule([name: empty_plan_rule],
    if plan(Ref,    [   ]    )  then [    %retract finished/empty
       retractall(plan(Ref,[])),          %plans
       format('finished: plan ~w~n',[Ref])
    ]
).

%******************************************************%
% Vamos apanhar as acoes que sao de mandar o sistema mexer aka
% assert command, desta maneira nao precisamos de ter dentro do plan uma
% acao mesmo assert_command e podemos mandar so o facto
actuators_list([ (motor_x, _), (motor_y,_), (motor_z,_), (ls, _), (rs,_) ]).

defrule([name: rule_execute_actuator_command, priority:10],
    if plan(Ref,  [Command|ListOfActions])
        and actuators_list(ActuatorsList)
        and member(Command, ActuatorsList)
    then[
       assert_command(Command),
       retractall( plan(Ref,  [Command|ListOfActions])),
       assert(  plan(Ref,  ListOfActions))%,
       %format('command: ~w~n', [Command])
    ]
).


%******************************************************%
% Se o plano nao acabou a dica e executar a proxima acao do plano e
% retira-la da lista de acoes
defrule([name: rule_non_empty_plan],
    if plan(Ref,  [Statement|ListOfActions])     % plan with first Action/Statement and Tail
        and functor(Statement, Name, Arity)
        % and actuators_list(List)
        % and not(member(Statement,List))
        and callable(Statement)
        and current_predicate(Name/Arity)
        and (Statement)  % the statement is executed in this line
    then[
       retractall( plan(Ref,  [Statement|ListOfActions])),   % retract the plan
       assert(  plan(Ref,  ListOfActions))                   % assert the plan without the current Statement
    ]                                                                                       %
).

%******************************************************%
% A ideia aqui e implementar as funcoes do wait

% wait(some_state) of warehouse
wait(Condition):-
    not(functor(Condition,'[|]', _ )),
    state(Condition, _).

% wait(not(some_state)) of warehouse
wait( not(Condition)):-
    not(functor(Condition,'[|]', _ )),
    not(state(Condition, _)).

wait(Condition):-
   not(functor(Condition,'[|]', _ )),
   functor(Condition, Name, _),
   current_predicate(Name/_),
   callable(Condition),
   Condition.

defrule([name: wait_rule_check_state_4],
    if  plan(Ref, [wait([])|ListOfActions]) then [
       retractall( plan(Ref,[wait([])|ListOfActions])),
       assert( plan(Ref,ListOfActions))
    ]
).

defrule([name: wait_rule_check_state_5],
    if  plan(Ref,[wait( [Condition|ConditionsList])|ListOfActions])
then [
       retractall(plan(Ref,[wait( [Condition|ConditionsList])|ListOfActions])),
       assert(plan(Ref,[wait(Condition),wait( ConditionsList)|ListOfActions]))
       %  ,format('wait____5: ~w, plan: ~w~n',[Condition, Ref])
    ]
).

%******************************************************%
% A ideia aqui e implementar as funcoes do delay

:-dynamic timer/3. % timer(TimeID, Start_TS, Delay_in_seconds).

delay(TimerID, Delay):-
    \+ timer(TimerID, _,_),
    get_time(TS),
    assert(timer(TimerID,TS, Delay)),
    % mqtt_dispatcher_handler(Handler),
    % mqtt_publish(Handler, 'time_delay', TimerID , 1, _Result),
    !,
    thread_create(execute_goal_after_delay(forward, Delay), _, [detached(true)]),
    fail.

delay(TimerID, Delay):-
    timer(TimerID, TS, Delay),
    get_time(Tnow),
    Diff is Tnow - TS,
    Diff < Delay,
    % thread_create(execute_goal_after_delay(forward, Diff), _, [detached(true)]),
    !,
    fail.

delay(TimerID, Delay):-
    timer(TimerID, TS, Delay),
    get_time(Tnow),
    Diff is Tnow - TS,
    Diff >= Delay,
    retractall( timer(TimerID, _,_)).
    %thread_create(execute_goal_after_delay(forward, Diff), _, [detached(true)]).

execute_goal_after_delay(Goal, Delay):-
    sleep(Delay),
    Goal.

%******************************************************%
% Agora vem funcoes de semaphore, de funcionamento parecido a str

:-dynamic semaphore/2.

sem_give(SemaphoreID):-
    semaphore(SemaphoreID, Counter),
    Counter2 is Counter + 1,
    retractall(  semaphore(SemaphoreID, Counter ) ),
    assert(   semaphore(SemaphoreID, Counter2) ),
    !.

sem_give(SemaphoreID):-
    \+ semaphore(SemaphoreID, _),
    assert(semaphore(SemaphoreID, 1)).

sem_wait(SemaphoreID):-
    semaphore(SemaphoreID, Counter),
    Counter > 0,
    Counter2 is Counter - 1,
    retractall(  semaphore(SemaphoreID, Counter ) ),
    assert(   semaphore(SemaphoreID, Counter2) ),
    !.

sem_wait(SemaphoreID):-
    \+ semaphore(SemaphoreID, _),
    assert(semaphore(SemaphoreID, 0)),
    fail.

%******************************************************%
% abilidade de fazer planos compostos por outros planos

defrule([name: plan_with_sub_plan_rule],
    if plan(PlanID,[   plan(SubplanID,Plan_sub_List)  |   ListOfActions])
       then [
       assert(plan(SubplanID, Plan_sub_List)),
       retractall(plan(PlanID, [plan(SubplanID,  Plan_sub_List)|ListOfActions])),
       assert(plan(PlanID, ListOfActions))
       % ,format('subplan: ~w~n',[SubplanID])
    ]
).


%******************************************************%
%                  Armazem de funcoes
%******************************************************%
% assert(plan(xx_cal, [(motor_x, 1), wait( x_is_at(_) ), (motor_x, 0)])), forward.
% Este de cima anda para o proximo x e para
% assert( plan(xz_move, [plan(xx_move, [ (motor_x, 1), delay(xd, 2), (motor_x, 0)  ]), plan(zz_move, [   (motor_z, 1),   delay(zd, 2),   (motor_z, 0)   ]) ])), forward.
% Este anda na diagonal em x e z no sentido positivo de ambos por 2
% segundos com delay.
% O proximo e fixe, e um plano com 2 planos um para mexer x e outro para
% mexer z para a pos (3,3)
% assert( plan(goto_xz, [plan(goto_x, [ (motor_x,1), wait( x_is_at(3) ), (motor_x,0)]), plan(goto_z, [(motor_z,1), wait(z_is_at(3.0)), (motor_z,0)]) ])), forward.
% Tambem se pode fazer chamando 2 planos em separado como esta em baixo
% assert(plan(goto_x, [(motor_x,1), wait( x_is_at(5) ), (motor_x,0)])), assert(plan(goto_z, [(motor_z,1), wait(z_is_at(5.0)), (motor_z,0)])), forward.

