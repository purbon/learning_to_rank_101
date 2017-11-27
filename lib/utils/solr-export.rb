require 'net/http'

module LTR
  class SolrExport

    def initialize

    end

    def get(id)
      puts "processing #{id}"
      url = "http://nemo-solrcloud.springer-sbm.com:8983/solr/nemo_smed_preview-2017-11-08-15_shard1_replica1/select?wt=json"
      url = url + "&q=id:(\"contentbean:#{id}\" )"
      uri = URI(url)
      Net::HTTP.get(uri)
    end
  end
end

if __FILE__ == $0
  export = LTR::SolrExport.new

  ids = File.read("data/books/ids2.log").split("\n").map { |id| id.strip.to_i }
  ids.each do |id|
    content = export.get(id)
    File.write("data/books/dataset2/dump-#{id}.json", content)
    sleep 1
  end
end
