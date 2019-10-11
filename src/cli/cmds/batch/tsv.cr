class Cmds::BatchCmd
  var snap_columns : Array(Clickhouse::Column) = clickhouse_columns(["account_id String", "id String", "updated_time Datetime"])

  # - convert <TAB> to <SPACE>
  # - convert <BACKSLASH> to <BACKSLASH><BACKSLASH>
  def tsv_impl
    tsv_impl_adsvr_creative
  end

  def tsv_impl_adsvr_creative
    name  = "adsvr_creative"
    hint  = "[tsv] #{name}"
    sep   = '\t'
    quote = CSV::Builder::Quoting::NONE
    file  = "#{name}.tsv"
    path  = "#{today_dir}/tsv/#{file}"

    ads = house(Adgen::Proto::NativePureAd).load
    logger.info "#{hint} ad:%d, creatives:%d" % [ads.size, creative_count(ads)]

    sql = Bundled::SQL["adsvr_creative"]
    keys = Clickhouse::Schema::Create.parse(sql).columns.map(&.name)
    
    data = disk.measure {
      CSV.build(quoting: quote, separator: sep) do |csv|
        csv.row(keys)
        ads.each do |ad|
          creatives = ad.pure_ad_creatives || next
          budget    = ad.pure_ad_budget || Adgen::Proto::NativePureAdBudget.new
          creatives.each do |creative|
            vals = Array(String).new

            keys.each do |key|
              case key
              # [NativePureAd]
              when "publisher_id"
                vals << tsv_serialize(ad.publisher_id)
              when "adsvr_schedule_id"
                vals << tsv_serialize(ad.adsvr_schedule_id)
              when "adsvr_schedule_name"
                vals << tsv_serialize(ad.adsvr_schedule_name)

              # [NativePureAdCreative]
              # adsvr_creative_id   = 1 ; // 6877
              # adsvr_creative_name = 2 ; // "P-プレビューテスト(119)"
              # native_title        = 3 ; // "広告タイトル 必須"
              # native_sponsored    = 4 ; // "広告主名"
              # native_ctatext      = 5 ; // "CTAボタン"
              when "adsvr_creative_id"
                vals << tsv_serialize(creative.adsvr_creative_id)
              when "adsvr_creative_name"
                vals << tsv_serialize(creative.adsvr_creative_name)
              when "native_title"
                vals << tsv_serialize(creative.native_title)
              when "native_sponsored"
                vals << tsv_serialize(creative.native_sponsored)
              when "native_ctatext"
                vals << tsv_serialize(creative.native_ctatext)
              else
                raise "[BUG] #{hint} got unknown key: #{key.inspect}"
              end
            end
            csv.row(vals)
          end
        end
      end
    }
    Pretty::File.write(path, data)
    logger.info "[tsv] %s [%s]" % [file, disk.last]
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

  private def creative_count(ads) : Int32
    count = 0
    ads.each do |ad|
      creatives = ad.pure_ad_creatives || next
      count += creatives.size
    end
    return count
  end
end
