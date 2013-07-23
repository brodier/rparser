module Parser
  class PrefixedlengthParser < AbstractParser
    def initialize(att)
      @length_parser = get_codec_from_ref('length',att)
      @value_parser = get_codec_from_ref('content',att)
      @id = att['id']
    end
	
	def get_length(length_field)
		length_field.get_value.to_i
	end
	
    def parse(buffer)
      l, buf = @length_parser.parse(buffer)
	    len = get_length(l)
	    if len == 0
	      f = Field.new
		    f.set_id(@id)
		    f.set_value(nil)
		    return f,buf
	    else
	      begin
		      f,remain = @value_parser.parse_with_length(buf,len)
		    rescue => e
		      LogParser.error "Error in #{@id} parser \n #{e.message}\n#{e.backtrace.join(10.chr)}"
		      raise ParsingException, e.message
		    end
        
        f.set_id(@id)
        return f,remain
	    end
    end
	
	def build_field
	  begin
	    f,r = parse(@data)
	  rescue ErrorBufferUnderflow => e
	    raise ParsingException, e.message
	  end
	  # log error if r != ""
	  return f
	end
  end

  class HeaderlengthParser < PrefixedlengthParser
    def initialize(att)
	  @path = att['length'] # length attribute contain the path for length field in header
	  @separator = @path.slice!(0).chr # first character contain the separator
	  att['length'] = att['header'] # Prefixedlength constructor used length attribute for header codec
	  super(att)
    end
	
	  def get_length(header_field)
	  	length_field = header_field.get_deep_field(@path,@separator)
	  	if length_field.nil?
	  	  return 0
	  	else
	  	  length_field.get_value.to_i
	  	end
	  end

	  def parse(buffer)
	    f = Field.new
	    f.set_id(@id)
	    head, buf = @length_parser.parse(buffer)
	    head.set_id(@length_parser.id)
	    f.add_sub_field(head)
	    len = get_length(head)
	    if len == 0
	      return f,buf
	    else
	      val,remain = @value_parser.parse_with_length(buf,len)
        val.set_id(@value_parser.id)
	  	  f.add_sub_field(val)
        return f,remain
	    end
	  end
  end  
end