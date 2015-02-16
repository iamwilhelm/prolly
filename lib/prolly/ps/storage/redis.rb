require "redis"

require 'prolly/ps/storage/base'

module Prolly
  class Ps
    module Storage

      class Redis

        def initialize(data)
          @redis = ::Redis.new(host: "localhost", port: "6379")
          reset
          import(data) unless data.nil?
        end

        def reset
          @redis.keys("pspace:*").each { |k| @redis.del k }
        end

        def import(data)
          data.each { |datum| add(datum) }
        end

        def add(datum)
          datum.each do |rv, val|
            @redis.sadd "pspace:rand_vars", rv
            @redis.sadd "pspace:uniq_vals:#{rv}", val

            @redis.PFADD "pspace:count:#{rv}", datum.object_id.to_i
            @redis.PFADD "pspace:count:#{rv}=#{val}", datum.object_id.to_i

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
end
