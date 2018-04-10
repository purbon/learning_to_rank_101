require "json"
require "elasticsearch"

module LTR

  class ESClient

    attr_reader :buffer

    def initialize
      @client = Elasticsearch::Client.new(log: false, hosts:["localhost:9200"])
      @buffer = []
      @index
    end

    def search(terms)
      @client.search q: terms.join(' '), size: 2000
    end

    def close
    end

  end

end

if __FILE__ == $0

  client = LTR::ESClient.new

  data = client.search ['thriller', 'police', 'berlin']

  File.open("dump.json", 'w') { |file| file.write(data["hits"].to_json) }

end
