
require 'prolly'
#require 'ruby-prof'

include Prolly

module DecisionTree
  class << self
    def load(cols, filepath)
      File.open(filepath, 'r') do |f|
        f.each_line do |line|
          next if line.chomp.empty?
          yield Hash[*cols.zip(line.chomp.split(/,\s*/)).flatten]
        end
      end
    end
  end

  class Machine
    attr_reader :tree

    def initialize
      @tree = nil
    end

    def load(data_set)
      data_set.each { |datum|
        add(datum)
      }
    end

    def add(example)
      ::Ps.add(example)
    end

    def split_rv(rv)
      if rv.class == Hash
        rkey = rv.keys.first
        rval = rv[rkey]
      else
        rkey = rv
        rval = nil
      end
      return rkey, rval
    end

    def putss(rvs, str)
      space = @rv_size - rvs.size
      puts (" " * (space) * 4) + str
    end

    def classify(datum)
      classify_helper(@tree, datum)
      # recursively traverse down the tree and figure out the decision.
      #classify_helper(....?)
    end

    # recursive.
    def classify_helper(node, datum)
      if node.kind_of?(Hash)
        max_result = node.max { |a, b| a[1] <=> b[1] }
        return max_result[0]
      else
        # puts "node: #{node}"
        unless datum.has_key?(node.name)
          raise "Missing column #{node.name} in datum"
        end

        unless node.children.has_key?([datum[node.name]])
          return nil
        end

        # puts datum[node.name]
        return classify_helper(node.children[[datum[node.name]]], datum)
      end
    end

    def learn(rv_target, &block)
      #RubyProf.start

      tkey, tval = split_rv(rv_target)
      rvs = ::Ps.rv.reject { |rv| rv == tkey }
      rvs.reject! do |key|
        !block.call(key)
      end
      @rv_size = rvs.size

      @tree = create_node(rv_target, {}, rvs, &block)

      #result = RubyProf.stop
      #printer = RubyProf::MultiPrinter.new(result)
      #printer.print(:path => "./profile", :profile => "profile", :min_percent => 2)
    end

    # rv_target - the variable we're trying to learn
    # rv_parents - hash of past decisions in branch
    # rand_vars - remaining rand_vars to decide on
    # block - for filtering which key to use
    def create_node(rv_target, rv_parents, rand_vars, &block)
      tkey, tval = split_rv(rv_target)
      #pkey, pval = split_rv(rv_parent)

      # calculate all gains for remaining rand vars
      gains = rand_vars.map do |key|
        ig = ::Ps.rv(tkey).given(key, rv_parents).infogain
        putss rand_vars, "#{tkey} | #{key}, #{rv_parents} = #{ig}"
        [ key, ig ]
      end
      putss rand_vars, "Gains: #{gains.to_s}"

      # find the next RV
      # use the rkey and remove it from list of candidate rand_vars
      rkey, _ = gains.max { |a, b|
        if a[1].nan? and b[1].nan?
          0
        elsif a[1].nan?
          -1
        elsif b[1].nan?
          1
        else
          a[1] <=> b[1]
        end
      }
      gains.delete_if { |ig| ig[0] == rkey }
      new_rand_vars = gains.map { |g| g[0] }

      # create node to attach to parent node
      putss rand_vars, "Using :#{rkey} for node with parents #{rv_parents} to create node"
      node = Node.new(rkey)

      # create a child node for every value of selected rkey
      ::Ps.uniq_vals([rkey]).each do |rval|
        rval_str = rval.first
        new_rv_parents = rv_parents.clone.merge(rkey => rval_str)

        putss rand_vars, "P(#{tkey} | #{new_rv_parents}) ="
        prob_distr = ::Ps.rv(tkey).given(new_rv_parents).pdf
        putss rand_vars, "-- #{prob_distr}"

        ## base case 0
        #if gains.empty?
        #  putss rand_vars, "Base Case 0 #{rkey}: no more rvs"
        #  node.add(rval_str, prob_distr)
        #  next
        #end

        # base case 2
        if gains.all? { |ig| ig[1] == 0.0 }
          putss rand_vars, gains.inspect
          putss rand_vars, "Base Case 2 #{rkey}: Gains all zero"
          node.add(rval, prob_distr)
          next
        end

        # base case 1
        ent = ::Ps.rv(tkey).given(new_rv_parents).entropy
        putss rand_vars, "H(#{tkey} | #{new_rv_parents}) ="
        putss rand_vars, "-- #{ent}"
        if ent == 0.0
          putss rand_vars, "Base Case 1 #{rkey}: H(#{tkey} | #{new_rv_parents}) = 0"
          node.add(rval, prob_distr)
          next
        end

        putss rand_vars, "Creating child node for #{rkey} = #{rval}"
        child_node = create_node(rv_target, new_rv_parents, new_rand_vars, &block)
        node.add(rval, child_node)
      end

      puts

      return node
    end
  end

  class Node
    attr_accessor :name
    attr_reader :children

    def initialize(name = nil)
      @name = name
      @children = {}
    end

    def add(val, node)
      return if node.nil?
      @children[val] = node
    end

    def inspect
      result = "{ "
      result += %Q{"name": "#{@name}", }
      result += %Q{"children":  \{}
      @children.each do |child_name, child_node|
        result += %Q{"#{child_name}"}
        result += " => "
        result += child_node.inspect
        result += ", "
      end
      result += " }"
      result += " }"
    end

  end

end


