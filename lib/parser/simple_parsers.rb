module Parser
  class NumbinParser < AbstractParser
    def build_field
      f = Field.new(@id)
      res = 0
      @data.unpack("C*").each{ |ubyte|
        res *= 256
        res += ubyte
      }
      f.set_value(res)
      return f
    end
  end


  
  class NumstrParser < AbstractParser
    def build_field
      f = Field.new(@id)
      f.set_value(@data.to_i)
      return f
    end
  end

  class StringParser < AbstractParser
    def build_field
      f = Field.new(@id)
      f.set_value(@data)
      return f
    end
  end

  class BinaryParser < AbstractParser
    def build_field
      f = Field.new(@id)
      f.set_value(@data.unpack("H*").first.upcase)
      return f
    end
  end
end