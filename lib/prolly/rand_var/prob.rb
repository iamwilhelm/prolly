module Prolly
  class RandVar

    module Prob

      def prob
        #puts "P(#{@rv} | #{@gv})"
        raise StandardError.new("Cannot use prob on this RV") if @spec_rv.empty?

        if @uspec_gv.empty? and @spec_gv.empty?
          prob_rv_eq
        else
          prob_rv_eq_gv_eq
        end
      end

      private

      # P(color=green)
      # P(color=green, size=small)
      # P(color=[green, blue])
      def prob_rv_eq
        numer = self.count()
        denom = @pspace.count(@spec_rv.keys)

        if denom == 0.0
          return 0.0
        else
          return numer.to_f / denom
        end
      end

      # P(color=green | size=small)
      # P(color=green, size=small | texture=smooth)
      # P(color=green | size=small, texture=smooth)
      def prob_rv_eq_gv_eq
        numer = @pspace.count(@spec_rv.merge(@spec_gv))
        denom = @pspace.count(@spec_gv)

        if denom == 0.0
          return 0.0
        else
          return numer.to_f / denom
        end
      end

      # P(color=green | size)
      #
      # For now, this is like P(color=green)
      def prob_rv_eq_gv
        numer = @pspace.count(@spec_rv)
        denom = @pspace.count(@uspec_gv)

        return numer.to_f / denom
      end


    end

  end
end
