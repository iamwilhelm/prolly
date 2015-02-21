module Prolly
  class RandVar

    module Infogain

      # I(Y | X)
      # I(Y | X, A = a)
      # I(Y | X, A = a, B = b)
      def infogain
        raise "Need given var" if @uspec_gv.empty? and @spec_gv.empty?
        raise "Need unspecified given var" if @uspec_gv.empty?
        raise "Need unspecified rand var" if @uspec_rv.empty?

        # puts "I(#{@rv} | #{@gv})"
        Ps.rv(*@uspec_rv).given(@spec_gv).entropy -
          Ps.rv(*@uspec_rv).given(*@uspec_gv, @spec_gv).entropy
      end

    end

  end
end
