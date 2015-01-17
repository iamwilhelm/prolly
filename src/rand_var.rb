class RandVar

  def initialize(pspace, *rand_vars)
    @pspace = pspace

    @uspec_rv, @spec_rv = parse(rand_vars)

    @uspec_gv = []
    @spec_gv = {}
  end

  # parses rand_var arguments
  #
  # random variable are passed in as arguments to a method. It can take the format of:
  #
  # :size
  #
  # { size: :large, color: :green }
  #
  # [ :size, { color: :green, texture: :rough } ]
  #
  def parse(rand_vars)
    if rand_vars.kind_of?(Hash)
      specified_rvs = rand_vars
      unspecified_rvs = []
    elsif rand_vars.kind_of?(Array)
      specified_rvs, unspecified_rvs = rand_vars.partition { |e| e.kind_of?(Hash) }
      specified_rvs = specified_rvs.inject({}) { |t, e| t.merge(e) }
    else # if it's a symbol
      specified_rvs = []
      unspecified_rvs = [rand_vars]
    end

    return unspecified_rvs, specified_rvs
  end

  def given(*rand_vars)
    @uspec_gv, @spec_gv = parse(rand_vars)

    return self
  end

  def count
    if !@spec_rv.empty?
      if @uspec_gv.empty? and @spec_gv.empty?
        @pspace.count(@spec_rv)
      else
        @pspace.count(@spec_rv.merge(@spec_gv))
      end
    else
      @pspace.count(@uspec_rv)
    end
  end


  def prob
    #puts "P(#{@rv} | #{@gv})"
    if !@spec_rv.empty?

      if @uspec_gv.empty? and @spec_gv.empty?
        prob_rv_eq
      else
        prob_rv_eq_gv_eq
      end

    else
      #puts "distr : #{@rv.to_s} : #{@gv.to_s}"

      if @uspec_gv.empty? and @spec_gv.empty?
        prob_rv
      elsif not @spec_gv.empty?
        prob_rv_gv_eq
      else
        prob_rv_gv
      end

    end
  end

  # P(color=green)
  def prob_rv_eq
    rkey, rval = @spec_rv.first

    numer = self.count()
    denom = @pspace.count([rkey])

    return numer.to_f / denom
  end

  # P(color=green | size=small)
  def prob_rv_eq_gv_eq
    numer = @pspace.count(@spec_rv.merge(@spec_gv))
    denom = @pspace.count(@spec_gv)

    return numer.to_f / denom
  end

  # P(color=green | size)
  # TODO not tested
  def prob_rv_eq_gv
    numer = @pspace.count(@spec_rv)
    denom = @pspace.count(@uspec_gv)
  end

  # P(color) = [P(color=green), P(color=blue)]
  def prob_rv
    rv = @uspec_rv.first
    distr = @pspace.uniq_vals(rv).flat_map do |rv_val|
      #puts "rv : #{rv.to_s} | #{@gv.to_s}"
      [rv_val, PSpace.rv(rv.to_sym => rv_val).prob]
    end
    Hash[*distr]
  end

  # P(color | size=small) =
  #   [P(color=green | size=small), P(color=blue | size=small)]
  def prob_rv_gv_eq
    rv = @uspec_rv.first
    distr = @pspace.uniq_vals(rv).flat_map do |rv_val|
      gkey, gval = @spec_gv.first

      #puts "rv | gv = #gv : #{rv.to_s} | #{@gv.to_s}"

      [rv_val, PSpace.rv(rv.to_sym => rv_val).given(gkey.to_sym => gval).prob]
    end
    Hash[*distr]
  end

  # P(color | size) =
  #   [P(color=green | size), P(color=blue | size)]
  # TODO not tested
  def prob_rv_gv
    rv = @uspec_rv.first
    gv = @uspec_gv.first

    distr = @pspace.uniq_vals(rv).flat_map do |rv_val|
      #puts "rv | gv : #{rv.to_s} | #{@gv.to_s}"

      [rv_val, PSpace.rv(rv.to_sym => rv_val).given(gv.to_sym).prob]
    end
    Hash[*distr]
  end

  # Entropy doesn't take hashes (for now?)
  # If it did, I'm not sure what H(color=green) means at all.
  def entropy
    if !@spec_rv.empty?

      if @uspec_gv.empty? and @spec_gv.empty?
        # These will raise exceptions
        entropy_rv_eq
      else
        # These will raise exceptions
        entropy_rv_eq_gv_eq
        entropy_rv_eq_gv
      end

    else
      #puts "H(#{@rv} | #{@gv})"

      if @uspec_gv.empty? and @spec_gv.empty?
        entropy_rv
      elsif not @spec_gv.empty?
        entropy_rv_gv_eq
      else 
        entropy_rv_gv
      end

    end
  end

  # H(color=green)
  def entropy_rv_eq
    raise "H(color=green) not implemented"
  end

  # H(color=green | size=small)
  # TODO does this make sense when given rv is specified? I don't think so...
  def entropy_rv_eq_gv_eq
    raise "H(color=green | size=small) not implemented"
  end

  # H(color=green | size)
  # TODO might not make sense when rv is specified
  def entropy_rv_eq_gv
    raise "H(color=green | size) not implemented"
  end

  # H(color)
  def entropy_rv
    #rv = @unspec_rv.first
    # puts "H(#{rv})"

    distr = prob
    distr.inject(0) do |t, kv|
      name, pn = kv
      # puts "  P(#{rv}=#{name}) * log P(#{rv}=#{name}) + "
      t += -pn * (pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)
    end.tap { |val|
      # puts "  = #{val}"
    }
  end

  # H(color | size=small)
  def entropy_rv_gv_eq
    #puts "H(#{@uspec_rv} | #{@spec_gv.to_s}) ="

    distr = prob
    distr.inject(0) do |t, kv|
      name, pn = kv
      #puts "  P(#{@uspec_rv} | #{@spec_gv})(#{pn}) *"
      # + " log P(#{@uspec_rv} | #{@spec_gv})"
      # + "(#{(pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)}) +"
      t += -pn * (pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)
    end.tap { |val|
      #puts "  = #{val}"
    }
  end

  # H(color | size)
  def entropy_rv_gv
    # puts "H(#{@rv} | #{@gv}) ="

    rv = @uspec_rv.first
    gv = @uspec_gv.first

    @pspace.uniq_vals(gv).inject(0) do |t, gval|
      pn = PSpace.rv(gv.to_sym => gval).prob
      hn = PSpace.rv(rv).given(gv.to_sym => gval).entropy

      # puts "  P(#{@gv} = #{gval}) * H(#{rv} | #{gv}=#{gval}) (#{pn * hn}) +"
      t += pn * hn
    end.tap { |val|
      # puts "  = #{val}"
    }
  end

  # need to always be I(Y | X)
  def infogain
    raise "Need given var" if @uspec_gv.empty? and @spec_gv.empty?
    raise "Need unspecified given var" if @uspec_gv.empty?
    raise "Need unspecified rand var" if @rv.class == Hash

    # puts "I(#{@rv} | #{@gv})"
    PSpace.rv(*@uspec_rv).entropy - PSpace.rv(*@uspec_rv).given(*@uspec_gv).entropy
  end

end
