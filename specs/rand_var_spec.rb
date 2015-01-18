$:.unshift "src"

require "rspec"
require "pspace"

describe RandVar do
  let(:data) {
    [
      { :color => :green, :size => :small, :texture => :smooth },
      { :color => :blue,  :size => :small, :texture => :rough  },
      { :color => :blue,  :size => :med,   :texture => :smooth },
      { :color => :green, :size => :large, :texture => :rough  },
      { :color => :green, :size => :small, :texture => :smooth },
    ]
  }

  describe "#count" do
    before do
      PSpace.import(data)
    end
    
    context "when counting color" do
      # TODO or should it be the count distribution?
      it "is size of entire set" do
        expect(PSpace.rv(:color).count).to eq(5)
      end
    end

    context "when counting color, size" do
      it "is size of entire set with both attributes" do
        expect(PSpace.rv(:color, :size).count).to eq(5)
      end
    end

    context "when counting color = green" do
      it "is 3, number of rows with color = green" do
        expect(PSpace.rv(color: :green).count).to eq(3)
      end
    end

    context "when counting color = green, size = small" do
      it "is 2, number of rows with both color = green and size = small" do
        expect(PSpace.rv(color: :green, size: :small).count).to eq(2)
      end
    end

    context "when counting color = green | size == small" do
      it "is 2" do
        expect(PSpace.rv(color: :green).given(size: :small).count).to eq(2)
      end
    end

    context "when counting color = green, size = small | texture = smooth" do
      it "is 2" do
        expect(
          PSpace.rv(color: :green).given(size: :small, texture: :smooth).count
        ).to eq(2)
      end
    end

    context "when counting color = blue | size = small, texture = rough" do
      it "is 1" do
        expect(
          PSpace.rv(color: :blue).given(size: :small, texture: :rough).count
        ).to eq(1)
      end
    end

    context "when counting color = blue | size = small, texture = smooth" do
      it "is 0" do
        expect(
          PSpace.rv(color: :blue).given(size: :small, texture: :smooth).count
        ).to eq(0)
      end
    end
  end

  describe "#prob" do
    before do
      PSpace.import(data)
    end

    context "#prob_rv_eq" do
      context "when prob color = green" do
        it "is 3/5" do
          expect(PSpace.rv(color: :green).prob).to be_within(0.001).of(3.0 / 5)
        end
      end

      context "when prob color = green, size = small" do
        it "is 2/5" do
          expect(
            PSpace.rv(color: :green, size: :small).prob
          ).to be_within(0.001).of(2.0 / 5)
        end
      end
    end

    context "#prob_rv_eq_gv_eq" do
      context "when prob color = green | size == small" do
        it "is 2/3" do
          result = PSpace.rv(color: :green).given(size: :small).prob
          expect(result).to be_within(0.001).of(2.0 / 3)
        end
      end

      context "when prob color=green, size=small | texture=smooth" do
        it "is 2/3" do
          result = PSpace.rv(color: :green, size: :small).given(texture: :smooth).prob
          expect(result).to be_within(0.001).of(2.0 / 3)
        end
      end

      context "when prob color=green | size=small, texture=smooth" do
        it "is 1.0" do
          result = PSpace.rv(color: :green).given(size: :small, texture: :smooth).prob
          expect(result).to be_within(0.001).of(1.0)
        end
      end
    end

    context "#prob_rv_eq_gv" do
      context "when prob size=large | texture" do
        it "is 1/5" do
          result = PSpace.rv(size: :large).given(:texture).prob
          expect(result).to be_within(0.001).of(1.0 / 5)
        end
      end
    end

    context "#prob_rv" do
      context "when prob color" do
        it "is the entire distribution as a hash" do
          expect(PSpace.rv(:color).prob).to be_an_instance_of(Hash)
        end

        it "is a distribution of blue = 2/5 and green = 3/5" do
          result = PSpace.rv(:color).prob
          expect(result.keys).to include(:blue)
          expect(result[:blue]).to eql(2.0 / 5)
          expect(result.keys).to include(:green)
          expect(result[:green]).to eql(3.0 / 5)
        end
      end

      context "when prob color, size" do
        it "is a distribution"
      end
    end

    context "when prob color | size == small" do
      it "is a distribution" do
        result = PSpace.rv(:color).given(size: :small).prob
        expect(result).to be_an_instance_of(Hash)
      end

      it "is a distribution of blue = 1/3, green = 2/3" do
        result = PSpace.rv(:color).given(size: :small).prob
        expect(result.keys).to include(:blue)
        expect(result[:blue]).to eql(1.0 / 3)
        expect(result.keys).to include(:green)
        expect(result[:green]).to eql(2.0 / 3)
      end
    end


    context "when prob color | size" do
      it "is ..." do
        #result = PSpace.rv(:color).given(:size).prob
      end
    end
  end

  describe "#entropy" do
    before do
      PSpace.import(data)
    end

    context "when entropy of color" do
      it "is H(X) = -∑ (pn log pn)" do
        expect(PSpace.rv(:color).entropy).to be_within(0.001).of(
          -0.6 * Math.log(0.6) / Math.log(10) - 0.4 * Math.log(0.4) / Math.log(10)
        )
      end
    end

    context "when entropy of color | size = small" do
      it "is H(color | size = small)" do
        expect(PSpace.rv(:color).given(size: :small).entropy).to be_within(0.001).of(
          -(1.0/3) * Math.log(1.0/3) / Math.log(10) -
          (2.0/3) * Math.log(2.0/3) / Math.log(10)
        )
      end
    end

    context "when entropy of color | size" do
      it "is H(color | size)" do
        result = PSpace.rv(:color).given(:size).entropy
        #puts result
        expect(result).to be_within(0.001).of(
          (0.6) * (-(2.0/3) * Math.log(2.0/3) / Math.log(10) - (1.0/3) * Math.log(1.0/3) / Math.log(10)) + # :small
          (0.2) * (-(0.0) - (1.0) * Math.log(1.0) / Math.log(10)) + # :med
          (0.2) * (-(1.0) * Math.log(1.0) / Math.log(10) - (0.0))   # :large
        )
      end
    end
  end

  describe "#infogain" do
    before do
      PSpace.import(data)
    end

    context "when color | size" do
      # I(color | size) = H(color) - H(color | size)
      it "is the infogain(color | size)" do
        result = PSpace.rv(:color).given(:size).infogain
        expect(result).to be_within(0.001).of(
          PSpace.rv(:color).entropy - PSpace.rv(:color).given(:size).entropy
        )
      end
    end

    context "when color | size = green, weight" do

      # I(color | size = green) =
      #   H(color | size = green) - H(color | size = green, weight)"
      it "is infogain(color | size = green, weight)" do
        #result = PSpace.rv(:color).given(:weight, size: :green)
      end

    end

    context "when color | size = green, texture = rough, weight)" do

      it "is infogain(color | size = green, texture = rough, weight)" do
        #result = PSpace.rv(:color)
      end

    end

  end

end
