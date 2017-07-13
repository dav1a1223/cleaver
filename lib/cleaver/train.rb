require "csv"
require "matrix"
require "pry"

module Cleaver
  class HMM
    def initialize(csv_file_path)
      @csv_file_path = csv_file_path
    end

    def train
      tprior_count = Matrix.build(4, 1) { 0 }
      tseq_count = Matrix.build(4, 4) { 0 }
      ct_count = Matrix.build(70000, 4) { 0 }
      counter = 0

      CSV.foreach(@csv_file_path) do |row|
        sent = row[2]
        bmes_tags = row[4]

        splited_tags = bmes_tags.split("")
        splited_sent = sent.split("")

        # count tprior
        splited_tags.each do |tag|
          index = tag_to_num(tag)
          tprior_count[index, 0] = tprior_count[index, 0] + 1
        end

        # count tseq
        splited_tags.each_with_index do |tag, i|
          if i + 1 == splited_tags.length
            break;
          end
          tseq_count[tag_to_num(tag), tag_to_num(splited_tags[i+1])] = tseq_count[tag_to_num(tag), tag_to_num(splited_tags[i+1])] + 1
        end

        # count ct
        splited_sent.each_with_index do |word, i|
          index = word.ord
          tag_index = tag_to_num(splited_tags[i])
          ct_count[index, tag_index] = ct_count[index, tag_index] + 1
        end

        counter += 1
        if counter == 100
          binding.pry
        end
      end
    end

    private

    def tag_to_num(tag)
      if tag == "S"
        0
      elsif tag == "B"
        1
      elsif tag == "M"
        2
      elsif tag == "E"
        3
      end
    end
  end
end

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

Cleaver::HMM.new("train_sent.csv").train
