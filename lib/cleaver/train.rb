require "csv"
require "matrix"
require "pry"

module Cleaver
  class HMM
    def initialize(csv_file_path, options = {})
      @csv_file_path = csv_file_path
      @options = options
    end

    def train
      @tprior_count = Matrix.build(4, 1) { 0 }
      @tseq_count = Matrix.build(4, 4) { 0 }
      @ct_count = Matrix.build(70000, 4) { 0 }
      counter = 0

      CSV.foreach(@csv_file_path) do |row|
        sent = row[2]
        bmes_tags = row[4]

        splited_tags = bmes_tags.split("")
        splited_sent = sent.split("")

        splited_sent.each_with_index do |word, i|
          tag = splited_tags[i]
          tag_index = tag_to_num(tag)
          word_index = word.ord

          # count tprior
          @tprior_count[tag_index, 0] = @tprior_count[tag_index, 0] + 1

          # count tseq
          if i+1 != splited_tags.length
            next_tag_index = tag_to_num(splited_tags[i+1])
            @tseq_count[tag_index, next_tag_index] = @tseq_count[tag_index, next_tag_index] + 1
          end

          # count ct
          @ct_count[word_index, tag_index] = @ct_count[word_index, tag_index] + 1
        end
      end
      save_model
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

    def save_model
      output_path = @options[:output_path] || "models/"

      File.open(output_path + "tprior_count", "w") do |file|
        file.write(@tprior_count)
      end

      File.open(output_path + "tseq_count", "w") do |file|
        file.write(@tseq_count)
      end

      File.open(output_path + "ct_count", "w") do |file|
        file.write(@ct_count)
      end
    end
  end
end

class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end

Cleaver::HMM.new("lib/cleaver/train_sent.csv").train
