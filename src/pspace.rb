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

    def uniq_vals(rv_name)
      @ps.uniq_vals(rv_name)
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
      @stash["#{name}=#{val}"] ||= @data.count { |e| e.has_key?(name) }
    else
      @stash["#{name}=#{val}"] ||= @data.count { |e| e[name] == val }
    end
  end

  # gvs = Hash of specified given variables
  def count2(name, val, spec_gv)
    @stash["#{name}=#{val} #{spec_gv.to_s}"] ||= @data.count { |e|
      e[name] == val and spec_gv.map { |gname, gval| e[gname] == gval }.all?
    }
  end

  def uniq_vals(name)
    @uniq_vals[name] ||= @data.map { |li| li.has_key?(name) ? li[name] : nil }.uniq
  end

  def rand_vars
    @data.first.keys
  end

end


