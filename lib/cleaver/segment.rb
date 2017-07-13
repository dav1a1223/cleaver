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

    def cut
    end
  end
end

cs = Cleaver::Segment.new
binding.pry
