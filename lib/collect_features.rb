require "elasticsearch"
require "json"
require "csv"

module LTR

  class FeatureEngineering


    attr_reader :client

    def initialize
      @client = Elasticsearch::Client.new log: false
    end

    def collect(terms, ids=[])
      sltr_query = {
        _name: "logged_featureset",
        featureset: "docs_features",
        params: {
          keywords: terms
        }
      }
      ids_filter = {
        query_string: {
          default_field: "track_id",
          query: ids.join(" or ")
        }
      }
      features_query = JSON.parse(File.read("join-features.json"))
      features_query["query"]["bool"]["filter"] << ids_filter
      features_query["query"]["bool"]["filter"] << { sltr: sltr_query }

      puts features_query.to_json, "---"

      docs = client.search index: 'docs', body: features_query.to_json
      docs["hits"]["hits"].map do |hit|
        [hit["_source"]["track_id"]]  + hit["fields"]["_ltrlog"][0]["log_entry1"].map { |e| "#{e['name']}:#{e['value']}" }
      end.group_by { |d| d[0].split(":").last  }
    end

  end
end

if __FILE__ == $0

  src_dir = ARGV[0]
  eng = LTR::FeatureEngineering.new
  queries = JSON.parse(File.read("#{src_dir}/queries.json"))
  list = CSV.read("#{src_dir}/judgement-norm.csv", { :col_sep => ";" }).group_by { |e| e[1] }
  CSV.open("#{src_dir}/judgements-with-features.log", "wb", { :col_sep => "\t" }) do |csv|

    # id => "contentbean:#{id.strip.to_i}"
    queries.each do |id, terms|
      ids = list["qid:#{id}"].map { |record| record.last[2..-1] }.map { |id| "#{id.strip}"  }
      puts ids.count
      ids.each_slice(10).each do |bucket|
        puts bucket.count
        docs = eng.collect(terms, bucket)
        puts docs.count
        list["qid:#{id}"].each do |e|
          _id = e[2][2..-1]
          next unless docs[_id]
          csv << ( e[0,2]+docs[_id].flatten[1..-1]+["# #{_id} #{terms}"])
        end
      end
    end
  end
end
