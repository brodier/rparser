Before do
  require 'parser'
  puts "Loading Parser"
end

Given(/^a protocol (\w+)$/) do |arg1|
  @p=Parser::DEFAULTS_PARSERS[arg1]
end

Given(/^a message (\w+) \(in hexa\)$/) do |arg1|
  @decoded_msg = @p.parse([arg1].pack("H*")).first
end

When(/^I request subfield on decoded message$/) do
  @res = @decoded_msg.get_deep_field('Champ.3').get_value
end

Then(/^I Should see the value (\d+) of field 3$/) do |arg1|
  assert_equal arg1.to_i , @res, "#{arg1} != #{@res}"
end

