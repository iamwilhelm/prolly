$:.unshift "src"

require "rspec"
require "pspace"

describe PSpace do
  let(:data) {
    [
      { :color => :green, :size => :small, :texture => :smooth },
      { :color => :blue,  :size => :small, :texture => :rough  },
      { :color => :blue,  :size => :med,   :texture => :smooth },
      { :color => :green, :size => :large, :texture => :rough  },
      { :color => :green, :size => :small, :texture => :smooth },
    ]
  }

  describe "#uniq_vals" do
    before do
      PSpace.import(data)
    end

    context "when asking for uniq vals of colors" do
      it "is green and blue" do
        result = PSpace.uniq_vals([:color])
        expect(result).to include([:blue])
        expect(result).to include([:green])
      end
    end

    context "when asking for uniq vals of colors and sizes" do
      it "is combinations of green blue, small, med, and large" do
        result = PSpace.uniq_vals([:color, :size])
        expect(result).to include([:green, :small])
        expect(result).to include([:green, :med])
        expect(result).to include([:green, :large])
        expect(result).to include([:blue, :small])
        expect(result).to include([:blue, :med])
        expect(result).to include([:blue, :large])
      end
    end

    context "when asking for uniq vals of colors, sizes, and textures" do
      it "is combinations of blue, green, small, med, large, smooth, and rough" do
        result = PSpace.uniq_vals([:color, :size, :texture])
        expect(result).to include([:green, :small, :smooth])
        expect(result).to include([:green, :med  , :smooth])
        expect(result).to include([:green, :large, :smooth])
        expect(result).to include([:blue, :small , :smooth])
        expect(result).to include([:blue, :med   , :smooth])
        expect(result).to include([:blue, :large , :smooth])

        expect(result).to include([:green, :small, :rough])
        expect(result).to include([:green, :med  , :rough])
        expect(result).to include([:green, :large, :rough])
        expect(result).to include([:blue, :small , :rough])
        expect(result).to include([:blue, :med   , :rough])
        expect(result).to include([:blue, :large , :rough])
      end
    end
  end

end
