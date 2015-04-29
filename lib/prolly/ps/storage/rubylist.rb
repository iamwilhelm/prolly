require 'prolly/ps/storage/base'

module Prolly
  class Ps
    module Storage

      class Rubylist < Base

        def initialize
          reset
        end

        def reset
          super
          @data = []
          @uniq_vals = {}
        end

        def add(datum)
          @data << datum
        end

        def count(rvs, options = {})
          reload = options[:reload] || false
          if rvs.kind_of?(Array)
            value = @data.count { |e| rvs.all? { |rv| e.has_key?(rv) } }
          elsif rvs.kind_of?(Hash)
            value = @data.count { |e|
              rvs.map { |rkey, rval|
                vals = rval.kind_of?(Array) ? rval : [rval]
                vals.include?(e[rkey])
              }.all?
            }
          end
          return value
        end

        def rand_vars
          @data.first.keys
        end

        def uniq_vals(name)
          @uniq_vals[name] ||= @data.map { |li| li.has_key?(name) ? li[name] : nil }.uniq
        end

        private

        def explain(rvs, options = {})
        end

        def stats(options = {})
        end

        def display_stats
          require 'pp'
          puts "------------- Stats! --------------------"
          puts
          pp @stash_time.sort { |a, b| b[1][:usage] <=> a[1][:usage] }[0..10]
          puts 
          pp @stash_time.sort { |a, b| b[1][:elapsed] <=> a[1][:elapsed] }[0..10]
          puts
          puts @stash_stats.inspect
          puts
        end

      end

    end
  end
end
