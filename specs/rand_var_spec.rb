require "rspec"

require_relative("../src/pspace")

# PSpace.import(data)

# PSpace.rv(:car).count
# PSpace.rv(:car).given(:weight).count

# PSpace.rv(:weight).prob

# PSpace.rv(weight: 180).prob

# PSpace.rv(:weight).given(:displacement).prob

# PSpace.rv(:weight).given(x: :bbq).entropy

# PSpace.entropy(:weight).given(:x)

# PSpace.infogain(:weight).given(:x)

describe RandVar do
  let(:data) {
    [
      { :color => :green, :size => :small },
      { :color => :blue,  :size => :small },
      { :color => :blue,  :size => :med },
      { :color => :green, :size => :large },
      { :color => :green, :size => :small },
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

    context "when counting color = green" do
      it "is 3" do
        expect(PSpace.rv(color: :green).count).to eq(3)
      end
    end

    context "when counting color = green | size == small" do
      it "is 2" do
        expect(PSpace.rv(color: :green).given(size: :small).count).to eq(2)
      end
    end
  end

  describe "#prob" do
    before do
      PSpace.import(data)
    end

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

    context "when prob color = green" do
      it "is 3/5" do
        expect(PSpace.rv(color: :green).prob).to be_within(0.001).of(3.0 / 5)
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

    context "when prob color = green | size == small" do
      it "is 2/3" do
        result = PSpace.rv(color: :green).given(size: :small).prob
        expect(result).to be_within(0.001).of(2.0 / 3)
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
      it "I(color | size) = H(color) - H(color | size)" do
        result = PSpace.rv(:color).given(:size).infogain
        expect(result).to be_within(0.001).of(
          PSpace.rv(:color).entropy - PSpace.rv(:color).given(:size).entropy
        )
      end
    end

  end

end
