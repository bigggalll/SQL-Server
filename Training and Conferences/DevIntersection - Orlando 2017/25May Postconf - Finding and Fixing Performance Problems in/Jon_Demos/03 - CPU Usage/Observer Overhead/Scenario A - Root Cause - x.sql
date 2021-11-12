CREATE EVENT SESSION [ApplicationXYZ] ON SERVER 
ADD EVENT filestream.filetable_application_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_file_io_request(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_file_io_response(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_nso_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_nso_kill(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_nso_operation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_database_operation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_enumerate_getitem(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_item_get(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_item_modify(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_item_moverename(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_operation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT filestream.filetable_store_table_operation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlclr.clr_allocation_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlclr.clr_init_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlclr.clr_virtual_alloc_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlclr.gc_suspension(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.allocation_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.assert_fired(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.async_io_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.async_io_requested(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.cpu_config_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.crt_out_of_memory_routine_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.crt_signal_abort_called(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.deadlock_scheduler_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.dump_exception_routine_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.ex_terminator_called(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.exception_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.exit_routine_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.function_hook_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.idle_server_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.large_cache_caching_decision(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.large_cache_entry_value_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.large_cache_memory_pressure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.large_cache_state_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.large_cache_sweep(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.malloc_spy_corrupted_memory_detected(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.malloc_spy_memory_allocated(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.malloc_spy_memory_freed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.memory_broker_clerks_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.memory_broker_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.memory_node_oom_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.memory_utilization_effect_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.multiple_tasks_enqueued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.node_affinity_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.node_created(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.non_yielding_iocp_listener_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.non_yielding_rm_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.non_yielding_scheduler_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.page_allocated(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.page_freed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.page_heap_memory_allocated(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.page_heap_memory_freed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.process_killed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.quantum_thief(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.resource_monitor_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_created(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_destroyed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_deadlock_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_non_yielding_iocp_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_non_yielding_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_non_yielding_rm_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_stalled_dispatcher_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_monitor_system_health_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_online_state_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.scheduler_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.security_handler_routine_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.set_abort_callback_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.spinlock_backoff(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.spinlock_backoff_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.task_aborted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.task_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.task_enqueued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.task_started(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.thread_attached(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.thread_detached(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.wait_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlos.wait_info_external(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.additional_memory_grant(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.after_snipping_some_log(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.allocation_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.alter_table_update_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.alwayson_ddl_executed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.app_domain_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.assembly_load(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.attention(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.auto_stats(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.availability_group_lease_expired(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.availability_replica_automatic_failover_validation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.availability_replica_manager_state_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.availability_replica_state_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.background_job_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.bad_memory_detected(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.bad_memory_fixed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.batch_hash_join_separate_hash_column(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.batch_hash_table_build_bailout(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.begin_tran_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.begin_tran_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.bitmap_disabled_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.blocked_process_report(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_activation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_activation_stored_procedure_invoked(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_activation_task_aborted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_activation_task_limit_reached(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_activation_task_started(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_conversation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_conversation_group(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_corrupted_message(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_dialog_transmission_body_dequeue(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_dialog_transmission_body_enqueue(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_dialog_transmission_queue_dequeue(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_dialog_transmission_queue_enqueue(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_forwarded_message_dropped(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_forwarded_message_sent(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_message_classify(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_message_undeliverable(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_mirrored_route_state_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_queue_activation_alert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_queue_disabled(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_remote_message_acknowledgement(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_acksm_action_fire(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_acksm_event_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_acksm_event_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_deliverysm_action_fire(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_deliverysm_event_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_deliverysm_event_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_exception(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_lazyflusher_processing_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_lazyflusher_processing_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_lazyflusher_remove(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_lazyflusher_submit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_delete_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_delete_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_get(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_worktable_load_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_worktable_load_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_worktable_save_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_object_worktable_save_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_timer_armed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_timer_fire(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_timer_reset(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.broker_transmission_timer_set(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_manager_database_pages(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_manager_page_life_expectancy(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_manager_target_pages(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_node_database_pages(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_node_page_life_expectancy(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_pool_page_allocated(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.buffer_pool_page_freed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.catalog_metadata_cache_entry_added(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.catalog_metadata_cache_entry_pinned(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.catalog_metadata_cache_entry_removed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.catalog_metadata_cache_entry_unpinned(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.catalog_metadata_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cdc_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cdc_session(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.change_tracking_cleanup(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.checkpoint_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.checkpoint_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.column_store_object_pool_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.column_store_object_pool_miss(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.column_store_rowgroup_read_issued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.column_store_rowgroup_readahead_issued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.column_store_segment_eliminate(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.commit_tran_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.commit_tran_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.connectivity_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.constant_page_corruption_detected(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cpu_threshold_exceeded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_close(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_execute(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_implicit_conversion(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cached_cursor_added(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cached_cursor_removed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_cache_attempt(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_memory_usage(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_plan_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_plan_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_worktable_use_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_manager_cursor_worktable_use_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_open(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_prepare(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_recompile(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.cursor_unprepare(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_attached(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_created(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_detached(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_file_size_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_mirroring_state_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_started(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_stopped(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_suspect_data_page(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_transaction_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_transaction_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.database_uncontained_usage(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_backup_restore_throughput(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_bulk_copy_rows(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_bulk_copy_throughput(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_bulk_insert_rows(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_bulk_insert_throughput(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_data_file_size_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_dbcc_logical_scan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_cache_read(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_file_size_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_file_used_size_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_flush(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_flush_wait(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_growth(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_shrink(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_log_truncation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.databases_shrink_data_movement(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deadlock_monitor_mem_stats(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deadlock_monitor_perf_stats(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deadlock_monitor_pmo_status(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deadlock_monitor_serialized_local_wait_for_graph(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deadlock_monitor_state_transition(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.degree_of_parallelism(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deprecation_announcement(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.deprecation_final_support(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.disk_log_read(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.disk_log_read_ignore(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.dtc_transaction(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.error_reported(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.errorlog_written(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.exchange_spill(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.exec_prepared_sql(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.execution_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.existing_connection(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.expression_compile_stop_batch_processing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.extent_activation_cache_overflow(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.failed_hresult(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.failed_hresult_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fastloadcontext_enabled(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.file_read(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.file_read_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.file_write_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.file_written(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.file_written_to_replica(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_io_dump(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_io_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_io_request(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_io_response(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_io_trace(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.filestream_file_write_completion(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.flush_file_buffers(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.full_text_crawl_started(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.full_text_crawl_stopped(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.full_update_instead_of_partial_update(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_query_exec_stats(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_query_recompile(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_reorganize_phase1_destination_fragment(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_reorganize_phase1_source_fragment(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_reorganize_progress(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_reorganize_source_fragment(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_reorganize_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.fulltext_semantic_document_language(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ghost_cleanup(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.group_commit_value_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ag_config_data_mutex_acquisition_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ag_database_api_call(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ag_lease_renewal(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ag_wsfc_resource_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_apply_log_block(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_apply_vlfheader(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ar_api_call(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ar_critical_section_entry_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ar_manager_mutex_acquisition_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ar_manager_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_capture_compressed_log_cache(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_capture_log_block(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_capture_vlfheader(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_database_flow_control_action(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_database_replica_disjoin_completion(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_commit_mgr_harden(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_commit_mgr_harden_still_waiting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_commit_mgr_set_policy(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_commit_mgr_update_harden(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_backup_info_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_backup_sync_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_db_queue_restart(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_db_restart(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_db_shutdown(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_db_startdb(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_establish_db_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_filemetadata_request(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_lsn_sync_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_page_request(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_redo(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_redo_control(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_scan_control(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_status_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_suspend_resume(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_undo(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_manager_user_control(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_partner_set_policy(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_db_partner_set_sync_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_ddl_failover_execution_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_dump_log_block(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_dump_log_progress(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_dump_primary_progress(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_dump_sync_primary_progress(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_dump_vlf_header(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_evaluate_readonly_routing_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_corrupt_message(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_directory_create(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_file_close(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_file_flush(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_file_open(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_file_set_eof(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_log_interpreter(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_message_block_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_message_dir_create(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_message_file_request(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_message_file_write(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_processed_block(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_filestream_undo_inplace_update(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_online_availability_group_first_attempt_failure(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_online_availability_group_retry_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_scan_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_sql_instance_to_node_map_entry_deleted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_thread_pool_worker_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_transport_dump_config_message(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_transport_dump_message(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_transport_flow_control_action(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_transport_session_state(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_transport_ucs_connection_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_undo_of_redo_log_scan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_worker_pool_task(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_worker_pool_thread(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_wsfc_change_notifier_node_not_online(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_wsfc_change_notifier_severe_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_wsfc_change_notifier_start_ag_specific_notifications(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_wsfc_change_notifier_status(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_xrf_copyXrf_partialCopy(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_xrf_deleteAllXrf_beforeEntry(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_xrf_deleteRecLsn_beforeEntry(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_xrf_updateXrf_before_recoveryLsn_update(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hadr_xrf_updateXrf_partialUpdate(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hash_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hekaton_slow_param_passing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_allocation_unit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_column(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_factory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_hobt(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_hobt_attributes(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.hobt_schema_mgr_hobt_page(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.host_task_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.inaccurate_cardinality_estimate(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.index_build_extents_allocation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ioaff_node_summary(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ioaff_scan_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ioaff_scan_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ioaff_scan_worker_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ioaff_scan_worker_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_acquire_time(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_demoted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_promoted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_suspend_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_suspend_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.latch_suspend_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.leaf_page_disfavored(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_acquired(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_cancel(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_deadlock(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_deadlock_chain(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_escalation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_redo_blocked(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_redo_unblocked(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_released(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_timeout(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.lock_timeout_greater_than_0(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.locks_lock_waits(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_block_cache(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_block_consume(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_block_move(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_block_persistence_reset(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_blocks_uncache(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_buffer_allocated(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_buffer_freed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_cache_buffer_refcounter_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_consumer_act(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_consumer_life(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_consumer_read_ahead(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_flush_complete(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_flush_requested(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_flush_retry(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_flush_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_generate_stall(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_pool_memory_status(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.log_single_record(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.login(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logout(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_add_compensation_range(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_add_eor(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_add_tran_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_apply_filter_proc(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_process_filestream_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_process_text_info(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_process_text_ptr(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.logreader_start_scan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.long_io_detected(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_database_cache_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_free_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_reserved_server_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_stolen_server_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_target_server_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_manager_total_server_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_database_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_foreign_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_free_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_stolen_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_target_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.memory_node_total_node_memory(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.metadata_persist_last_value_for_sequence(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.missing_column_statistics(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.missing_join_predicate(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.module_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.module_start(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.new_log_interest_flip(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.object_altered(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.object_created(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.object_deleted(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oiblob_cleanup_begin(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oiblob_cleanup_end(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oledb_call(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oledb_data_read(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oledb_error(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oledb_provider_information(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.oledb_query_interface(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.optimizer_timeout(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.packet_enqueued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.page_compression_attempt_failed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.page_compression_tracing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.page_reference_tracker(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.page_split(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.perfobject_logicaldisk(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.perfobject_process(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.perfobject_processor(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.perfobject_system(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.physical_page_read(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.physical_page_write(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.plan_affecting_convert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.plan_cache_cache_attempt(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.plan_cache_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.plan_guide_successful(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.plan_guide_unsuccessful(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.preconnect_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.preconnect_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.prefetch_extent(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.prelogin_traceid(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.prepare_sql(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.process_invalidate_cache_logrec(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.progress_report_online_index_operation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.promote_tran_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.promote_tran_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.qn_dynamics(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.qn_parameter_table(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.qn_subscription(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.qn_template(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_cache_removal_statistics(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_no_cqscan_cache_due_to_memory_limitation(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_post_compilation_showplan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_post_execution_showplan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_pre_execution_showplan(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_close(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_create_accessor(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_create_col_accessor(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_delete_rows(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_end_update(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_fetch_next_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_fetch_row_by_key_value(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_get_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_go_dormant(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_insert_index_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_insert_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_locate_and_delete_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_locate_and_update_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_locate_or_insert_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_delete_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_fetch_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_get_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_goto_marker(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_insert_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_prepare_to_delete(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_set_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_set_marker(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_set_range(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_set_range_with_cached_keys(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_cmd_wake_up(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_prepare_to_delete(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_delete_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_fetch_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_get_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_goto_marker(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_insert_row(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_lob_action(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_prepare_to_delete(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_set_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_set_marker(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_process_cmd_set_range(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_release_accessor(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_cache_flush(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_cache_hit_no_key(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_cache_insert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_cache_miss(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_cache_remove(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_collection_create(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_cache_insert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_cache_miss(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_cache_remove(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_create(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_init(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_server_runtime_wake_up(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_set_cardinality(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_set_data(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_set_range(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_switch_partition(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.query_rpc_wake_up(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.read_only_route_complete(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.read_only_route_fail(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_catch_checkpoint(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_force_oldest_page(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_incremental_checkpoint(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_simple_log_truncate(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_skip_checkpoint(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_target_miss(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.recovery_target_reset(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_caught_up(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_single_record(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_stop_clear(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_stop_set(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_target_set(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_worker_entry(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.redo_worker_exit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.repl_event(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rollback_tran_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rollback_tran_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rpc_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.rpc_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.save_tran_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.save_tran_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.scan_started(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.scan_stopped(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sec_ekm_provider_called(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_authentication_perf_create_logintoken(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_authentication_perf_find_login(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_authentication_perf_login(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_cache_database_cleanup(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_cache_database_object_insert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_cache_database_object_removal(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_cache_database_timestamp_increment(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.security_error_ring_buffer_recorded(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.selective_xml_index_no_compatible_sql_type(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.selective_xml_index_no_compatible_xsd_types(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.selective_xml_index_path_not_indexed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.selective_xml_index_path_not_supported(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.server_memory_change(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.server_start_stop(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.session_mgr_work_item_dequeued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.session_mgr_work_item_end_execution(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.session_mgr_work_item_enqueued(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.session_mgr_work_item_start_execution(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sort_add_run_tracing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sort_memory_grant_adjustment(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sort_state_change_tracing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sort_statistics_tracing(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sort_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_cache_hit(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_cache_insert(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_cache_miss(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_cache_remove(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_server_diagnostics_component_result(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_server_diagnostics_result_set(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_statement_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sp_statement_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.spatial_guess(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_batch_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_batch_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_exit_invoked(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_statement_completed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_statement_recompile(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_statement_starting(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.sql_transaction(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.stack_trace(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.syscommittab_cleanup(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.trace_flag_changed(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.trace_print(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.transaction_log(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.ual_instrument_called(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.uncached_sql_batch_statistics(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.unmatched_filtered_indexes(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.unprepare_sql(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.user_event(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.user_settable(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.window_spool_ondisk_warning(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.xml_deadlock_report(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT sqlserver.xquery_static_type(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_change_notification(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_corrupt_message(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_flow_control(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_recv_io(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_recv_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_send_io(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_send_msg(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_setup(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_connection_state_machine(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_task_idempotent(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_task_periodic_work(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_destination_connect(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_destination_event(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_destination_process(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_destination_service(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_periodic_work(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_reclassify(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_service_reclassify(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_service_session(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transmitter_stream_update(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)),
ADD EVENT ucs.ucs_transport_periodic_work(
    ACTION(package0.callstack,sqlserver.tsql_frame,sqlserver.tsql_stack)) 
ADD TARGET package0.ring_buffer(SET max_events_limit=(1000))
WITH (STARTUP_STATE=ON)
GO

ALTER EVENT SESSION [ApplicationXYZ] ON SERVER STATE=START;
GO
