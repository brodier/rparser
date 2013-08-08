#!/usr/bin/ruby
require 'rubygems'
require 'parser'

include Parser

codecs=DEFAULTS_PARSERS
msg_cis = ["30313030f23c4601a8e182080000000000000002313635323934333430343038323130393635303030303030303030303030303030363235313230343038353935393030323030353039353933303132303431363036393430323035313030313036303132383736303632303033353133373532393433343034303832313039363544313630363230313133333639373837393030303031323132303030323132303430303030333139323037393431333220202020202020204c4120504f535445204c39343133323020393420204c20204c41564152454e4e45535448204652413030315239373830383682023800950500000080009c01009f10120110a58003020000e0fc00000000099400ff9f2608a1fdbaa28fae25fe9f2701809f3602002a9f370450bdbe449a031212045f2a0209789f02060000000006259f1a0202503032363130313030303030303135303032353030303030303030303030303135414131313531333031323230303431"].pack("H*")
f,r= codecs["MSG_CIS"].parse(msg_cis)

puts "Field  :" + f.to_yaml
puts "Remain :" + r.unpack("H*").first
 
 
msg_614 = ["061400200140020400000142800670400002303030308fdf58000731363030303330df5800073137" +
           "3030303031df58000731383131313130df58000731393030303130df58000732303030303230df58" +
           "000732313030303130df58000732323030303130df58000732333030303130df5800073235303030" +
           "3031df58000732363030303031df58000732373030303630df58000732383030303031df58000732" +
           "393030303130"].pack("H*")
msg_246 = ["02467038064006020640104970401843527043170000000000005000000001103553080510511100" +
           "00200001313134323133383030302130313030343135313030353030313430373030323133313030" +
           "303630303030303114303035333235304330303030303030333237393879008200023d00008e000e" +
           "00000000000000000103040302035f2400031411305f2500031210019f060007a00000004210109f" +
           "070002ff009f0d0005bc400480009f0e00050010b800009f0f0005bc600498009f100007064f0a03" +
           "6400029f260008f03c17a9e74104bd9f270001409f360002002edf730001323f0095000500000080" +
           "00009c0001179f33000360b8c09f3400030103029f37000429624a2fff0d0005f870fca870ff0e00" +
           "051010500070ff0f0005f870fcf870"].pack("H*")
           
msg_804 = [ "08048038018100c60000200000000000000000000115595708" +
            "06086280140b04970112004131333732333938443039393734" +
            "303220202020202020204bdf50000c31343335333037363035" +
            "3035df510003303031df5200023130df54000131df5d000e30" +
            "35303038363030383837353536df5e00083133373233393844" +
            "df5f0007303939373430322f30373030323133313630303831" +
            "31303030303030313830303336333834383031344130303030" +
            "3030303432323031300000"].pack("H*")

f,r= codecs["MSG_TCB2A"].parse(msg_614)

puts "Field  :" + f.to_yaml
puts "Remain :" + r.unpack("H*").first

f,r= codecs["MSG_TCB2A"].parse(msg_246)

puts "Field  :" + f.to_yaml
puts "Remain :" + r.unpack("H*").first

f,r= codecs["MSG_TCB2A"].parse(msg_804)

puts "Field  :" + f.to_yaml
puts "Remain :" + r.unpack("H*").first
