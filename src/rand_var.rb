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
        # P(color=green)
        numer = self.count()
        denom = @pspace.count(rkey, nil)
      else
        # P(color=green | size=small)
        gkey = @gv.keys.first
        gval = @gv[gkey]

        numer = @pspace.count2(rkey, rval, gkey, gval)
        denom = @pspace.count(gkey, gval)
      end

      return numer.to_f / denom
    else
      distr = @pspace.uniq_vals(@rv).flat_map do |rv_val|
        if @gv.empty?
          # P(color) = [P(color=green), P(color=blue)]
          [rv_val, PSpace.rv(@rv.to_sym => rv_val).prob]
        elsif @gv.class == Hash
          # P(color | size=small) =
          #   [P(color=green | size=small), P(color=blue | size=small)]
          gkey = @gv.keys.first
          gval = @gv[gkey]

          [rv_val, PSpace.rv(@rv.to_sym => rv_val).given(gkey.to_sym => gval).prob]
        else
          # P(color | size) =
          #   [P(color | size=small), P(color | size=???)]
          [rv_val, PSpace.rv(@rv.to_sym).given(@gv.to_sym).prob]
        end
      end

      Hash[*distr]
    end
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
