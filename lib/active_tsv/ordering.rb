module ActiveTsv
  Ordering = Struct.new(:column)

  class Ascending < Ordering
    def to_i
      1
    end

    def ascending?
      true
    end

    def descending?
      false
    end
  end

  class Descending < Ordering
    def to_i
      -1
    end

    def ascending?
      false
    end

    def descending?
      true
    end
  end
end
