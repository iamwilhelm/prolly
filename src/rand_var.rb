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
    #puts "P(#{@rv} | #{@gv})"
    if @rv.class == Hash

      if @gv.empty?
        prob_rv_eq
      else
        prob_rv_eq_gv_eq
      end

    else
      #puts "distr : #{@rv.to_s} : #{@gv.to_s}"

      if @gv.empty?
        prob_rv
      elsif @gv.class == Hash
        prob_rv_gv_eq
      else
        prob_rv_gv
      end

    end
  end

  # P(color=green)
  def prob_rv_eq
    rkey = @rv.keys.first
    rval = @rv[rkey]

    numer = self.count()
    denom = @pspace.count(rkey, nil)

    return numer.to_f / denom
  end

  # P(color=green | size=small)
  def prob_rv_eq_gv_eq
    rkey = @rv.keys.first
    rval = @rv[rkey]

    gkey = @gv.keys.first
    gval = @gv[gkey]

    numer = @pspace.count2(rkey, rval, gkey, gval)
    denom = @pspace.count(gkey, gval)

    return numer.to_f / denom
  end

  # P(color=green | size)
  def prob_rv_eq_gv
    # NOT USED
  end

  # P(color) = [P(color=green), P(color=blue)]
  def prob_rv
    distr = @pspace.uniq_vals(@rv).flat_map do |rv_val|
      #puts "rv : #{@rv.to_s} | #{@gv.to_s}"
      [rv_val, PSpace.rv(@rv.to_sym => rv_val).prob]
    end
    Hash[*distr]
  end

  # P(color | size=small) =
  #   [P(color=green | size=small), P(color=blue | size=small)]
  def prob_rv_gv_eq
    distr = @pspace.uniq_vals(@rv).flat_map do |rv_val|
      gkey = @gv.keys.first
      gval = @gv[gkey]

      #puts "rv | gv = #gv : #{@rv.to_s} | #{@gv.to_s}"

      [rv_val, PSpace.rv(@rv.to_sym => rv_val).given(gkey.to_sym => gval).prob]
    end
    Hash[*distr]
  end

  # P(color | size) =
  #   [P(color | size=small), P(color | size=???)]
  def prob_rv_gv
    distr = @pspace.uniq_vals(@rv).flat_map do |rv_val|
      #puts "rv | gv : #{@rv.to_s} | #{@gv.to_s}"

      [rv_val, PSpace.rv(@rv.to_sym).given(@gv.to_sym).prob]
    end
    Hash[*distr]
  end

  # Entropy doesn't take hashes (for now?)
  # If it did, I'm not sure what H(color=green) means at all.
  def entropy
    if @gv.class == Hash or @gv.empty?
      #gkey = @gv.keys.first
      #gval = @gv[gkey]

      distr = prob
      #puts "---"
      distr.inject(0) do |t, kv|
        name, pn = kv
        #puts "P(#{@rv}=#{name}|#{gkey}=#{gval})*log P(#{@rv}=#{name}|#{gkey}=#{gval})"
        t += -pn * (pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)
      end
    else
      @pspace.uniq_vals(@gv).inject(0) do |t, gval|
        pn = PSpace.rv(@gv.to_sym => gval).prob
        hn = PSpace.rv(@rv).given(@gv.to_sym => gval).entropy
        #puts "P(#{@gv}=#{gval}) #{pn} * H(#{@rv}|#{@gv}=#{gval}) #{hn}"
        t += pn * hn
      end
    end

  end

  # need to always be I(Y | X)
  def infogain
    raise "Need given var" if @gv.empty?
    raise "Need unspecified given var" if @gv.class == Hash
    raise "Need unspecified rand var" if @rv.class == Hash
    PSpace.rv(@rv).entropy - PSpace.rv(@rv).given(@gv).entropy
  end

end
