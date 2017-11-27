require "csv"
require "json"

#: 4	qid:1 #	7555	Rambo
#: 3	qid:1 #	1370	Rambo III
#: 3	qid:1 #	1369	Rambo: First Blood Part II
#: 3	qid:1 #	1368	First Blood
#: 0	qid:1 #	136278	Blood

module LTR
  class Judgements

    def self.normalize(file)
      queries = {}
      ids = {}
      CSV.open("data/books/judgement-norm.csv", "wb", { :col_sep => "\t" }) do |csv|
        CSV.foreach(file, { :headers => true, :col_sep => ";" }  ) do |row|
          (1..10).each do |id|
            query = row["SEARCHPHRASE"]
            queries[query] = queries.count+1 unless queries[query]
            rank = row["RELEVANCE_RANK_#{id}"].to_i
            next if rank < 0
            doc_id = row["DOC_ID_RANK_#{id}"]
            ids[doc_id] = doc_id unless ids[doc_id]
            csv << [ rank , "qid:#{queries[query]}" , "# #{doc_id}" ]
          end
        end
      end

      File.write("data/queries.json", queries.invert.to_json)
      File.open("data/ids.log", "wb") do |_file|
        ids.values.each do |id|
        _file.write("#{id}\n")
        end
      end
    end

  end
end

if __FILE__ == $0
  LTR::Judgements.normalize("data/books/judgement.list")
end
