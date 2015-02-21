module Prolly
  class RandVar

    module Pdf

      def pdf
        if !@spec_rv.empty?

          raise StandardError.new("Cannot use pdf on this RV")

          #if @uspec_gv.empty? and @spec_gv.empty?
          #  prob_rv_eq
          #else
          #  prob_rv_eq_gv_eq
          #end

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

      private

      # P(color) = [P(color=green), P(color=blue)]
      # P(color, size) = [every combo of color and size]
      def prob_rv
        distr = ::Ps.uniq_vals(@uspec_rv).flat_map do |rv_vals|
          spec_rv = Hash[*@uspec_rv.zip(rv_vals).flatten]
          [rv_vals, Ps.rv(spec_rv).prob]
        end

        Hash[*distr]
      end

      # P(color | size=small) =
      #   [P(color=green | size=small), P(color=blue | size=small)]
      # P(color | size=small, texture=smooth) =
      #   [P(every color | size=small, texture=smooth)]
      def prob_rv_gv_eq
        distr = ::Ps.uniq_vals(@uspec_rv).flat_map do |rv_vals|
          spec_rv = Hash[*@uspec_rv.zip(rv_vals).flatten]
          [rv_vals, Ps.rv(spec_rv).given(@spec_gv).prob]
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

          [rv_val, Ps.rv(rv.to_sym => rv_val).given(gv.to_sym).prob]
        end
        Hash[*distr]
      end



    end

  end
end
