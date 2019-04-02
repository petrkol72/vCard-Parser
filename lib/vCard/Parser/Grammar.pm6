grammar Vcard {
    #required
    token version        { :i 'Version:4.0' };
    token begin          { :i 'BEGIN:VCARD' };
    token endI           { :i 'END:VCARD' };

    #logic
    token contentLine    { [<group> '.']? <propertyName> [ ';' <parameter>]* ':' <propertyValue>+ % ';' };

    token group          { <.alphaNumDash>+ };
        token alphaNumDash   { \w | '-' };

    token propertyValue { <-[\n;]>* };

    proto token propertyName {*}
    token propertyName:sym<source>          { :i source }
    token propertyName:sym<kind>            { :i kind }
    token propertyName:sym<fn>              { :i fn }
    token propertyName:sym<n>               { :i n }
    token propertyName:sym<nickName>        { :i nickName }
    token propertyName:sym<photo>           { :i photo }
    token propertyName:sym<bDay>            { :i bDay }
    token propertyName:sym<anniversary>     { :i anniversary }
    token propertyName:sym<gender>          { :i gender }
    token propertyName:sym<adr>             { :i adr }
    token propertyName:sym<tel>             { :i tel }
    token propertyName:sym<email>           { :i email }
    token propertyName:sym<impp>            { :i impp }
    token propertyName:sym<lang>            { :i lang }
    token propertyName:sym<tz>              { :i tz }
    token propertyName:sym<geo>             { :i geo }
    token propertyName:sym<title>           { :i title }
    token propertyName:sym<role>            { :i role }
    token propertyName:sym<logo>            { :i logo }
    token propertyName:sym<org>             { :i org }
    token propertyName:sym<member>          { :i member }
    token propertyName:sym<related>         { :i related }
    token propertyName:sym<categories>      { :i categories }
    token propertyName:sym<note>            { :i note }
    token propertyName:sym<prodid>          { :i prodid }
    token propertyName:sym<rev>             { :i rev }
    token propertyName:sym<sound>           { :i sound }
    token propertyName:sym<uid>             { :i uid }
    token propertyName:sym<cliendPidMap>    { :i cliendPidMap }
    token propertyName:sym<url>             { :i url }
    token propertyName:sym<key>             { :i key }
    token propertyName:sym<fbUrl>           { :i fbUrl }
    token propertyName:sym<caladruri>       { :i caladruri }
    token propertyName:sym<caluri>          { :i caluri }
    token propertyName:sym<xml>             { :i xml }
    token propertyName:sym<birthplace>      { :i birthplace }
    token propertyName:sym<deathplace>      { :i deathplace }
    token propertyName:sym<deathdate>       { :i deathdate }
    token propertyName:sym<expertise>       { :i expertise }
    token propertyName:sym<hobby>           { :i hobby }
    token propertyName:sym<interest>        { :i interest }
    token propertyName:sym<org-directory>   { :i org'-'directory }
    token propertyName:sym<xName>           { <[xX]> '-' <.alphaNumDash>+ }

    token parameter      { <parameterName> '=' <parameterValue>+ % ',' };
     token parameterValue { <qSafeChar> | <safeChar> };
        token qSafeChar      { [<["]> <(] ~ [)> <["]>] <-["]>+ };
        token safeChar       { <-:C-[:;,"]>+ };

    proto token parameterName {*}
    token parameterName:sym<mediatype>              { :i mediatype }
    token parameterName:sym<label>                  { :i label }
    token parameterName:sym<languague>              { :i languague }
    token parameterName:sym<value>                  { :i value }
    token parameterName:sym<pref>                   { :i pref }
    token parameterName:sym<altid>                  { :i altid }
    token parameterName:sym<type>                   { :i type }
    token parameterName:sym<pid>                    { :i pid }
    token parameterName:sym<geo>                    { :i geo }
    token parameterName:sym<index>                  { :i index }
    token parameterName:sym<level>                  { :i level }
    token parameterName:sym<group>                  { :i group }
    token parameterName:sym<tz>                     { :i tz }
    token parameterName:sym<sort-as>                { :i sort'-'as }
    token parameterName:sym<calscale>               { :i calscale }
    token parameterName:sym<propertyName:xName>     { <.sym> }


    token TOP { <begin> \n <version> \n <contentLine>+ %% \n <endI> }
}

my $testCard1 = 
Q[BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
FN:Forrest Gump
ORG:Bubba Gump Shrimp Co.
TITLE:Shrimp Man
PHOTO;MEDIATYPE=image/gif;VALUE=uri:http://www.example.com/dir_photos/my_photo.gif
TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212
TEL;TYPE=home,voice;VALUE=uri:tel:+1-404-555-1212
ADR;TYPE=work;PREF=1;LABEL="100 Waters Edge\nBaytown\, LA 30314\nUnited States of America":;;100 Waters Edge;Baytown;LA;30314;United States of America
ADR;TYPE=home;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America
EMAIL:forrestgump@example.com
x-qq:21588891
END:VCARD];
#REV:20080424T195243Z
my $testCard2=
Q[BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
END:VCARD];
my $testJcard = '[
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
]';

use JSON::Tiny;

#say from-json($jCard);

#Vcard.parse($e).say;
#.Str.say for Vcard.parse($e).caps;

class vCardToJcard {
    method TOP ($/) {
        make [
            ["version", %(), "text", "4.0"],
            |$<contentLine>».made;
        ]
    };
    method contentLine ($/) {
        #preparing hashArray of parameters
        my %parameter = %($<parameter>».made);
        my $parameterOfTypeValue = %parameter<value>[0] // $<selectTypeOfValue>.made;   #default value
        %parameter<value>:delete;

        #add a group to hashArray of parameters if exists
        with $<group> {
            %parameter<group> = $_.Str
        }

        #propertyValue is array, whenever there are more matches found in contentLine
        my $propertyValue;
        given $<propertyValue> {
            when $_.elems > 1 {$propertyValue = $_».made}
            default {$propertyValue = $_[0].made}
        }

        make [
            $<propertyName>.lc,     
            %parameter,
            $parameterOfTypeValue,
            $propertyValue
        ]
    };
    method propertyValue ($/) {
        make $/.subst( / \\ )> <[,;]> /, Q{}, :g ).subst(/ \\n/, "\n", :g)
    };
    method parameter ($/) {
        my $value;
        given $<parameterValue> {
            when $_.elems > 1 {$value = $_».made}
            default {$value = $_[0].made}
        }
        make $<parameterName>.lc => $value; 
    };
    method parameterValue ($/) {
        with $<qSafeChar> {make $_.made}
        orwith $<safeChar> {make $_.Str}
    };
    method qSafeChar ($/) {
        make $/.subst(/ \\ )> <[,\;]> /, Q{}, :g ).subst(/ \\n /, "\n", :g)
    };
    method selectTypeOfValue ($/) {
        make say 'helo';
        say $<parameterName>;
    };
}
 
my $rest = Vcard.parse($testCard1, actions => vCardToJcard.new).made;   # ---NW
say $rest;

#dd Vcard.parse($_, actions => vCardToJcard.new, :rule<contentLine>).made for 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212', 'ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America', 'CONTACT.FN:Mr. John Q. Public\, Esq.';

use Test;

#is-deeply $rest, from-json($jCard);    ----NW
is Vcard.parse($_, actions => vCardToJcard.new, :rule<contentLine>).made[1], "${:group("MyGroup")}", 'Jcard contains a group parameter' with 'MyGroup.ORG:Bubba Gump Shrimp Co.';
is-deeply Vcard.parse($_, actions => vCardToJcard.new, :rule<parameter>).made, 'type' => <work voice>.Array, 'Parameter TYPE was converted to lowercase and its value is hashArray of values: work, voice' with 'TYPE=work,voice';
is-deeply Vcard.parse($_, actions => vCardToJcard.new, :rule<contentLine>).made, $["tel", {:type($["work", "voice"])}, "uri", "tel:+1-111-555-1212"], 'The structure of contentLine is following: string-tel, hashArray-type, string-uri, string-value' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
is Vcard.parse($_, actions => vCardToJcard.new, :rule<propertyValue>).made, "United, States; of America", 'Formating propertyValue - testing whether allowed backslashed characters were modified correctly' with 'United\, States\; of America';
ok Vcard.parse($_, :rule<propertyName>), "A property name can be $_" for <email Email eMail n N fn fN>;
like Vcard.parse($_, :rule<contentLine>).<propertyValue>,/^Bubba/ with 'ORG:Bubba Gump Shrimp Co.';
like Vcard.parse($_, :rule<contentLine>).<propertyValue>,/^\d+$/ with 'x-qq:21588891';
is Vcard.parse($_, :rule<contentLine>).<propertyValue>».Str,('', 'Gump', 'Forrest', '', 'Mr.',''), 'Found 6 propertyValues, including 3 empty in border testing.' with 'N:;Gump;Forrest;;Mr.;';
# like Vcard.parse($_, :rule<contentLine>).<value>,/\n \h+/ with 'x-qq:215
#  88891';
is Vcard.parse($_, :rule<contentLine>).<parameter>, <TYPE=work,voice VALUE=uri>, 'Found parameters: TYPE with values=work, voice; Value with value=uri.' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
like Vcard.parse($_, :rule<contentLine>).<parameter>.[0],/^TYPE/, 'First parameterName begins with characters TYPE.' with 'ADR;TYPE=HOME;LABEL="42 Plantation St.\nBaytown\, LA 30314\nUnited States of America":;;42 Plantation St.;Baytown;LA;30314;United States of America';
ok Vcard.parse($_), "Testcard: \n\n$/ \n\nparsed successfully" for $testCard1, $testCard2;

done-testing;


#https://tools.ietf.org/html/rfc6350#page-73 - Vcard
#https://tools.ietf.org/html/rfc7095         - Jcard
#https://www.iana.org/assignments/vcard-elements/vcard-elements.xhtml#value-data-types - Iana