require 'ParserTools'
include Parser

$codecs = {}
$codecs = load_parsers_from_xml('test_codecs.xml')

def test(parser,buffer)
  puts "Test parsing #{buffer} with #{parser} parser"
  c = $codecs[parser]
  f,r = c.parse([buffer].pack("H*"))
  puts "Parsed field : ", f.to_yaml
  puts "Remaining data <" + r + ">"
end

test('n7',"01234567")
test('n7',"0123456789FFFFFFFFFF")
test('bitmap8',"200000000000000001234567")
test('n4',"0100")
test('iso8583',"0100200000000000000001234567")
test('iso8583',"0100600000000000000010444433332222111101234567")
test('cbComH',"C106050401201120")
test('cbCom',"C106050401201120")
test('cbCom',"C10A050401201120070200170100600000000000000010444433332222111101234567")
test('cbComIP',"00000023C10A05040120112007020017010060000000000000001044443333222211110123456752454D41494E494E472E2E2E")
test('ber',"950504000000809F100A11223344556677889900")
