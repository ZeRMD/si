:-ensure_loaded('RTXengine/RTXstrips_planner').

strips([
    act [(motor_x, 1)],
    pre [x_moving(0)],
    add [x_moving(1)],
    del [x_moving(0)]
]).

strips([
    act [(motor_x, -1)],
    pre [x_moving(0)],
    add [x_moving(-1)],
    del [x_moving(0)]
]).


strips([
    act [(motor_x, 0)],
    pre [x_moving(Direction)],
    add [x_moving(0)],
    del [x_moving(Direction)]
]) :-
     member_of_world(x_moving(Direction)),
    (Direction == -1 ; /*OR*/ Direction == 1).

strips([
    act[wait(x_is_at(Xf))],
    pre[x_moving(1), x_is_at(Xi)],
    add[x_is_at(Xf)],
    del[x_is_at(Xi)]
]):-
    member_of_world(x_is_at(Xi)),
    Xi<Xf.

strips([
    act[wait(x_is_at(Xf))],
    pre[x_moving(-1), x_is_at(Xi)],
    add[x_is_at(Xf)],
    del[x_is_at(Xi)]
]):-
    member_of_world(x_is_at(Xi)),
    Xi>Xf.
