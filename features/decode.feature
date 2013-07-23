Feature: Get Field 3 in message ACB2A
 In order to get processing code of an authorisation request
 I want to have the value of field 3
 
 Scenario Outline: Decode Message
   Given a protocol <p>
   And a message <m> (in hexa)
   When I request subfield on decoded message
   Then I Should see the value <v> of field 3
   Examples:
     |p|m|v|
     |MSG_ACB2A|01002000000000000000123456|123456|
     |MSG_ACB2A|01002000000000000000000000|000000|
