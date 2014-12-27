class PSpace

  class << self
    def import(data)
      @ps = PSpace.new(data)
    end

    def rv(rand_vars)
      RandVar.new(@ps, rand_vars)
    end
  end

  def initialize(data)
    @data = data
  end

  def count(name, val)
    if val.nil?
      @data.count { |e| e.has_key?(name) }
    else
      @data.count { |e| e[name] == val }
    end
  end

  def count2(name1, val1, name2, val2)
    @data.count { |e| e[name1] == val1 and e[name2] == val2 }
  end

  def uniq_vals(name)
    @data.map { |li| li.has_key?(name) ? li[name] : nil }.uniq
  end

end

class RandVar

  def initialize(pspace, rand_vars)
    @pspace = pspace
    @rv = rand_vars
    @gv = []
  end

  def given(rand_vars)
    @gv = rand_vars
    return self
  end

  def count
    if @rv.class == Hash
      # FIXME need to support multiple variables
      rkey = @rv.keys.first
      rval = @rv[rkey]
      if @gv.empty?
        @pspace.count(rkey, rval)
      else
        gkey = @gv.keys.first
        gval = @gv[gkey]
        @pspace.count2(rkey, rval, gkey, gval)
      end
    else
      rkey = @rv
      @pspace.count(rkey, nil)
    end
  end

  def prob
    if @rv.class == Hash
      rkey = @rv.keys.first
      rval = @rv[rkey]

      if @gv.empty?
        numer = self.count()
        denom = @pspace.count(rkey, nil)
      else
        gkey = @gv.keys.first
        gval = @gv[gkey]

        numer = @pspace.count2(rkey, rval, gkey, gval)
        denom = @pspace.count(gkey, gval)
      end

      return numer.to_f / denom
    else
      # should return a distribution
      distr = @pspace.uniq_vals(@rv).flat_map do |rv_val|
        [rv_val, PSpace.rv(@rv.to_sym => rv_val).prob]
      end

      Hash[*distr]
    end
  end

  def entropy
  end

  def infogain
  end

end
