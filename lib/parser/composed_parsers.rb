module Parser
  class BitmapParser < AbstractParser
    NB_BITS_BY_BYTE = 8
    def initialize(att)
	  super(att)
      @num_extended_bitmaps=[]
      @subParsers = {}
    end
    
    def add_extended_bitmap(num_extention)
      @num_extended_bitmaps << num_extention.to_i
    end
    
    def parseBitmap(buffer,first_field_num)
      fieldsList = []
      
      bitmapBuffer = buffer[0,@length].unpack("B*").first
      buf = buffer[@length,buffer.length]
      field_num = first_field_num
      while(bitmapBuffer.length > 0)
        fieldsList << field_num if bitmapBuffer.start_with?('1')
        bitmapBuffer.slice!(0)
        field_num += 1
      end
      return fieldsList, buf
    end
    
    def parse(buffer)
      msg = Field.new(@id)
      field_num = 1
      # 1. read bitmap
      fields_list,buf = parseBitmap(buffer,field_num)
      field_num += @length * NB_BITS_BY_BYTE
      # 2. parse each field present
      while fields_list.length > 0
        # get next field number in bitmap
        fieldToParse = fields_list.slice!(0)
        if @num_extended_bitmaps.include?(fieldToParse)
          nextFields,buf = parseBitmap(buf,field_num)
          fields_list = fields_list + nextFields
        elsif @subParsers[fieldToParse.to_s].respond_to?(:parse)
          f,buf = @subParsers[fieldToParse.to_s].parse(buf)
          f.set_id(fieldToParse.to_s)
          msg.add_sub_field(f)
        else
		  f = Field.new("ERR") 
		  f.set_value(buf.unpack("H*").first)
		  msg.add_sub_field(f)
          raise ParsingException,msg.to_yaml + "\nError unknown field #{fieldToParse.to_s} : "
        end
      end
      return msg,buf
    end
  end
  
  class StructParser < AbstractParser
    def initialize(att)
      @id = att['id']
      @subParsers = []
    end
	
	def parse(buf)
	  @length_unknown = true
	  super(buf)
	end

	def parse_with_length(buf,length)
	  @length_unknown = false
	  super(buf,length)
	end

    def build_field
      msg = Field.new(@id)
      working_buf = @data
      @subParsers.each{|id,parser|
		if working_buf.length == 0
		  if @length_unknown
		    raise ErrorBufferUnderflow, "Not enough data for parsing Struct #{@id} stop on field #{id}"
		  else
		    # TO FIX : create specific class for complete struct and partial struct parsing
			# LogParser.warn("Not enough data for parsing #{@id} in build_field")
		  end
		  f = Field.new(id)
		  f.set_value("")
		else 
	      f,working_buf = parser.parse(working_buf)
		end
        f.set_id(id)
        msg.add_sub_field(f)
      }
	  
	  if working_buf.length > 0
	    if @length_unknown 
		  @remain = working_buf 
		else
	      f = Field.new("PADDING")
		  f.set_value(working_buf.unpack("H*"))
		  msg.add_sub_field(f)
		end
	  end
      
	  return msg
    end
	
	def add_subparser(id_field,parser)
	  if parser.nil?
	    raise ErrorBuildingParser, "Invalid codec reference in subparser #{id_field} for codec #{@id}"
	  end
      @subParsers << [id_field, parser]
    end 
	
  end

  class TlvParser < PrefixedlengthParser
    
    def initialize(att)
      super(att)
      @tag_parser = get_codec_from_ref('header',att)
      @subParsers = {}
    end
    
    def parse_with_length(buf,length)
      init_data(buf,length)
	  f,r = parse(@data)
	  # log warn remain data in tlv parse_with_length
      return f,@remain
    end
	
    def parse(buffer)
      msg = Field.new(@id)
      while(buffer.length > 0)
        tag,buffer = @tag_parser.parse(buffer)
        if @subParsers[tag.get_value.to_s].nil?
          val,buffer = super(buffer)
        else
          l,buf = @length_parser.parse(buffer)
          val,buffer = @subParsers[tag.get_value.to_s].parse_with_length(buf,l.get_value.to_i)
        end
        val.set_id(tag.get_value.to_s)
        msg.add_sub_field(val)
      end
      return msg,buffer
    end
  end
  
  class BertlvParser < AbstractParser
    def initialize(att)
	  @id = att['id']
	end
	
	def read_length
	 b = @data.slice!(0)
	 if b & 0x80 == 0x80
	   ll = b & 0x7F 
	   lb = @data[0,ll]
	   @data = @data[ll,@data.length]
	   length = 0
	   while(lb.length > 0)
	     length *= 256
		 length += lb.slice!(0)
	   end
	   return length
	 else
	   return b
	 end
	end
	
	def read_tag
	  b = 0
	  while b == 0 || b == 255
	    b = @data.slice!(0)
	  end
	  
	  tag = b.chr
	  
	  if b & 0x1F == 0x1F
	    nb = 0x80
	    while nb & 0x80 == 0x80
	      nb = @data.slice!(0)
		  tag += nb.chr
		end
	  end
	  return tag.unpack("H*").first.upcase
	end

	def read_value(length)
	  raise ErrorBufferUnderflow,"Not enough data for parsing BER TLV #{@id} length value #{length} remaining only #{@data.length}" if length > @data.length
	  value = @data[0,length]
	  @data = @data[length,@data.length]
	  return value.unpack("H*").first.upcase
	end
	
	def build_field
	  msg = Field.new(@id)
	  while @data.length > 0
	    f = Field.new(read_tag)
		f.set_value(read_value(read_length))
		msg.add_sub_field(f)
	  end
	  return msg
	end
	
	def parse(buffer)
	  @data = buffer
	  return build_field,""
	end
  end
end