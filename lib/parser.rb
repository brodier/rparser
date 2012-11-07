module Parser
  require 'parser/exceptions'
  require 'parser/fields'
  require 'parser/abstract_parser'
  require 'parser/prefix_length_parsers'
  require 'parser/composed_parsers'
  require 'parser/simple_parsers'
  require 'parser/packed_parsers'
  
  require 'rexml/document'
  include REXML
  
  def get_defaults_parsers
    files_list = Dir[Gem::Specification.find_by_name('parser').gem_dir + '/rsc/**/*.xml']
	codecs = {}
	files_list.each{|file|
	  codecs.merge!(load_parsers_from_xml(file))
	}
	return codecs
  end
  
  def load_parsers_from_xml(xml_file)
    codecs = {}
  	xml_def = Document.new(IO.read(xml_file)).root
  	xml_def.elements.select{|c| c.name == 'codec'}.each{|codec|
  	  att = {}
  	  codec.attributes.each{|k,v| att[k]=v}
  	  type = att.delete("type")
  	  if type.nil?
  		raise ErrorBuildingParser, "Unable to build codec without a type"
  	  else
  		codecClass = eval(codec.attributes["type"].capitalize + 'Parser')
  	  end
  	  
  	  codecId = att['id']
  	  if codecId.nil?
  		raise ErrorBuildingParser, "Unable to load codec without an id"
  	  end
  	  att['codecs'] = codecs
  	  codecs[codecId] = codecClass.new(att)
	  curr_codec = codecs[codecId]
	  codec.elements.select{|sc| sc.name == 'subcodec'}.each{ |sc|
	    curr_codec.add_subparser(sc.attributes['id'],codecs[sc.attributes['ref']])
	  }
	  if curr_codec.instance_of?(BitmapParser)
		codec.elements.select{|sc| sc.name == 'extention'}.each{|extention|
		  curr_codec.add_extended_bitmap(extention.attributes['ref'])
		}
	  end
  	}
  	return codecs
  end

end
