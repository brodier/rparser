module Parser
  class PackedParser < AbstractParser
    def get_pck_length(length)
      ((length + 1) / 2)
    end
	
    def parse_with_length(buf,length)
      init_data(buf,get_pck_length(length))
      return build_field,@remain
    end
    
    def parse(buf)
      return parse_with_length(buf,@length)
    end
  end

  class NumpckParser < PackedParser
    def build_field
      f = Field.new(@id)
      f.set_value(@data.unpack("H*").first.to_i)
      return f
    end
  end
  
  class StrpckParser < PackedParser
    def build_field
      f = Field.new(@id)
      f.set_value(@data.unpack("H*").first)
      return f
    end
  end

end