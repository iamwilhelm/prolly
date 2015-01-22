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
  # P(color=green, size=small)
  def prob_rv_eq
    numer = self.count()
    denom = @pspace.count(@spec_rv.keys)

    return numer.to_f / denom
  end

  # P(color=green | size=small)
  # P(color=green, size=small | texture=smooth)
  # P(color=green | size=small, texture=smooth)
  def prob_rv_eq_gv_eq
    numer = @pspace.count(@spec_rv.merge(@spec_gv))
    denom = @pspace.count(@spec_gv)

    return numer.to_f / denom
  end

  # P(color=green | size)
  #
  # For now, this is like P(color=green)
  def prob_rv_eq_gv
    numer = @pspace.count(@spec_rv)
    denom = @pspace.count(@uspec_gv)

    return numer.to_f / denom
  end

  # P(color) = [P(color=green), P(color=blue)]
  # P(color, size) = [every combo of color and size]
  def prob_rv
    distr = ::PSpace.uniq_vals(@uspec_rv).flat_map do |rv_vals|
      spec_rv = Hash[*@uspec_rv.zip(rv_vals).flatten]
      [rv_vals, PSpace.rv(spec_rv).prob]
    end

    Hash[*distr]
  end

  # P(color | size=small) =
  #   [P(color=green | size=small), P(color=blue | size=small)]
  # P(color | size=small, texture=smooth) =
  #   [P(every color | size=small, texture=smooth)]
  def prob_rv_gv_eq
    distr = ::PSpace.uniq_vals(@uspec_rv).flat_map do |rv_vals|
      spec_rv = Hash[*@uspec_rv.zip(rv_vals).flatten]
      [rv_vals, PSpace.rv(spec_rv).given(@spec_gv).prob]
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
      raise "Cannot use entropy with specified random variables"
    else
      #puts "H(#{@rv} | #{@gv})"

      if @uspec_gv.empty?# and @spec_gv.empty?
        entropy_rv
      else 
        entropy_rv_gv
      end

    end
  end

  # H(color)
  # H(color, size)
  # H(color | size=small)
  # H(color, size | texture=smooth)
  # H(color | size=small, texture=smooth)
  def entropy_rv
    distr = prob
    distr.inject(0) do |t, kv|
      name, pn = kv
      t += -pn * (pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)
    end
  end

  # H(color | size)
  # H(color, weight | size, texture = smooth)
  # H(color | size, texture = smooth)
  def entropy_rv_gv
    ::PSpace.uniq_vals(@uspec_gv).inject(0) do |t, gv_vals|
      uspec_gv_speced = Hash[*@uspec_gv.zip(gv_vals).flatten]
      gv = @spec_gv.merge(uspec_gv_speced)

      pn = PSpace.rv(gv).given(@spec_gv).prob
      hn = PSpace.rv(*@uspec_rv).given(gv).entropy

      #puts "P(#{gv} | #{@spec_gv}) = #{pn}"
      #puts "H(#{@uspec_rv} | #{gv}) = #{hn}"
      #puts "  #{PSpace.rv(*@uspec_rv).given(gv).prob}"

      t += (pn * hn)
    end
  end

  # I(Y | X)
  # I(Y | X, A = a)
  # I(Y | X, A = a, B = b)
  def infogain
    raise "Need given var" if @uspec_gv.empty? and @spec_gv.empty?
    raise "Need unspecified given var" if @uspec_gv.empty?
    raise "Need unspecified rand var" if @uspec_rv.empty?

    # puts "I(#{@rv} | #{@gv})"
    PSpace.rv(*@uspec_rv).given(@spec_gv).entropy -
      PSpace.rv(*@uspec_rv).given(*@uspec_gv, @spec_gv).entropy
  end

end
