use v6.d;
use Test;
use vCard::Parser::Grammar;

my $vcard-grammar = vCard::Parser::Grammar.new;


ok $vcard-grammar.parsefile($_), "Testcard: \n\n$/ \n\n..........\n" for './t/test-cards/test-card1.vcard', './t/test-cards/test-card2.vcard', './t/test-cards/test-card4.vcard';

ok $vcard-grammar.parse($_, :rule<property-name>), "A property name can be $_" for <email Email eMail n N fn fN>;
like $vcard-grammar.parse($_, :rule<content-line>).<property-value>,/^Bubba/ with 'ORG:Bubba Gump Shrimp Co.';
like $vcard-grammar.parse($_, :rule<content-line>).<property-value>,/^\d+$/ with 'x-qq:21588891';
like $vcard-grammar.parse($_, :rule<content-line>).<parameter>».<parameter-name>, /^X'-'\w+$/ with 'x-prop;X-param=val:Joseph Com.';
is $vcard-grammar.parse($_, :rule<content-line>).<property-value>».Str,('', 'Gump', 'Forrest', '', 'Mr.',''), 'Found 6 propertyValues, including 3 empty in border testing.' with 'N:;Gump;Forrest;;Mr.;';
# like $vcard-grammar.parse($_, :rule<content-line>).<value>,/\n \h+/ with 'x-qq:215
#  88891';

is $vcard-grammar.parsefile($_).<vcard>.elems, 3,"$vcard-grammar contains 3 vcards." with './t/test-cards/test-card4.vcard';
is $vcard-grammar.parsefile($_).<vcard>.elems, 1,"$vcard-grammar contains 1 vcard." with './t/test-cards/test-card2.vcard';

is $vcard-grammar.parse($_, :rule<content-line>).<group>, "MyGroup", 'Group occurance test.' with 'MyGroup.ORG;pref=5:Bubba Gump Shrimp Co.';
nok $vcard-grammar.parse($_, :rule<content-line>).<property-name>, 'Missing the property-name is not allowed.' with ';pref=1:Bubba Gump Shrimp Co.';
nok $vcard-grammar.parse($_, :rule<content-line>).<property-name>, 'Usage of non existent property-name is not allowed.' with 'preb:Bubba Gump Shrimp Co.';
nok $vcard-grammar.parse($_, :rule<content-line>).<property-value>, 'Missing the parameter-value is not allowed.' with 'MyGroup.ORG;pref=5';

is $vcard-grammar.parse($_, :rule<content-line>).<parameter>, <TYPE=work,voice VALUE=uri>, 'Found parameters: TYPE with values=work, voice; Value with value=uri.' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
like $vcard-grammar.parse($_, :rule<content-line>).<parameter>.[0],/^TYPE/, 'First parameter-name begins with characters TYPE.' with 'ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America';
cmp-ok $vcard-grammar.parse($_, :rule<property-value>).<property-simple-value>».Str, 'eqv', ["My Street", "Left Side", "Second Shack"], 'property-value makes an array with three items of a property-simple-value type' with 'My Street,Left Side,Second Shack';

done-testing;
