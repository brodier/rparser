module Parser
  class AbstractParser
    attr_reader :id
    def initialize(att)
        @length = att['length'].to_i
        @id = att['id']
    end

	def get_codec_from_ref(key,hash)
	 c = hash['codecs'][hash[key]] 
	 if c.nil?
	   raise ErrorBuildingParser, "Invalid codec reference in #{key} attribute for codec #{hash['id']}"
	 else
	   return c
	 end
	end

    def build_field
      raise ParsingException,"Abstract Parser"
    end
    
    def parse_with_length(buf,length)
      init_data(buf,length)
      return build_field,@remain
    end
    
    def parse(buf)
      init_data(buf,@length)
      return build_field,@remain
    end    
    
    def init_data(buf,length)
	  length = 0 if length.nil?
      if(length != 0)
	    if buf.length < length
	      raise ErrorBufferUnderflow, "Not enough data for parsing #{@id} (#{length}/#{buf.length})"
	    end
        @data = buf[0,length]
        @remain = buf[length,buf.length]
      else
        @data = buf
        @remain = ""
      end
    end
    
    def add_subparser(id_field,parser)
	  if parser.nil?
	    raise ErrorBuildingParser, "Invalid codec reference in subparser #{id_field} for codec #{@id}"
	  end
      if @subParsers.kind_of? Hash
        @subParsers[id_field] = parser 
      end
    end 
	
	def get_sub_parsers
	  return @subParsers
	end
  end
  
  class TagedParser < AbstractParser
    def initialize(att)
      @subParsers = {}
      @tag_codec = get_codec_from_ref('header',att)
	  @id = att['id']
    end
    
    def parse(buffer)
      tag,buf = @tag_codec.parse(buffer)
      f,buf = @subParsers[tag.get_value.to_s].parse(buf)
      f.set_id(tag.get_value.to_s)
      return f,buf
    end
  end

end