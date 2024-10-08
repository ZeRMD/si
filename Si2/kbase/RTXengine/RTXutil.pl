
:-dynamic id_holder____1/1.
:-dynamic rtx/1.




test_with_catch(_RuleName, Goal, _DefaultResult):-

    \+ current_predicate(_,Goal),
    !,
    fail.

% test with existence_error(procedure,simula:on/2).
test_with_catch(RuleName, Goal, DefaultResult):-
    current_predicate(_,Goal),
    test_with_catch_final(RuleName, Goal, DefaultResult).


% test on other errors
test_with_catch_final(RuleName, Goal, DefaultResult):-
    catch(Goal, error(Error,Context),
      (
          log_format('Error in rule named ~w -> error(~w,~w) : ~n',[RuleName, Error,Context]),
          show_error_from_catch(RuleName, Error,Context),
          DefaultResult
       )
    ).

:-dynamic last_catch_error/1.
show_error_from_catch(RuleName, Error,Context):-
    \+ last_catch_error(Error),
    log_format('Error in rule named ~w -> error(~w,~w) : ~n',[RuleName, Error,Context]),
    retractall(last_catch_error(Error)),
    assert(last_catch_error(Error)),
    !.
show_error_from_catch(_RuleName, _Error,_Context).



make_most_generic_term(Term, GenericTerm):-
     \+ compound(Term),
     GenericTerm = Term.

make_most_generic_term(Term, GenericTerm):-
     compound(Term),
     make_most_generic_term_2(Term, GenericTerm).

make_most_generic_term_2(Term, GenericTerm):-
     compound(Term),
     functor(Term, Name, _Arity),
     findall(SubGeneric,(
         arg(_, Term, SubTerm),
         make_most_generic_term_2(SubTerm, SubGeneric)
     ),  L),
     TermAsList = [Name | L],
     GenericTerm =.. TermAsList,
     !.
make_most_generic_term_2(_, _).



is_undefined(Term):-
    not(is_defined(Term)).

is_defined(Term):-
    catch(Term, _Exception, false).


new_id(NewID):-
    id_holder____1(OldID),
    NewID is OldID +1,
    retractall(id_holder____1(OldID)),
    assert(id_holder____1(NewID)),
    !.

new_id(1):-
    \+ id_holder____1(_),
    assert(id_holder____1(1)).



/*
retract_old_diagnoses:-
    forall( done(Goal), retract_safe(diagnose(Goal)) ).

assert_new_diagnoses:-
    forall(goal(Goal), assert_once(diagnose(Goal))).
*/


write_list(List):-
    writeln('['),
    write_list_2(List, 1),
    writeln(']').


write_list_2([], _).
write_list_2([X|L], Position):-
    log_format('  ~|~`0t~d~2+ -> ~w~n',[Position, X]),
    P is Position + 1,
    write_list_2(L, P).


write_list_inline([]).
write_list_inline([X]):-
    log(X).
write_list_inline([X1,X2|L]):-
    log(X1),
    log(', '),
    write_list_inline([X2|L]).



/*
assert_rtx(Fact):-defrule([name:r6], if invoice_sent                                     then [ writeln(make_payment),assert_rtx(payment_made)      ]).
    catch(Fact,_Cather, false),
    rtx(Fact),
    !.
*/

declare_facts([]).
declare_facts([Functor|List]):-
    dynamic(Functor),
    declare_facts(List).



assert_rtx(Fact):-
    assert(Fact),
    assert(rtx(Fact)).

retract_rtx(Fact):-
    retract(Fact),
    retract(rtx(Fact)).

retractall_rtx:-
    forall(rtx(Fact), retract(Fact)),
    retractall(rtx(_)).


replace_rtx(NewFact):-
    functor(NewFact, Name, Arity),
    findall(_, between(1,Arity,_Ignore), List),
    ExistingFacts =.. [Name | List],
    catch(retractall(ExistingFacts), _Catcher1, true),
    catch(retractall(rtx(ExistingFacts)), _Catcher2, true),
    assert(NewFact),
    assert(rtx(NewFact)).




