grammar Vcard {
    #required
    token version  { :i 'Version:4.0' };
    token begin    { :i 'BEGIN:VCARD' };
    token endI     { :i 'END:VCARD'   };

    #logic
    token content-line  { [<group> '.']? <property-name> [ ';' <parameter>]* ':' <property-value>+ % <[;]> };

    token group         { <.alpha-num-dash>+ };
        token alpha-num-dash { \w | '-' };

    token property-value  { <property-simple-value>+ % ',' };
        token property-simple-value  { [ \\ . | <-[\n;,]> ]* };

    proto token property-name {*}
    token property-name:sym<source>          { :i source }
    token property-name:sym<kind>            { :i kind }
    token property-name:sym<fn>              { :i fn }
    token property-name:sym<n>               { :i n }
    token property-name:sym<nickname>        { :i nickname }
    token property-name:sym<photo>           { :i photo }
    token property-name:sym<bday>            { :i bday }
    token property-name:sym<anniversary>     { :i anniversary }
    token property-name:sym<gender>          { :i gender }
    token property-name:sym<adr>             { :i adr }
    token property-name:sym<tel>             { :i tel }
    token property-name:sym<email>           { :i email }
    token property-name:sym<impp>            { :i impp }
    token property-name:sym<lang>            { :i lang }
    token property-name:sym<tz>              { :i tz }
    token property-name:sym<geo>             { :i geo }
    token property-name:sym<title>           { :i title }
    token property-name:sym<role>            { :i role }
    token property-name:sym<logo>            { :i logo }
    token property-name:sym<org>             { :i org }
    token property-name:sym<member>          { :i member }
    token property-name:sym<related>         { :i related }
    token property-name:sym<categories>      { :i categories }
    token property-name:sym<note>            { :i note }
    token property-name:sym<prodid>          { :i prodid }
    token property-name:sym<rev>             { :i rev }
    token property-name:sym<sound>           { :i sound }
    token property-name:sym<uid>             { :i uid }
    token property-name:sym<clientpidmap>    { :i clientpidmap }
    token property-name:sym<url>             { :i url }
    token property-name:sym<key>             { :i key }
    token property-name:sym<fburl>           { :i fburl }
    token property-name:sym<caladruri>       { :i caladruri }
    token property-name:sym<caluri>          { :i caluri }
    token property-name:sym<xml>             { :i xml }
    token property-name:sym<birthplace>      { :i birthplace }
    token property-name:sym<deathplace>      { :i deathplace }
    token property-name:sym<deathdate>       { :i deathdate }
    token property-name:sym<expertise>       { :i expertise }
    token property-name:sym<hobby>           { :i hobby }
    token property-name:sym<interest>        { :i interest }
    token property-name:sym<org-directory>   { :i org'-'directory }
    token property-name:sym<x-name>          { <[xX]> '-' <.alpha-num-dash>+ }

    token parameter  { <parameter-name> '=' <parameter-value>+ % ',' };
     token parameter-value  { <q-safe-char> | <safe-char> };
        token q-safe-char     { [<["]> <(] ~ [)> <["]>] <-["]>+ };
        token safe-char       { <-:C-[:;,"]>+ };

    proto token parameter-name {*}
    token parameter-name:sym<mediatype>              { :i mediatype }
    token parameter-name:sym<label>                  { :i label }
    token parameter-name:sym<languague>              { :i languague }
    token parameter-name:sym<value>                  { :i value }
    token parameter-name:sym<pref>                   { :i pref }
    token parameter-name:sym<altid>                  { :i altid }
    token parameter-name:sym<type>                   { :i type }
    token parameter-name:sym<pid>                    { :i pid }
    token parameter-name:sym<geo>                    { :i geo }
    token parameter-name:sym<index>                  { :i index }
    token parameter-name:sym<level>                  { :i level }
    token parameter-name:sym<group>                  { :i group }
    token parameter-name:sym<tz>                     { :i tz }
    token parameter-name:sym<sort-as>                { :i sort'-'as }
    token parameter-name:sym<calscale>               { :i calscale }
    token parameter-name:sym<property-name:x-name>     { <.sym> }


    token TOP { [<begin> \n <version> \n <content-line>+ %% \n <endI>]+ % \n }
}

class vCard-to-jCard {
    my %default-type-of-value = %(
        source => 'uri',
        photo => 'uri',
        member => 'uri',
        tel => 'uri',
        geo => 'uri',
        url => 'uri',
        key => 'uri',
        caladruri => 'uri',
        fburl => 'uri',
        caluri => 'uri',
        related => 'uri',
        logo => 'uri',
        sound => 'uri',
        uid => 'uri',
        clientpidmap => 'uri',
        impp => 'uri',
        org-directory => 'uri',
        adr => 'text',
        email => 'text',
        org => 'text',
        birthplace => 'text',
        deathplace => 'text',
        expertise => 'text',
        hobby => 'text',
        interest => 'text',
        title => 'text',
        role => 'text',
        categories => 'text',
        kind => 'text',
        note => 'text',
        prodid => 'text',
        xml => 'text',
        fn => 'text',
        n => 'text',
        nickname => 'text',
        gender => 'text',
        tz => 'text',
        bday => 'date-and-or-time',
        anniversary => 'date-and-or-time',
        deathdate => 'date-and-or-time',
        lang => 'language-tag',
        rev => 'timestamp',
    );
    method made-value ($_) {
            when $_.elems > 1 {$_».made}
            default {$_[0].made}
    };
    method TOP ($/) {
        make ["vcard",
          [
            ["version", %(), "text", "4.0"],
            |$<content-line>».made;
          ]
        ]
    };
    method content-line ($/) {
        #preparing hashArray of parameters
        my %parameter = %($<parameter>».made);
        my $parameter-of-type-value = %parameter<value>[0] // %default-type-of-value{$<property-name>.lc} // 'unknown';
        %parameter<value>:delete;

        #add a group to hashArray of parameters if exists
        with $<group> {
            %parameter<group> = $_.Str
        }

        make [
            $<property-name>.lc,     
            %parameter,
            $parameter-of-type-value,
            $.made-value($<property-value>)
        ]
    };
    method property-simple-value ($/) {
        make $/.subst( / \\ )> <[,;]> /, Q{}, :g ).subst(/ \\n/, "\n", :g)
    };
    method property-value ($/) {
        make $.made-value($<property-simple-value>)
    };
    method parameter ($/) {
        make $<parameter-name>.lc => $.made-value($<parameter-value>); 
    };
    method parameter-value ($/) {
        with $<q-safe-char> {make $_.made}
        orwith $<safe-char> {make $_.Str}
    };
    method q-safe-char ($/) {
        make $/.subst(/ \\ )> <[,\;]> /, Q{}, :g ).subst(/ \\n /, "\n", :g)
    };
}

use Test;
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

#is-deeply Vcard.parse($test-card1, actions => vCard-to-jCard.new).made, from-json($test-jCard);
is Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made[1], "${:group("MyGroup")}", 'Jcard contains a group parameter' with 'MyGroup.ORG:Bubba Gump Shrimp Co.';
is Vcard.parse($_, :rule<content-line>).<group>, "MyGroup", 'Group occurance test.' with 'MyGroup.ORG;pref=5:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-name>, 'Missing the property-name is not allowed.' with ';pref=1:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-name>, 'Usage of non existent property-name is not allowed.' with 'preb:Bubba Gump Shrimp Co.';
nok Vcard.parse($_, :rule<content-line>).<property-value>, 'Missing the parameter-value is not allowed.' with 'MyGroup.ORG;pref=5';
is-deeply Vcard.parse($_, actions => vCard-to-jCard.new, :rule<parameter>).made, 'type' => <work voice>.Array, 'Parameter TYPE was converted to lowercase and its value is hashArray of values: work, voice' with 'TYPE=work,voice';
is-deeply Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made, $["tel", {:type($["work", "voice"])}, "uri", "tel:+1-111-555-1212"], 'The structure of content-line is following: string-tel, hashArray-type, string-uri, string-value' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
is Vcard.parse($_, actions => vCard-to-jCard.new, :rule<property-value>).made, 'United, States; of A\\merica', 'Formating property-value - testing whether allowed backslashed characters were modified correctly' with 'United\, States\; of A\\merica';
ok Vcard.parse($_, :rule<property-name>), "A property name can be $_" for <email Email eMail n N fn fN>;
like Vcard.parse($_, :rule<content-line>).<property-value>,/^Bubba/ with 'ORG:Bubba Gump Shrimp Co.';
like Vcard.parse($_, :rule<content-line>).<property-value>,/^\d+$/ with 'x-qq:21588891';
is Vcard.parse($_, :rule<content-line>).<property-value>».Str,('', 'Gump', 'Forrest', '', 'Mr.',''), 'Found 6 propertyValues, including 3 empty in border testing.' with 'N:;Gump;Forrest;;Mr.;';
# like Vcard.parse($_, :rule<content-line>).<value>,/\n \h+/ with 'x-qq:215
#  88891';

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

is Vcard.parse($_, :rule<content-line>).<parameter>, <TYPE=work,voice VALUE=uri>, 'Found parameters: TYPE with values=work, voice; Value with value=uri.' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
like Vcard.parse($_, :rule<content-line>).<parameter>.[0],/^TYPE/, 'First parameter-name begins with characters TYPE.' with 'ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America';
cmp-ok Vcard.parse($_, :rule<property-value>).<property-simple-value>».Str, 'eqv', ["My Street", "Left Side", "Second Shack"], 'property-value makes an array with three items of a property-simple-value type' with 'My Street,Left Side,Second Shack';

my $jCard-multi-value = from-json '["adr", {}, "text",
    [
     "", "",
     ["My Street", "Left Side", "Second Shack"],
     "Hometown", "PA", "18252", "U.S.A."
    ]
]';
cmp-ok Vcard.parse($_, actions => vCard-to-jCard.new, :rule<content-line>).made, 'eqv', $jCard-multi-value, 'Equality testing - jCard from-json contains an array in property-value' with 'ADR:;;My Street,Left Side,Second Shack;Hometown;PA;18252;U.S.A.';

ok Vcard.parse($_), "Testcard: \n\n$/ \n\n...parsed successfully\n" for $test-card1, $test-card2, $test-card3;

done-testing;


#https://tools.ietf.org/html/rfc6350#page-73 - Vcard
#https://tools.ietf.org/html/rfc7095         - Jcard
#https://www.iana.org/assignments/vcard-elements/vcard-elements.xhtml#value-data-types - Iana