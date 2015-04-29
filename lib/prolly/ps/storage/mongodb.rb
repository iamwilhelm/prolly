require 'date'
require 'moped'

require 'prolly/ps/storage/base'

module Prolly
  class Ps
    module Storage

      class Mongodb < Base

        attr_reader :session

        def initialize
          @session ||= Moped::Session.new(["127.0.0.1:27017", "127.0.0.1:27018"])
          @session.use 'pspace'

          super
          @rand_vars = []
        end

        def reset
          super
          @session['samples'].drop
        end

        def add(datum)
          # create an index for each new datum key
          #new_rvs(datum).each do |rv|
          #  @session.indexes.create(rv.to_sym => 1)
          #end

          record_new_rand_vars(datum)

          @session[:samples].insert(datum)
        end

        def count(rvs, options = {})
          reload = options["reload"] || false
          if rvs.kind_of?(Array)
            @session[:samples].find(
              Hash[*rvs.flat_map { |rv| [rv, { '$exists' => true }] }]
            ).count
          elsif rvs.kind_of?(Hash)
            @session[:samples].find(to_query_hash(rvs)).count
          end
        end

        def rand_vars
          @session[:rand_vars].find.map { |rv| rv[:name] }
        end

        def uniq_vals(name)
          @session[:samples].aggregate([
            { "$match" => { name.to_sym => { "$exists" => true } } },
            { "$group" => { "_id" => "$#{name}" } }
          ]).map { |e| e["_id"] }
        end

        private

        def new_rvs(datum)
          return datum.keys - rand_vars 
        end

        def record_new_rand_vars(datum)
          new_rvs(datum).each do |rv|
            @session[:rand_vars].insert({ name: rv })
          end
        end

        def to_query_hash(rvs)
          Hash[*rvs.flat_map { |k, v|
            [k, v.kind_of?(Array) ? { "$in" => v } : v]
          }]
        end

      end

    end
  end
end
