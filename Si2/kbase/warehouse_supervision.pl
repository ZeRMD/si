:-ensure_loaded(warehouse_config).
:-ensure_loaded(warehouse_dispatcher).
:-ensure_loaded(warehouse_monitoring).
:-ensure_loaded(warehouse_planner).

start_all:-
    create_monitoring_client,
    create_dispatcher_client.