assert_single(NewFact):-
    catch( retractall(NewFact),
           _Catcher,
           true),
    assert(NewFact).



assert_all(NewFact):-
    functor(NewFact, Name, Arity),
    findall(_, between(1,Arity,_Ignore), List),
    ExistingFacts =.. [Name | List],
    catch(retractall(ExistingFacts), _Catcher, true),
    assert(NewFact).


assert_once(NewFact):-  /* destrois all previous facts with the same pattern as NewFact */
    functor(NewFact, Name, Arity),
    findall(_, between(1,Arity,_Ignore), List),
    OldFact =..[Name|List],
    dynamic(Name/Arity),
    assert_once_2(OldFact, NewFact).


assert_once_2(OldFact, NewFact):-
    OldFact,
    retractall(OldFact),
    assert(NewFact),
    !.


assert_once_2(_, NewFact):-
    assert(NewFact).


retract_safe(Fact):-
    functor(Fact, Name, Arity),
    current_predicate(Name/Arity),
    retract_safe_2(Fact),
    !.

retract_safe(Fact):-
    functor(Fact, Name, Arity),
    dynamic(Name/Arity),
    retract_safe_2(Fact),
    !.

retract_safe_2(Fact):-
    \+ Fact,
    !.

retract_safe_2(Fact):-
    retract(Fact),
    !.





/*
value_of_prolog_functor(Name, Value):-
    current_predicate(Name/N),
    value_of_prolog_functor(N, Name, Value),
    !.

value_of_prolog_functor(_Name, false).



value_of_prolog_functor(0, Name, Value):-
    try_dynamize_it(Name, 1),
    Term =.. [Name],
    (   ((Term) -> Value=true); Value=false ).


value_of_prolog_functor(1, Name, Value):-
    try_dynamize_it(Name, 1),
    Term =.. [Name, Value],
    Term.
*/



/*
system_has_states(StatesList):-
    forall( member(State, StatesList),
            (   functor(State, Name, Arity),
                try_dynamize_it(Name, Arity),
                State
            )).

*/

system_has_states(States, SystemStates):-
    forall( member(State, States), member(State, SystemStates)).


list_to_string(List, String):-
   with_output_to(atom(String_temp), write_list_term(List)),
   atom_concat('[',String_temp, S2),
     atom_concat(S2,']', String).

write_list_term([]).
write_list_term([X | [] ]):-
    log(X).
write_list_term([X | XL ]):-
    log(X),
    log(','),
    write_list_term(XL).




sublist([], []).

sublist([A|T], [A|L]):-
    sublist(T, L).

sublist(T, [_|L]):-
    sublist(T, L).


sublist(Sub,List,MinLen,MaxLen) :-
    between(MinLen,MaxLen,Len),
    length(Sub,Len),
    sublist(Sub,List).

choose(Sub,List) :-
    sublist(Sub,List,1,2),
    member(f,Sub).









throw_console(Message):-
   current_output(Curr),
   set_output(user_output),
   % throw(Message),
   writeln(Message),
   set_output(Curr).


:-dynamic enable_logs/0.
:-assert(enable_logs).
log(_):-
    \+ enable_logs,
    !.
log(Sentence):-
   current_output(Curr),
   set_output(user_output),
   write(Sentence),
   set_output(Curr),!.

log_nl(_):-
    \+ enable_logs,
    !.
log_nl(Sentence):-
   current_output(Curr),
   set_output(user_output),
   writeln(Sentence),
   set_output(Curr),!.

log_format(_, _):-
    \+ enable_logs,
    !.
log_format(String, Arguments):-
   current_output(Curr),
   set_output(user_output),
   format(String, Arguments),
   set_output(Curr),!.


