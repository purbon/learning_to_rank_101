require "elasticsearch"
require "json"
require "csv"
require "net/http"

module LTR

  class Models


    attr_reader :client

    def initialize
    end

    def upload(model, name, type="model/ranklib")

      payload = {
        model: {
          name: name,
          model: {
              type: type,
              definition: model
          }
        }
      }

      uri = URI("http://localhost:9200/_ltr/_featureset/docs_features/_createmodel")


      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = payload.to_json
      request["Content-Type"] = "application/json"
      http.request(request)

    end

  end
end

if __FILE__ == $0
  eng = LTR::Models.new
  model = File.read(ARGV[0])
  eng.upload(model, ARGV[1])
end
