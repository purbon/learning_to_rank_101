require "json"
require "elasticsearch"

module LTR
  class Loader

    def self.run(dir="data/books/dataset2/*.json")
      puts "loading #{dir}"
      client = ESClient.new
      Dir.glob(dir).each do |file|
        payload = File.read(file)
        content = JSON.parse(payload)
        begin
          content.delete("similars")
          client.append(content)
        rescue => e
          puts e
        end
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
     # track_id = doc['track_id']
      buffer.push({ index: { _index: "docs", _type: 'docs', data: doc } })
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

def alphabet
  (65..90).map { |d| d.chr }
end

if __FILE__ == $0
  #LTR::Loader.run("/Volumes/Seagate Backup Plus Drive/Datasets/lastfm/subset/*/*/*/*.json")
  #LTR::Loader.run("/Volumes/Seagate Backup Plus Drive/Datasets/lastfm/train/*/*/*/*.json")
  #LTR::Loader.run("/Volumes/Seagate Backup Plus Drive/Datasets/lastfm/test/*/*/*/*.json")

  base = "/Volumes/Seagate Backup Plus Drive/Datasets/lastfm/test"
  alphabet.each_slice(5).each do |slice|
    pool = slice.map do |triple|
      Thread.new do
        LTR::Loader.run("#{base}/#{triple}/*/*/*.json")
      end
    end
    pool.each do |p| p.join end
  end
end
