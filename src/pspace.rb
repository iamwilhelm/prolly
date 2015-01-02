require "rand_var"

class PSpace

  class << self
    def import(data)
      @ps = PSpace.new(data)
    end

    def add(datum)
      @ps ||= PSpace.new([])
      @ps.add(datum)
    end

    def rv(*rand_vars)
      if rand_vars.empty?
        @ps.rand_vars
      else
        RandVar.new(@ps, *rand_vars)
      end
    end

    def stash
      @ps.stash
    end

    def uniq_vals(name)
      @ps.uniq_vals(name)
    end
  end

  def initialize(data)
    @data = data
    @uniq_vals = {}
    @stash ||= {}
  end

  def stash
    @stash
  end

  def add(datum)
    @data << datum
  end

  def count(name, val)
    if val.nil?
      @stash["#{name}|#{val}"] ||= @data.count { |e| e.has_key?(name) }
    else
      @stash["#{name}|#{val}"] ||= @data.count { |e| e[name] == val }
    end
  end

  def count2(name1, val1, name2, val2)
    @stash["#{name1}|#{val1} #{name2}|#{val2}"] ||= @data.count { |e|
      e[name1] == val1 and e[name2] == val2
    }
  end

  def uniq_vals(name)
    @uniq_vals[name] ||= @data.map { |li| li.has_key?(name) ? li[name] : nil }.uniq
  end

  def rand_vars
    @data.first.keys
  end

end


