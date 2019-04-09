use v6.d;
use Test;
use vCard::Parser::Actions;
use JSON::Tiny;

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


role Do-made {
    method made {self};
};
isa-ok vCard-to-jCard.made-value([1 but Do-made,2 but Do-made]), "Array";
isa-ok vCard-to-jCard.made-value([1 but Do-made]), 'Int';

my $jCard-multi-value = from-json '["adr", {}, "text",
    [
     "", "",
     ["My Street", "Left Side", "Second Shack"],
     "Hometown", "PA", "18252", "U.S.A."
    ]
]';
cmp-ok Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made, 'eqv', $jCard-multi-value, 'Equality testing - jCard from-json contains an array in property-value' with 'ADR:;;My Street,Left Side,Second Shack;Hometown;PA;18252;U.S.A.';

is-deeply Vcard.parse($_, actions => vCard-to-jCard.new, :rule<parameter>).made, 'type' => <work voice>.Array, 'Parameter TYPE was converted to lowercase and its value is hashArray of values: work, voice' with 'TYPE=work,voice';
is-deeply Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made, $["tel", {:type($["work", "voice"])}, "uri", "tel:+1-111-555-1212"], 'The structure of content-line is following: string-tel, hashArray-type, string-uri, string-value' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
is Vcard.parse($_, actions => vCard-to-jCard.new, :rule<property-value>).made, 'United, States; of A\\merica', 'Formating property-value - testing whether allowed backslashed characters were modified correctly' with 'United\, States\; of A\\merica';
is-deeply Vcard.parse($test-card1, actions => vCard-to-jCard.new).made, from-json($test-jCard);#error
is Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made[1], "${:group("MyGroup")}", 'Jcard contains a group parameter' with 'MyGroup.ORG:Bubba Gump Shrimp Co.';

my %type-of-property-value = %(
    'x-qq:21588891' => 'unknown',
    'group.X-prop:tel:454' => 'unknown',
    'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212' => 'uri',
    'EMAIL;PID=4.2,5.1:jdoe@example.com' => 'text',
    'EMAIL;PID=4.2,5.1;VALUE=date:jdoe@example.com' => 'date',
    'ANNIVERSARY:20090808T1430-0500' => 'date-and-or-time',
);
for %type-of-property-value.pairs {
    is my $tmp = Vcard.parse($_.key, actions => vCard-to-jCard.new, :rule<content-line>).made[2], $_.value, "A type of property-value for: $/ is: $tmp";
};

done-testing;