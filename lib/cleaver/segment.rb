require "pry"
require "matrix"
require_relative "../../models/default_model"

module Cleaver
  class Segment
    include Model
    def initialize
      @tprior_count = TPRIOR_COUNT
      @tseq_count = TSEQ_COUNT
      @ct_count = CT_COUNT
    end

    def cut(sent)
      splited_sent = sent.split("")
      moving_priors = @tprior_count.column(0).to_a
      tags_table = Matrix.empty(0, 4)
      last_predict_index = 0
      output = []

      splited_sent.each_with_index do |word, i|
        pre_prior = @ct_count.row(word.ord) + Vector[*moving_priors]
        if i == (splited_sent.length - 1)
          last_predict_index = pre_prior.each_with_index.max[1]
          next
        end

        pre_prior_matrix = Matrix.build(4, 4) { |r, c| pre_prior[r] }
        pre_prior_matrix = pre_prior_matrix + @tseq_count
        predict_tags = []

        (0..3).each do |ii|
          moving_priors[ii], max_value_index = pre_prior_matrix.column(ii).each_with_index.max
          predict_tags << tag_predict(max_value_index)
        end
        tags_table = Matrix.rows(tags_table.to_a << predict_tags)
      end

      # back trace
      sent_tags = [tag_predict(last_predict_index)]
      this_tag_index = last_predict_index

      (0..(tags_table.row_count-1)).reverse_each do |i|
        this_tag = tags_table[i, this_tag_index]
        this_tag_index = tag_to_num(this_tag)
        sent_tags.insert(0, this_tag)
      end

      # use tags to split sentence
      sent_tags.each_with_index do |tag, i|
        if (tag == "S" || tag == "B") || i == 0
          output << splited_sent[i]
        else
          output[-1] += splited_sent[i]
        end
      end
      output
    end

    def tag_predict(tag_index)
      if tag_index == 0
        "S"
      elsif tag_index == 1
        "B"
      elsif tag_index == 2
        "M"
      elsif tag_index == 3
        "E"
      end
    end

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

cs = Cleaver::Segment.new
cs.cut("紀惠容舉例")
