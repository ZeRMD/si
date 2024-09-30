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


assert_fact(sensor, x_direction, Direction):-
    assert_state(x_direction(Direction)).

assert_fact(sensor, x_direction, 0):-
    retract_state( x_direction(_)),
    !.

% Y AXIS
assert_fact(sensor, y_is_at, -1):-
    retract_state( y_is_at(_)),
    !.

assert_fact(sensor, y_is_at, Position):-
    assert_state( y_is_at(Position)).


assert_fact(sensor, y_direction, Direction):-
    assert_state(y_direction(Direction)).

% Z AXIS
assert_fact(sensor, z_is_at, -1):-
    retract_state( z_is_at(_)),
    !.

assert_fact(sensor, z_is_at, Position):-
    assert_state( z_is_at(Position)).


assert_fact(sensor, z_direction, Direction):-
    assert_state(z_direction(Direction)).


% Left Station
assert_fact(sensor, ls_has_part, Has):-
    assert_state(ls_has_part(Has)).

assert_fact(sensor, ls_direction, Direction):-
    assert_state(ls_direction(Direction)).

assert_fact(sensor, ls_direction, 0):-
    retract_state( ls_direction(_)),
    !.

% Right Station

assert_fact(sensor, rs_has_part, Has):-
    assert_state(rs_has_part(Has)).

assert_fact(sensor, rs_direction, Direction):-
    assert_state(rs_direction(Direction)).

assert_fact(sensor, rs_direction, 0):-
    retract_state( rs_direction(_)),
    !.

% Cage

assert_fact(sensor, part_in_cage, Is):-
    assert_state(part_in_cage(Is)).










