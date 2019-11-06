Cmds.command "batch" do
  # [Task]
  #   clean
  task clean, "<date>" do
    Pretty.rm_rf(today_dir)
    logger.info "Deleted #{today_dir}"
  end
  
  usage "run 2017-11-13"
  # [Task]
  #   run
  # [Responsibility]
  #   meta task of all tasks
  # [Input]
  #   See each task
  # [Output]
  #   See each task
  task "run", "<date>" do
    invoke_task("recv")
    invoke_task("db")
  end

  # [Task]
  #   recv
  # [Responsibility]
  #   receive all data as json from Adgen by invoking api
  # [Input]
  #   API:
  # [Output]
  #   FILE: Adgen::Proto::*/
  task "recv", "<date>" do
    recv_impl

    update_status "[recv:done] API:#{api} MEM:#{Pretty.process_info.max}", logger: "INFO"

  rescue err
    update_status "[recv] #{err.to_s}", logger: "FATAL"
    raise err
  end

  task "db", "<date>" do
    invoke_task("tsv")
    invoke_task("clickhouse")
  end

  task "tsv", "<date>" do
    tsv_impl
  end  

  task "clickhouse" do
    invoke_task("clickhouse_import")

    update_status "[clickhouse:done] DB:#{db} MEM:#{Pretty.process_info.max}", logger: "INFO"
  end

  task "clickhouse_import" do
    import_clickhouse_tsv
  end
  
  task "gc" do
    return if !config.batch_gc?

    gc_storage HttpCall
    gc_tsv

    update_status "[gc:done] DISK:#{disk} MEM:#{Pretty.process_info.max}", logger: "INFO"
  end
end

require "./batch/*"
