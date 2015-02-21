require 'prolly/rand_var/prob'
require 'prolly/rand_var/entropy'
require 'prolly/rand_var/infogain'

module Prolly

  class RandVar

    include Prob
    include Entropy
    include Infogain

    def initialize(pspace, *rand_vars)
      @pspace = pspace

      @uspec_rv, @spec_rv = parse(rand_vars)

      @uspec_gv = []
      @spec_gv = {}
    end

    # parses rand_var arguments
    #
    # random variable are passed in as arguments to a method. It can take the format of:
    #
    # :size
    #
    # { size: :large, color: :green }
    #
    # [ :size, { color: :green, texture: :rough } ]
    #
    def parse(rand_vars)
      if rand_vars.kind_of?(Hash)
        specified_rvs = rand_vars
        unspecified_rvs = []
      elsif rand_vars.kind_of?(Array)
        specified_rvs, unspecified_rvs = rand_vars.partition { |e| e.kind_of?(Hash) }
        specified_rvs = specified_rvs.inject({}) { |t, e| t.merge(e) }
      else # if it's a symbol
        specified_rvs = []
        unspecified_rvs = [rand_vars]
      end

      return unspecified_rvs, specified_rvs
    end

    def given(*rand_vars)
      @uspec_gv, @spec_gv = parse(rand_vars)

      return self
    end

    def count
      if !@spec_rv.empty?
        if @uspec_gv.empty? and @spec_gv.empty?
          @pspace.count(@spec_rv)
        else
          @pspace.count(@spec_rv.merge(@spec_gv))
        end
      else
        @pspace.count(@uspec_rv)
      end
    end

  end

end
