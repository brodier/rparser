require 'parser'
include Parser
VisaDecoder = DEFAULTS_PARSERS['MSG_VISA_IP']

unpack_msg = "1600000032123456654321000000000000000000000001007000000000000000104970123456789112000000000000001000"
msg = [unpack_msg].pack("H*")
f,r = VisaDecoder.parse(msg)

puts f.to_yaml
puts "remaining #{r.unpack("H*").first}"
