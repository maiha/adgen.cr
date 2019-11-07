class Cmds::BatchCmd
  private macro import_clickhouse_tsv(proto)
    if enabled?({{proto}})
      _tbl_  = Pretty.underscore("{{proto}}".split(/::/).last)
      _path_ = File.join(today_dir, "tsv", "#{_tbl_}.tsv")
      import_clickhouse_tsv_impl(_tbl_, _path_)
    end
  end

  private def import_clickhouse_tsv
    import_clickhouse_tsv_impl("adsvr_creative")

    {% for klass in PUBLISHER_MODEL_CLASS_IDS %}
      {% name = klass.stringify.underscore %}
      if enabled?({{name}}) # "native_pure_ad", "native_house_ad"
        name = "adsvr_creative_" + native_shorten_name({{name}})
        import_clickhouse_tsv_impl(name)
      end
    {% end %}
  end

  private def import_clickhouse_tsv_impl(table, path = nil)
    path ||= "#{today_dir}/tsv/#{table}.tsv"

    shell = Shell::Seq.new
    shell.dryrun = config.dryrun?

    db.measure {
      shell.run("#{PROGRAM_NAME} clickhouse replace #{table} #{path}")
    }

    if shell.dryrun?
      STDOUT.puts shell.manifest
    else
      unless shell.success?
        msg = "FAIL: %s\n%s" % [shell.last.cmd, shell.stderr]
        abort msg
      end
      logger.info "[clickhouse] (tsv) %s [%s]" % [table, db.last]
    end
  end
  
end
