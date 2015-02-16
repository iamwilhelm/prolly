$:.unshift "src"

require "rspec"
require "ps"

describe RandVar do
  let(:data) {
    [
      { color: :green, size: :small, texture: :smooth, weight: :fat , opacity: :transparent },
      { color: :blue,  size: :small, texture: :rough , weight: :thin, opacity: :transparent },
      { color: :blue,  size: :med,   texture: :smooth, weight: :thin, opacity: :opaque },
      { color: :green, size: :large, texture: :rough , weight: :thin, opacity: :opaque },
      { color: :green, size: :small, texture: :smooth, weight: :thin, opacity: :opaque },
    ]
  }

  before do
    Ps.reset
    Ps.import(data)
  end

  describe "#count" do
    context "when counting color" do
      # TODO or should it be the count distribution?
      it "is size of entire set" do
        expect(Ps.rv(:color).count).to eq(5)
      end
    end

    context "when counting color, size" do
      it "is size of entire set with both attributes" do
        expect(Ps.rv(:color, :size).count).to eq(5)
      end
    end

    context "when counting color = green" do
      it "is 3, number of rows with color = green" do
        expect(Ps.rv(color: :green).count).to eq(3)
      end
    end

    context "when counting color = green, size = small" do
      it "is 2, number of rows with both color = green and size = small" do
        expect(Ps.rv(color: :green, size: :small).count).to eq(2)
      end
    end

    context "when counting color = green | size == small" do
      it "is 2" do
        expect(Ps.rv(color: :green).given(size: :small).count).to eq(2)
      end
    end

    context "when counting color = green, size = small | texture = smooth" do
      it "is 2" do
        expect(
          Ps.rv(color: :green).given(size: :small, texture: :smooth).count
        ).to eq(2)
      end
    end

    context "when counting color = blue | size = small, texture = rough" do
      it "is 1" do
        expect(
          Ps.rv(color: :blue).given(size: :small, texture: :rough).count
        ).to eq(1)
      end
    end

    context "when counting color = blue | size = small, texture = smooth" do
      it "is 0" do
        expect(
          Ps.rv(color: :blue).given(size: :small, texture: :smooth).count
        ).to eq(0)
      end
    end
  end

  describe "#prob" do

    describe "#prob_rv_eq" do
      context "when prob color = green" do
        it "is 3/5" do
          expect(Ps.rv(color: :green).prob).to be_within(0.001).of(3.0 / 5)
        end
      end

      context "when prob color = green, size = small" do
        it "is 2/5" do
          expect(
            Ps.rv(color: :green, size: :small).prob
          ).to be_within(0.001).of(2.0 / 5)
        end
      end
    end

    describe "#prob_rv_eq_gv_eq" do
      context "when prob color = green | size == small" do
        it "is 2/3" do
          result = Ps.rv(color: :green).given(size: :small).prob
          expect(result).to be_within(0.001).of(2.0 / 3)
        end
      end

      context "when prob color=green, size=small | texture=smooth" do
        it "is 2/3" do
          result = Ps.rv(color: :green, size: :small).given(texture: :smooth).prob
          expect(result).to be_within(0.001).of(2.0 / 3)
        end
      end

      context "when prob color=green | size=small, texture=smooth" do
        it "is 1.0" do
          result = Ps.rv(color: :green).given(size: :small, texture: :smooth).prob
          expect(result).to be_within(0.001).of(1.0)
        end
      end
    end

    describe "#prob_rv_eq_gv" do
      context "when prob size=large | texture" do
        it "is 1/5" do
          result = Ps.rv(size: :large).given(:texture).prob
          expect(result).to be_within(0.001).of(1.0 / 5)
        end
      end
    end

    describe "#prob_rv" do
      context "when prob color" do
        it "is the entire distribution as a hash" do
          result = Ps.rv(:color).prob
          expect(result).to be_an_instance_of(Hash)
          expect(result.keys).to include([:blue])
          expect(result.keys).to include([:green])
        end

        it "has probs that sum to 1" do
          result = Ps.rv(:color).prob
          sum = result.values.inject(0) { |t,e| t += e }
          expect(sum).to eq(1.0)
        end

        it "is a distribution of blue = 2/5 and green = 3/5" do
          result = Ps.rv(:color).prob
          expect(result).to be_an_instance_of(Hash)
          expect(result[[:blue]]).to eql(2.0 / 5)
          expect(result[[:green]]).to eql(3.0 / 5)
        end
      end

      context "when prob color, size" do
        it "is a distribution" do
          result = Ps.rv(:color, :size).prob
          expect(result.keys).to include([:green, :small])
          expect(result.keys).to include([:green, :med])
          expect(result.keys).to include([:green, :large])
          expect(result.keys).to include([:blue , :small])
          expect(result.keys).to include([:blue , :med])
          expect(result.keys).to include([:blue , :large])
        end

        it "has probs that sum to 1" do
          result = Ps.rv(:color, :size).prob
          sum = result.values.inject(0) { |t,e| t += e }
          expect(sum).to eq(1.0)
        end

        it "is a distribution of color and size" do
          result = Ps.rv(:color, :size).prob
          expect(result[[:green, :small]]).to eql(2.0 / 5)
          expect(result[[:green, :med  ]]).to eql(0.0 / 5)
          expect(result[[:green, :large]]).to eql(1.0 / 5)
          expect(result[[:blue , :small]]).to eql(1.0 / 5)
          expect(result[[:blue , :med  ]]).to eql(1.0 / 5)
          expect(result[[:blue , :large]]).to eql(0.0 / 5)
        end
      end
    end

    describe "#prob_rv_gv_eq" do
      context "when prob color | size = small" do
        it "is a distribution" do
          result = Ps.rv(:color).given(size: :small).prob
          expect(result).to be_an_instance_of(Hash)
          expect(result.keys).to include([:blue])
          expect(result.keys).to include([:green])
        end

        it "has probs that sum to 1" do
          result = Ps.rv(:color).given(size: :small).prob
          sum = result.values.inject(0) { |t,e| t += e }
          expect(sum).to eq(1.0)
        end

        it "is a distribution of blue = 1/3, green = 2/3" do
          result = Ps.rv(:color).given(size: :small).prob
          expect(result[[:blue]]).to eql(1.0 / 3)
          expect(result[[:green]]).to eql(2.0 / 3)
        end
      end

      context "when prob color | size = small, texture = smooth" do
        it "is a distribution" do
          result = Ps.rv(:color).given(size: :small, texture: :smooth).prob
          expect(result).to be_an_instance_of(Hash)
          expect(result.keys).to include([:blue])
          expect(result.keys).to include([:green])
        end

        it "has probs that sum to 1" do
          result = Ps.rv(:color).given(size: :small, texture: :smooth).prob
          sum = result.values.inject(0) { |t,e| t += e }
          expect(sum).to eq(1.0)
        end

        it "is a distribution of blue and green" do
          result = Ps.rv(:color).given(size: :small, texture: :smooth).prob
          expect(result[[:blue]]).to eql(0.0 / 2)
          expect(result[[:green]]).to eql(2.0 / 2)
        end
      end
    end

    context "when prob color = green | size = small" do
      it "is ..." do
        #result = Ps.rv(:color).given(:size).prob
      end
    end
  end

  describe "#entropy" do

    describe "#entropy_rv" do
      context "when entropy of color" do
        it "is H(X) = -∑ (pn log pn)" do
          result = Ps.rv(:color).entropy
          expect(result).to be_within(0.001).of(
            -0.6 * Math.log(0.6) / Math.log(10) - 
             0.4 * Math.log(0.4) / Math.log(10)
          )
        end
      end

      context "when entropy of color, size" do
        it "is H(color,size)" do
          result = Ps.rv(:color, :size).entropy
          expect(result).to be_within(0.001).of(
            -0.4 * Math.log(0.4) / Math.log(10) +
            -0.2 * Math.log(0.2) / Math.log(10) * 3
          )
        end
      end

      context "when entropy of color | size = small" do
        it "is H(color | size = small)" do
          result = Ps.rv(:color).given(size: :small).entropy
          expect(result).to be_within(0.001).of(
            -(1.0/3) * Math.log(1.0/3) / Math.log(10) +
            -(2.0/3) * Math.log(2.0/3) / Math.log(10)
          )
        end

        it "is H(color, size | texture = smooth)" do
          result = Ps.rv(:color, :size).given(texture: :smooth).entropy
          expect(result).to be_within(0.001).of(
            -(1.0/3) * Math.log(1.0/3) / Math.log(10) +
            -(2.0/3) * Math.log(2.0/3) / Math.log(10)
          )
        end

        it "is H(color | size=small, texture=smooth)" do
          result = Ps.rv(:color).given(size: :small, texture: :smooth).entropy
          expect(result).to be_within(0.001).of(
            -(1.0) * Math.log(1.0) / Math.log(10)
          )
        end
      end
    end

    describe "#entropy_rv_gv" do
      context "when entropy of color | size" do
        it "is H(color | size)" do
          result = Ps.rv(:color).given(:size).entropy
          expect(result).to be_within(0.001).of(
            # :small * (:green | :small + :blue | :small)
            (3.0 / 5) * (-(2.0/3) * Math.log(2.0/3) / Math.log(10) +
                         -(1.0/3) * Math.log(1.0/3) / Math.log(10)) + 
            # :med
            (1.0 / 5) * (-(0.0) +
                         -(1.0) * Math.log(1.0) / Math.log(10)) + 
            # :large
            (1.0 / 5) * (-(0.0) +
                         -(1.0) * Math.log(1.0) / Math.log(10))
          )
        end

        it "is H(color, texture | size, weight = thin)" do
          result = Ps.rv(:color, :texture).given(:size, weight: :thin)

          expect(result.entropy).to be_within(0.001).of(
            # :small * (:green, :smooth | :small, :thin +
            #           :blue,  :smooth | :small, :thin +
            #           :green, :rough  | :small, :thin +
            #           :blue,  :rough  | :small, :thin )
            (2.0/4) * (-(1.0/2) * Math.log(1.0/2) / Math.log(10) +
                       -(0.0/2) * 0.0 / Math.log(10) +
                       -(0.0/2) * 0.0 / Math.log(10) +
                       -(1.0/2) * Math.log(1.0/2) / Math.log(10)
                      ) +
            # :med
            (1.0/4) * (-(0.0/1) * 0.0 / Math.log(10) +
                       -(1.0/1) * Math.log(1.0/1) / Math.log(10) +
                       -(0.0/1) * 0.0 / Math.log(10) +
                       -(0.0/1) * 0.0 / Math.log(10)
                      ) +
            # :large
            (1.0/4) * (-(0.0/1) * 0.0 / Math.log(10) +
                       -(0.0/1) * 0.0 / Math.log(10) +
                       -(1.0/1) * Math.log(1.0/1) / Math.log(10) +
                       -(0.0/1) * 0.0 / Math.log(10)
                      )
          )
        end

        it "is H(color | size, weight = thin)" do
          result = Ps.rv(:color).given(:size, weight: :thin)

          expect(result.entropy).to be_within(0.001).of(
            # :small * (:green | :small, :thin + :blue | :small, :thin)
            (2.0/4) * (-(1.0/2) * Math.log(1.0/2) / Math.log(10) +
                       -(1.0/2) * Math.log(1.0/2) / Math.log(10)) +
            # :med
            (1.0/4) * (-(0.0) +
                       -(1.0) * Math.log(1.0) / Math.log(10)) + 
            # :large
            (1.0/4) * (-(0.0) +
                       -(1.0) * Math.log(1.0) / Math.log(10))
          )
        end

        it "is H(color | texture, opacity=opaque, weight=thin)" do
          result = Ps.rv(:color).given(:texture,
                                           opacity: :opaque,
                                           weight: :thin)
          expect(result.entropy).to be_within(0.001).of(
            # :smooth * (:green | :smooth + :blue | :smooth)
            (2.0/3) * (-(1.0/2) * Math.log(1.0/2) / Math.log(10) +
                       -(1.0/2) * Math.log(1.0/2) / Math.log(10)) +
            # :rough * (:green | :rough + :blue | :rough)
            (1.0/3) * (-(1.0/1) * Math.log(1.0/1) / Math.log(10) +
                       -(0.0/1) * 0.0 / Math.log(10))
          )
        end

      end
    end
  end

  describe "#infogain" do

    context "when color | size" do
      # I(color | size) = H(color) - H(color | size)
      it "is the infogain(color | size)" do
        result = Ps.rv(:color).given(:size).infogain
        expect(result).to be_within(0.001).of(
          Ps.rv(:color).entropy - Ps.rv(:color).given(:size).entropy
        )
      end
    end

    context "when color | size, weight = thin" do
      # I(color | size, weight = thin) =
      #   H(color | weight = thin) - H(color | size, weight = thin)"
      it "is infogain(color | weight = thin)" do
        result = Ps.rv(:color).given(:size, weight: :thin).infogain

        expect(result).to be_within(0.001).of(
          Ps.rv(:color).given(weight: :thin).entropy -
          Ps.rv(:color).given(:size, weight: :thin).entropy
        )
      end
    end

    context "when color | texture, weight = thin, opacity = opaque)" do
      it "is infogain(color | texture, weight = thin, opacity = opaque)" do
        result = Ps.rv(:color).given(:texture,
                                         weight: :thin, opacity: :opaque).infogain

        expect(result).to be_within(0.001).of(
          Ps.rv(:color).given(weight: :thin, opacity: :opaque).entropy -
          Ps.rv(:color).given(:texture,
                                  weight: :thin, opacity: :opaque).entropy
        )
      end
    end

  end

end
