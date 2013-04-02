module Parser
  require 'yaml'
  require 'rexml/document'
  require 'log4r'
  include Log4r
  include REXML
  
  require 'parser/exceptions'
  require 'parser/fields'
  require 'parser/abstract_parser'
  require 'parser/prefix_length_parsers'
  require 'parser/composed_parsers'
  require 'parser/simple_parsers'
  require 'parser/packed_parsers'
  
  LogParser = Logger.new 'parserLog'
  LogParser.outputters = Outputter.stdout

  if defined?(PARSER_CONST).nil?
    PARSER_CONST = true
    PROTOCOL_HASH = {'MSG_CBAE_IP' => 1,
	                        'MSG_CIS_IP' => 2,
							'MSG_CBCOM_ACB2A' => 3}
    PROTOCOL_NAME = {1 => 'MSG_CBAE_IP',
	                        2 => 'MSG_CIS_IP',
							3 => 'MSG_CBCOM_ACB2A'}
							
    ITM_PATH = {1 => 'MSG_CBAE.ITM',
                       2 =>	'MSG_CIS.ITM',
					   3 => 'MSG_ACB2A.ITM'}

   CR_PATH   = {1 => 'MSG_CBAE.Champ.39',
                       2 =>	'MSG_CIS.DE.39',
					   3 => 'MSG_ACB2A.Champ.39'}
					   
	FIELDS_PATHS = {:cardholder => { 1 => 'MSG_CBAE.Champ.2',
						  2 => 'MSG_CIS.DE.2',
						  3 => 'MSG_ACB2A.Champ.2'},
	                    :merchant => { 1 => 'MSG_CBAE.Champ.42',
						  2 => 'MSG_CIS.DE.42',
						  3 => 'MSG_ACB2A.Champ.42'},
						:terminal => { 1 => 'MSG_CBAE.Champ.41',
						  2 => 'MSG_CIS.DE.41',
						  3 => 'MSG_ACB2A.Champ.41'}}
  end
  
  
  def self.get_defaults_parsers
    files_list = Dir[Gem::Specification.find_by_name('parser').gem_dir + '/rsc/**/*.xml']
	LogParser.info "Loading default parser in files [#{files_list.join(',')}]"

        codecs = {}
	files_list.each{|file|
	  codecs.merge!(load_parsers_from_xml(file))
	}
	return codecs
  end
  
  def self.load_parsers_from_xml(xml_file)
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

  if defined?(DEFAULTS_PARSERS).nil?
    DEFAULTS_PARSERS = get_defaults_parsers
  end
end
