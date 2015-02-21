module Prolly
  class RandVar

    module Entropy

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

      private

      # H(color)
      # H(color, size)
      # H(color | size=small)
      # H(color, size | texture=smooth)
      # H(color | size=small, texture=smooth)
      def entropy_rv
        distr = pdf
        distr.inject(0) do |t, kv|
          name, pn = kv
          t += -pn * (pn == 0 ? 0.0 : Math.log(pn)) / Math.log(10)
        end
      end

      # H(color | size)
      # H(color, weight | size, texture = smooth)
      # H(color | size, texture = smooth)
      def entropy_rv_gv
        ::Ps.uniq_vals(@uspec_gv).inject(0) do |t, gv_vals|
          uspec_gv_speced = Hash[*@uspec_gv.zip(gv_vals).flatten]
          gv = @spec_gv.merge(uspec_gv_speced)

          pn = Ps.rv(gv).given(@spec_gv).prob
          hn = Ps.rv(*@uspec_rv).given(gv).entropy

          #puts "P(#{gv} | #{@spec_gv}) = #{pn}"
          #puts "H(#{@uspec_rv} | #{gv}) = #{hn}"
          #puts "  #{Ps.rv(*@uspec_rv).given(gv).prob}"

          t += (pn * hn)
        end
      end

    end

  end
end
