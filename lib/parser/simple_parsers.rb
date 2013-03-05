module Parser
  EBCDIC_2_ASCII = ["000102039C09867F978D8E0B0C0D0E0F101112139D8508871819928F1C1D1E1F"+
  "80818283840A171B88898A8B8C050607909116939495960498999A9B14159E1A"+
  "20A0A1A2A3A4A5A6A7A8D52E3C282B7C26A9AAABACADAEAFB0B121242A293B5E"+
  "2D2FB2B3B4B5B6B7B8B9E52C255F3E3FBABBBCBDBEBFC0C1C2603A2340273D22"+
  "C3616263646566676869C4C5C6C7C8C9CA6A6B6C6D6E6F707172CBCCCDCECFD0"+
  "D17E737475767778797AD2D3D45BD6D7D8D9DADBDCDDDEDFE0E1E2E3E45DE6E7"+
  "7B414243444546474849E8E9EAEBECED7D4A4B4C4D4E4F505152EEEFF0F1F2F3"+
  "5C9F535455565758595AF4F5F6F7F8F930313233343536373839FAFBFCFDFEFF"].pack("H*")

  def Ebcdic2Ascii(ebcdic)
    ascii = ""
    ebcdic.unpack("C*").each{|c|
	  ascii += EBCDIC_2_ASCII[c]
	}
	ascii
  end
  
  def IsEbcdic(str)
    str.unpack("C*").select{|c| c >= 128}.size > 0
  end
  
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
	  # Force conversion of ebcdic number to ascii number
	  if IsEbcdic(@data)
	    @data = Ebcdic2Ascii(@data)
	  end
	  
      f.set_value(@data.to_i)
      return f
    end
  end

  class StringParser < AbstractParser
    def build_field
      f = Field.new(@id)
	  if IsEbcdic(@data)
	    @data = Ebcdic2Ascii(@data)
	  end
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