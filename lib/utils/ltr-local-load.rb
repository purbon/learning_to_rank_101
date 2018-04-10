require "json"
require "elasticsearch"

module LTR
  class Loader

    def self.run(file)
      puts "loading #{file}"
      client = ESClient.new
      payload = File.read(file)
      content = JSON.parse(payload)
      content['hits'].each do |hit|
        client.append(hit)
      end
      client.close
    end
  end

  class ESClient

    attr_reader :buffer

    def initialize
      @client = Elasticsearch::Client.new(log: false, hosts:["localhost:9200"])
      @buffer = []
      @index
    end

    def append(doc)
      buffer.push({ index: { _index: "docs2", _type: 'docs2', data: doc['_source'] } })
      if buffer.count > 1000
        flush
      end
    end

    def flush
      puts "buffer.count #{@buffer.count}"
      @client.bulk(body: buffer) unless buffer.empty?
      @buffer.clear
      #puts "buffer.count #{@buffer.count}"
    end

    def close
      flush
    end

  end

end

if __FILE__ == $0
  LTR::Loader.run("dump.json")
end
