require 'ps/storage/base'

class Ps
  module Storage

    class Rubylist < Base

      def initialize
        super
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
        start_time = Time.now
        if rvs.kind_of?(Array)
          value = @data.count { |e| rvs.all? { |rv| e.has_key?(rv) } }
        elsif rvs.kind_of?(Hash)
          value = @data.count { |e| rvs.map { |rkey, rval| e[rkey] == rval }.all? }
        end
        elapsed = Time.now - start_time
        return value

        #if @stash.has_key?(rvs.to_s) and reload == false
        #  @stash_stats[:hits] += 1
        #  @stash_time[rvs.to_s][:usage] += 1
        #  return @stash[rvs.to_s]
        #else
        #  @stash_stats[:misses] += 1
        #  @stash_time[rvs.to_s] = { elapsed: elapsed, usage: 0 }
        #  return @stash[rvs.to_s] = value
        #end
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