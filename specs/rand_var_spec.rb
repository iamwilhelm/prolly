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

      it "is a distribution of blue and green" do
        expect(PSpace.rv(:color).prob).to be
      end
    end

    context "when prob color = green" do
      it "is 3/5" do
        expect(PSpace.rv(color: :green).prob).to be_within(0.001).of(3.0 / 5)
      end
    end

    context "when prob color = green | size == small" do
      it "is 2/3" do
        expect(PSpace.rv(color: :green).given(size: :small).prob).to be_within(0.001).of(2.0 / 3)
      end
    end
  end

end
