class Cmds::BatchCmd
  var tsv_sep   = '\t'
  var tsv_quote = CSV::Builder::Quoting::NONE
  
  # - convert <TAB> to <SPACE>
  # - convert <BACKSLASH> to <BACKSLASH><BACKSLASH>
  def tsv_impl
    tsv_impl_adsvr_creative
  end

  def tsv_impl_adsvr_creative
    hint  = "[tsv] adsvr_creative"
    file  = "adsvr_creative.tsv"
    path  = "#{today_dir}/tsv/#{file}"

    # touch output path for append
    Pretty::File.write(path, "")
    
    {% for klass in PUBLISHER_MODEL_CLASS_IDS %}
      {% name = klass.stringify.underscore %}
      if enabled?({{name}}) # "native_pure_ad", "native_house_ad"
        name = "adsvr_creative_" + native_shorten_name({{name}})

        # We create two kinds of TSV
        # 1) Data that exactly matches the API schema
        data = build_tsv_adsvr_creative_{{name.id}}(keys: tsv_keys_for(name))
        Pretty::File.write("#{today_dir}/tsv/#{name}.tsv", data)

        # 2) Abstract data that can represent all about adsvr_creative_xxx
        data = build_tsv_adsvr_creative_{{name.id}}(keys: tsv_keys_for("adsvr_creative"))
        File.open(path, "a+"){|f| f.print data}
      end
    {% end %}

    logger.info "[tsv] %s [%s]" % [file, disk.last]
  end

  private def build_tsv_adsvr_creative_native_pure_ad(keys)
    hint = "[tsv] native_pure_ad"
    ads = house(Adgen::Proto::NativePureAd).load
    logger.info "%s pure ads:%d, creatives:%d" % [hint, ads.size, ads.map(&.creatives.size).sum]

    return disk.measure {
      CSV.build(quoting: tsv_quote, separator: tsv_sep) do |csv|
        # NativePureAd
        ads.each do |ad|
          creatives = ad.pure_ad_creatives || next
          budget = ad.pure_ad_budget || Adgen::Proto::NativePureAdBudget.new

          creatives.each do |creative|
            vals = Array(String).new
            keys.each do |key|
              if key == "native_type"
                vals << "pure"
              elsif Adgen::Proto::NativePureAd::Fields[key]?
                vals << tsv_serialize(ad[key]?)
              elsif Adgen::Proto::NativePureAdBudget::Fields[key]?
                vals << tsv_serialize(budget[key]?)
              elsif Adgen::Proto::NativePureAdCreative::Fields[key]?
                vals << tsv_serialize(creative[key]?)
              else
                raise "[BUG] #{hint} got unknown key: #{key.inspect}"
              end
            end
            csv.row(vals)
          end
        end
      end
    }
  end

  private def build_tsv_adsvr_creative_native_house_ad(keys)
    hint = "[tsv] native_house_ad"
    ads = house(Adgen::Proto::NativeHouseAd).load
    logger.info "%s house ads:%d, creatives:%d" % [hint, ads.size, ads.map(&.creatives.size).sum]

    return disk.measure {
      CSV.build(quoting: tsv_quote, separator: tsv_sep) do |csv|
        # NativeHouseAd
        ads.each do |ad|
          creatives = ad.house_ad_creatives || next

          creatives.each do |creative|
            vals = Array(String).new
            keys.each do |key|
              if key == "native_type"
                vals << "house"
              elsif Adgen::Proto::NativeHouseAd::Fields[key]?
                vals << tsv_serialize(ad[key]?)
              elsif Adgen::Proto::NativeHouseAdCreative::Fields[key]?
                vals << tsv_serialize(creative[key]?)
              else
                # NativeHouseAd lacks some fields
                vals << tsv_serialize(nil)
              end
            end
            csv.row(vals)
          end
        end
      end
    }
  end

  private def tsv_keys_for(name : String) : Array(String)
    sql = Bundled::SQL[name]? || raise NotImplementedError.new("[BUG] no sql schema for '#{name}'")
    Clickhouse::Schema::Create.parse(sql).columns.map(&.name)
  end 

  private def tsv_serialize(v) : String
    # Nullable
    return "\\N" if v.nil?

    # convert TAB and RET to spaces
    v = v.to_s.gsub('\t', ' ').gsub('\n', ' ')
    # escape backslashes
    v = escape_backslashes(v)

    return v
  end

  # backslash string in macro fails
  # see https://github.com/crystal-lang/crystal/issues/8064
  private def escape_backslashes(v)
    v.gsub('\\', "\\\\")
  end
end
