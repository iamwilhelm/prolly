require "rand_var"

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


