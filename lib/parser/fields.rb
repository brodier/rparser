module Parser
  class Field
    def initialize(id="*")
      @id = (id.nil? ? "*" : id)
      @value = nil
    end

    def get_id
      @id
    end
    
    def set_id(id)
      @id = id
    end

    def set_value(value)
      @value = value
    end
    
    def get_value
      @value
    end
    
    def add_sub_field(sf)
      @value = {} if @value.nil?
	  raise "Add impossible on not Hash valued field" unless @value.kind_of? Hash
	  @value[sf.get_id] = [@value.size,[]] if @value[sf.get_id].nil?
	  @value[sf.get_id].last << sf
    end
    
	def get_sf_recursivly(ids)
		if(ids.size == 1 && @value.kind_of?(Hash))
			return get_sub_field(ids.first)
		elsif (ids.size > 1 && @value.kind_of?(Hash))
			id = ids.slice!(0)
			return get_sub_field(id).get_sf_recursivly(ids)
		else
			return nil
		end
	end
	
	def get_deep_field(path,separator='.')
		get_sf_recursivly(path.split(separator))
	end
    
	def get_sub_field(id)
	  sf_rec = @value[id]
	  if sf_rec.nil?
	    return nil
	  else
	    raise MultipleFieldError if sf_rec.last.size > 1
		return @value[id].last.first
	  end
    end

    def get_sub_fields(id)
      if @value[id].nil?
        return nil
      else
        return @value[id].last
      end
    end
  
   def to_yaml(tab="")
     s = ""
     if @value.kind_of? Hash
	   tab += "  "
	   s += @id +": \n" 
	   @value.to_a.
		   sort{|a,b| 
			 a.last.first <=> b.last.first
		   }.each{|k,rk_n_flds|
		      rk_n_flds.last.each{|sf|
			    s += tab + sf.to_yaml(tab)
			  }
		   }
	   return s
	 else
	   @id + ": " + @value.to_s + "\n"
	 end
   end   
  end
  
end