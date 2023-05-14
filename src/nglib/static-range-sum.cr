module NgLib
  class StaticRangeSum(T)
    getter size : Int64
    getter csum : Array(T)
  
    def initialize(array : Array(T))
      @size = array.size.to_i64
      @csum = Array.new(@size + 1, T.zero)
      @size.times { |i| @csum[i + 1] = @csum[i] + array[i] }
    end
  
    def get(left, right) : T
      raise IndexError.new("`left` must be less than or equal to `right` (#{left}, #{right})") unless left <= right
      @csum[right] - @csum[left]
    end
  
    def get(range : Range(Int?, Int?)) : T
      left = (range.begin || 0)
      right = if range.end.nil?
          @size
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end
      get(left, right)
    end
    
    def get?(left, right) : T?
      return nil unless left <= right
      get(left, right)
    end
  
    def get?(range : Range(Int?, Int?)) : T?
      left = (range.begin || 0)
      right = if range.end.nil?
          @size
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end
      get?(left, right)
    end
  
    def get!(left, right) : T
      @csum[right] - @csum[left]
    end
  
    def get!(range : Range(Int?, Int?)) : T
      left = (range.begin || 0)
      right = if range.end.nil?
          @size
        else
          range.end.not_nil! + (range.exclusive? ? 0 : 1)
        end
      get!(left, right)
    end
  
    def [](left, right) : T; get(left, right) end
    def [](range : Range(Int?, Int?)) : T; get(range) end
    def []?(left, right) : T?; get?(left, right) end
    def []?(range : Range(Int?, Int?)) : T?; get?(range) end
  end  
end
