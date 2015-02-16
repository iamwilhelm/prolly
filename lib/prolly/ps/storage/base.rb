
module Prolly
  class Ps
    module Storage

      class Base

        def initialize
        end

        def reset
          @stash ||= {}
          @stash_stats ||= { hits: 0, misses: 0 }
          @stash_time ||= {}
        end

        def import(data)
          data.each { |datum| add(datum) }
        end

        def add(datum)
          raise StandardError.new("not implemented")
        end

        def count(rvs, options = {})
          raise StandardError.new("not implemented")
        end

        def rand_vars
        end

        def uniq_vals(name)
        end

      end

    end
  end
end

