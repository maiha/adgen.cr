class Cmds::BatchCmd
  private def url_builder(name : String, bindings = Hash(String, String).new) : -> String
    # validate: check config:cmd exists, otherwise raises
    cmd = ParamsCmd.parse?(config.api_cmd?(name)) || raise "config:#{name}.cmd is nil"

    if !/\{TARGET_EMD_AT\}/.match(config.api_cmd?(name).to_s)
      bindings.delete("TARGET_EMD_AT")
    end
    
    # validate: cmd params
    cmd.params == bindings.keys ||
      raise ArgumentError.new("config: [%s].cmd should contain %s parameters, but got %s" % [name, bindings.keys.inspect, cmd.params.inspect])

    -> { cmd.resolve(bindings) }
  end
end
