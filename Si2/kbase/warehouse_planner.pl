:-ensure_loaded('RTXengine/RTXstrips_planner').

% Wait State

strips([
    act[wait(State)],
    pre[],
    add[wait(State)],
    del[]
]).

%************************************************%
% X Axis
%************************************************%

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

%************************************************%
% Y Axis
%************************************************%

strips([
    act [(motor_y, 1)],
    pre [y_moving(0)],
    add [y_moving(1)],
    del [y_moving(0)]
]).

strips([
    act [(motor_y, -1)],
    pre [y_moving(0)],
    add [y_moving(-1)],
    del [y_moving(0)]
]).

strips([
    act [(motor_y, 0)],
    pre [y_moving(Direction)],
    add [y_moving(0)],
    del [y_moving(Direction)]
]) :-
     member_of_world(y_moving(Direction)),
    (Direction == -1 ; /*OR*/ Direction == 1).

strips([
    act[wait(y_is_at(Yf))],
    pre[y_moving(1), y_is_at(Yi)],
    add[y_is_at(Yf)],
    del[y_is_at(Yi)]
]):-
    member_of_world(y_is_at(Yi)),
    Yi<Yf.

strips([
    act[wait(y_is_at(Yf))],
    pre[y_moving(-1), y_is_at(Yi)],
    add[y_is_at(Yf)],
    del[y_is_at(Yi)]
]):-
    member_of_world(y_is_at(Yi)),
    Yi>Yf.

%************************************************%
% Z Axis
%************************************************%

strips([
    act [(motor_z, 1)],
    pre [z_moving(0)],
    add [z_moving(1)],
    del [z_moving(0)]
]).

strips([
    act [(motor_z, -1)],
    pre [z_moving(0)],
    add [z_moving(-1)],
    del [z_moving(0)]
]).

strips([
    act [(motor_z, 0)],
    pre [z_moving(Direction)],
    add [z_moving(0)],
    del [z_moving(Direction)]
]) :-
     member_of_world(z_moving(Direction)),
    (Direction == -1 ; /*OR*/ Direction == 1).

strips([
    act[wait(z_is_at(Zf))],
    pre[z_moving(1), z_is_at(Zi)],
    add[z_is_at(Zf)],
    del[z_is_at(Zi)]
]):-
    member_of_world(z_is_at(Zi)),
    Zi<Zf.

strips([
    act[wait(z_is_at(Zf))],
    pre[z_moving(-1), z_is_at(Zi)],
    add[z_is_at(Zf)],
    del[z_is_at(Zi)]
]):-
    member_of_world(z_is_at(Zi)),
    Zi>Zf.

%******************%
% Left Station
%******************%

strips([
    act [(motor_ls, 1)],
    pre [ls_moving(0)],
    add [ls_moving(1)],
    del [ls_moving(0)]
]).

strips([
    act [(motor_ls, -1)],
    pre [ls_moving(0)],
    add [ls_moving(-1)],
    del [ls_moving(0)]
]).

strips([
    act [(motor_ls, 0)],
    pre [ls_moving(Direction)],
    add [ls_moving(0)],
    del [ls_moving(Direction)]
]) :-
     member_of_world(ls_moving(Direction)),
    (Direction == -1 ; /*OR*/ Direction == 1).

% LS com Carro

strips([
    act [wait(part_at_ls)],
    pre [ls_moving(1)],
    add [part_at_ls],
    del []
]).

strips([
    act [(motor_ls, 0)],
    pre [part_at_ls],
    add [car_arrival],
    del []
]).

%***************%
% Right Station
%***************%

strips([
    act [(motor_rs, 1)],
    pre [rs_moving(0)],
    add [rs_moving(1)],
    del [rs_moving(0)]
]).

strips([
    act [(motor_rs, -1)],
    pre [rs_moving(0)],
    add [rs_moving(-1)],
    del [rs_moving(0)]
]).

strips([
    act [(motor_rs, 0)],
    pre [rs_moving(Direction)],
    add [rs_moving(0)],
    del [rs_moving(Direction)]
]) :-
     member_of_world(rs_moving(Direction)),
    (Direction == -1 ; /*OR*/ Direction == 1).

% hierarchical plans

% Go To XZ
strips([
    act Plan,
    pre [x_is_at(Xi), z_is_at(Zi)],
    add [x_is_at(Xf), z_is_at(Zf)],
    del [x_is_at(Xi), z_is_at(Zi)],
    priority(10)
]):-
     world(W1,_),
     member_of_goals(x_is_at(Xf)),
     member_of_goals(z_is_at(Zf)),
     solve([x_is_at(Xf), x_moving(0)],W1, W2, PlanX),
     solve([z_is_at(Zf), z_moving(0)],W2, _W3, PlanZ),
     Plan = [plan(goto_x(Xf), PlanX), plan(goto_z(Zf), PlanZ)].

% cage_at(X,Z)
% move a cage para a pos em X e Z tem de estar nalgum sitio
strips([
    act [plan(goto_x(Xf),PlanX), plan(goto_z(Zf), PlanZ)],
    pre [x_is_at(Xi), z_is_at(Zi)],
    add [cage_at(Xf, Zf)],
    del [x_is_at(Xi), z_is_at(Zi)],
    effect W3
]):-
     world(W1,_),
     member(x_is_at(Xi), W1),
     member(z_is_at(Zi), W1),
     solve([x_is_at(Xf), x_moving(0)],W1, W2, PlanX),
     solve([z_is_at(Zf), z_moving(0)],W2, W3, PlanZ).

% Retirar a peca da Left Station
strips([
    act[ ],
    pre[ seq(
             cage_at(1,1.0),
             wait(x_is_at(1)),
             wait(z_is_at(1.0)),
             y_is_at(1),   y_moving(0),
             % wait(part_at_ls),
             part_at_ls,
             z_is_at(1.5), z_moving(0),
             y_is_at(2),   y_moving(0),
             z_is_at(1.0), z_moving(0)
         )
       ],
    add[ retrieved_car_from_ls],
    del[ ]
]).









