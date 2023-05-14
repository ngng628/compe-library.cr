module NgLib
  struct Edge
    @data : {Int64, Int64}
    def initialize(t : Int64, w : Int64)
      @data = {t, w}
    end
  
    def self.to; @data[0] end
    def self.weight; @data[1] end
    def [](i : Int); @data[i] end
  end
end
