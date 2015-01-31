require "redis"

class PSpace
  module Storage

    class Redis

      def initialize(data)
        @redis = Redis.new
      end

      def reset
        rand_vars.each do |rv|
          uniq_vals(rv) do |val|
            @redis.del "pspace:count:#{rv}=#{val}"
          end
          @redis.del "pspace:count:#{rv}"
          @redis.del "pspace:uniq_vals:#{rv}"
        end
        @redis.del "pspace:rand_vars"
      end

      def import(data)
      end

      def add(datum)
        datum.each do |rv, val|
          @redis.sadd "pspace:rand_vars", rv
          @redis.sadd "pspace:uniq_vals:#{rv}", val
          @redis.pfadd "pspace:count:#{attr}", datum.object_id
          @redis.pfadd "pspace:count:#{attr}=#{val}", datum.object_id
        end
      end

      def count(rvs, options = {})
        if rvs.kind_of?(Array)
          @redis.pfcount *rvs.map { |rv| "pspace:count:#{rv}" }
        elsif rvs.kind_of?(Hash)
          @redis.pfcount *rvs.map { |rv, val| "pspace:count:#{rv}=#{val}" }
        end
      end

      def rand_vars
        @redis.smembers "pspace:rand_vars"
      end

      def uniq_vals(rv)
        @redis.smembers "pspace:uniq_vals:#{rv}"
      end

    end

  end
end
