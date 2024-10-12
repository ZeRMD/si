:-ensure_loaded('RTXengine/RTXengine').
:-ensure_loaded(mqtt_prolog_messages).


:-dynamic mqtt_monitoring_handler/1.
create_monitoring_client:-
    load_mqtt_library,
    not(mqtt_monitoring_handler(_)),
    mqtt_broker(Broker_URL), % it is defined in the previous file (right click to see it)
    mqtt_create_client(client_monitoring, Broker_URL,   Handler),
    % the Handler is the C/C++ void *pointer inside the DLL.
    assert(mqtt_monitoring_handler(Handler)),
    mqtt_connect(Handler, _Result),
    !;
    true.

client_monitoring_on_connect_success(Handler):-
   format('success connection of ~w~n', [client_monitoring]),
   %mqtt_monitoring_handler(Handler2), % get the void * pointer
   mqtt_subscribe(Handler, sensor  ,1, _Result1). % QoS= 1

client_monitoring_on_message_arrived(Topic, Message, _Handler):-
    % format('received MQTT topic: ~w, Payload: ~w~n', [Topic, Message]),
    % store the sensors as facts in the knowledge base
    atom_json_dict(Message, JsonDict, []),
    StringName = JsonDict.name,
    StringValue = JsonDict.value,
    number_string(NumberValue, StringValue),
    atom_string(AtomName, StringName),
    (
        assert_fact(Topic,AtomName, NumberValue),
        !;
        format('Monitoring: Please, specify assert_fact predicate for message {name:~w, value:~w}~n',[AtomName, NumberValue]),
        true
    ),
    forward.


% X AXIS
assert_fact(sensor, x_is_at, -1):-
    retract_state( x_is_at(_)),
    !.

assert_fact(sensor, x_is_at, Position):-
    assert_state( x_is_at(Position)).


assert_fact(sensor, x_moving, Direction):-
    assert_state(x_moving(Direction)).

% Y AXIS
assert_fact(sensor, y_is_at, -1):-
    retract_state( y_is_at(_)),
    !.

assert_fact(sensor, y_is_at, Position):-
    assert_state( y_is_at(Position)).


assert_fact(sensor, y_moving, Direction):-
    assert_state(y_moving(Direction)).

% Z AXIS
assert_fact(sensor, z_is_at, -1.0):-
    retract_state( z_is_at(_)),
    !.

assert_fact(sensor, z_is_at, Position):-
    assert_state( z_is_at(Position)).


assert_fact(sensor, z_moving, Direction):-
    assert_state(z_moving(Direction)).


% Left Station
assert_fact(sensor,ls_has_part, 0):-
    retract_state(part_at_ls),
    !.

assert_fact(sensor, ls_has_part, 1):-
    assert_state(part_at_ls).

assert_fact(sensor, ls_moving, 0):-
    retract_state( ls_moving(_)),
    !.

assert_fact(sensor, ls_moving, Direction):-
    assert_state(ls_moving(Direction)).

% Right Station
assert_fact(sensor, rs_has_part, 0):-
    retract_state(part_at_rs),
    !.

assert_fact(sensor, rs_has_part, 1):-
    assert_state(part_at_rs).


assert_fact(sensor, rs_moving, 0):-
    retract_state( rs_moving(_)),
    !.

assert_fact(sensor, rs_moving, Direction):-
    assert_state(rs_moving(Direction)).
% Cage

assert_fact(sensor, part_in_cage, 0):-
    retract_state( part_in_cage(_)),
    !.

assert_fact(sensor, part_in_cage, _):-
    assert_state(part_in_cage).










