use v6.d;
use Test;
use vCard::Parser::Grammar;

my $test-card1 = 
Q[BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
FN:Forrest Gump
ORG:Bubba Gump Shrimp Co.
TITLE:Shrimp Man
PHOTO;MEDIATYPE=image/gif:http://www.example.com/dir_photos/my_photo.gif
TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212
TEL;TYPE=home,voice;VALUE=uri:tel:+1-404-555-1212
ADR;TYPE=work;PREF=1;LABEL="100 Waters Edge\nBaytown\, LA 30314\nUnited States of America":;;100 Waters Edge;Baytown;LA;30314;United States of America
ADR;TYPE=home;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America
EMAIL:forrestgump@example.com
x-qq:21588891
END:VCARD];
#REV:20080424T195243Z
my $test-card2 =
Q[BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
END:VCARD];
my $test-card3 = 
Q[BEGIN:VCARD
VERSION:4.0
KIND:group
FN:The Doe family
MEMBER:urn:uuid:03a0e51f-d1aa-4385-8a53-e29025acd8af
MEMBER:urn:uuid:b8767877-b4a1-4c70-9acc-505d3819e519
END:VCARD
BEGIN:VCARD
VERSION:4.0
FN:John Doe
UID:urn:uuid:03a0e51f-d1aa-4385-8a53-e29025acd8af
END:VCARD
BEGIN:VCARD
VERSION:4.0
FN:Jane Doe
UID:urn:uuid:b8767877-b4a1-4c70-9acc-505d3819e519
END:VCARD];
my $test-jCard = '["vcard",
  [
    ["version", {}, "text", "4.0"],
    ["n", {}, "text", ["Gump", "Forrest", "", "Mr.", ""]],
    ["fn", {}, "text", "Forrest Gump"],
    ["org", {}, "text", "Bubba Gump Shrimp Co."],
    ["title", {} ,"text", "Shrimp Man"],
    ["photo", {"mediatype":"image/gif"}, "uri", "http://www.example.com/dir_photos/my_photo.gif"],
    ["tel", {"type":["work", "voice"]}, "uri", "tel:+1-111-555-1212"],
    ["tel", {"type":["home", "voice"]}, "uri", "tel:+1-404-555-1212"],
    ["adr",
      {"label":"100 Waters Edge\nBaytown, LA 30314\nUnited States of America", "type":"work", "pref":"1"},
      "text",
      ["", "", "100 Waters Edge", "Baytown", "LA", "30314", "United States of America"]
    ],
    ["adr",
      {"label":"42 Plantation St.\nBaytown, LA 30314\nUnited States of America", "type":"home"},
      "text",
      ["", "", "42 Plantation St.", "Baytown", "LA", "30314", "United States of America"]
    ],
    ["email", {}, "text", "forrestgump@example.com"]
  ]
]';


ok Vcard.parse($_), "Testcard: \n\n$/ \n\n..........\n" for $test-card1, $test-card2, $test-card3;

ok Vcard.parse($_, :rule<property-name>), "A property name can be $_" for <email Email eMail n N fn fN>;
like Vcard.parse($_, :rule<content-line>).<property-value>,/^Bubba/ with 'ORG:Bubba Gump Shrimp Co.';
like Vcard.parse($_, :rule<content-line>).<property-value>,/^\d+$/ with 'x-qq:21588891';
like Vcard.parse($_, :rule<content-line>).<parameter>».<parameter-name>, /^X'-'\w+$/ with 'x-prop;X-param=val:Joseph Com.';
is Vcard.parse($_, :rule<content-line>).<property-value>».Str,('', 'Gump', 'Forrest', '', 'Mr.',''), 'Found 6 propertyValues, including 3 empty in border testing.' with 'N:;Gump;Forrest;;Mr.;';
# like Vcard.parse($_, :rule<content-line>).<value>,/\n \h+/ with 'x-qq:215
#  88891';

is Vcard.parse($_).<vcard>.elems, 3,"vCard contains 3 vcards." with $test-card3;
is Vcard.parse($_).<vcard>.elems, 1,"vCard contains 1 vcard." with $test-card2;

is Vcard.parse($_, :rule<content-line>).<group>, "MyGroup", 'Group occurance test.' with 'MyGroup.ORG;pref=5:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-name>, 'Missing the property-name is not allowed.' with ';pref=1:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-name>, 'Usage of non existent property-name is not allowed.' with 'preb:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-value>, 'Missing the parameter-value is not allowed.' with 'MyGroup.ORG;pref=5';

is Vcard.parse($_, :rule<content-line>).<parameter>, <TYPE=work,voice VALUE=uri>, 'Found parameters: TYPE with values=work, voice; Value with value=uri.' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
like Vcard.parse($_, :rule<content-line>).<parameter>.[0],/^TYPE/, 'First parameter-name begins with characters TYPE.' with 'ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America';
cmp-ok Vcard.parse($_, :rule<property-value>).<property-simple-value>».Str, 'eqv', ["My Street", "Left Side", "Second Shack"], 'property-value makes an array with three items of a property-simple-value type' with 'My Street,Left Side,Second Shack';

done-testing;