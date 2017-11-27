require "elasticsearch"
require "json"
require "csv"
require "net/http"

module LTR

  class FeatureEngineering


    attr_reader :client, :base_url

    def initialize
      @base_url = "http://localhost:9200"
    end

    def init_features_store(src="def-features.json")
      payload = JSON.parse(File.read(src))
      uri = URI("#{base_url}/_ltr/_featureset/docs_features")
      puts do_request(uri, payload).body
    end

    def add_feature(name, field)
      payload = {
        features: [
          name: name,
          params: [],
          template_language: "mustache",
          template: {
          function_score: {
            query: { match_all: {} },
            script_score: {
              script: {
                source: "System.currentTimeMillis() - doc['#{field}'].date.getMillis()"
              }
            }
          }
        }
        ]
      }

      uri = URI("#{base_url}/_ltr/_featureset/docs_features/_addfeatures")
      puts do_request(uri, payload).body
    end

    private

    def do_request(uri, payload)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = payload.to_json
      request["Content-Type"] = "application/json"
      http.request(request)
    end

  end
end

if __FILE__ == $0
  eng = LTR::FeatureEngineering.new
  eng.init_features_store("def-features-music.json")
  #eng.add_feature("6", "freshness")
  #eng.add_feature("7", "publicationdate")
end
