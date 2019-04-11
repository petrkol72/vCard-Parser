use v6.d;
use Test;
use vCard::Parser::Grammar;
use vCard::Parser::Actions;
use JSON::Tiny;

my $grammar = vCard::Parser::Grammar.new;
my $action = vCard::Parser::Actions.new;


role Do-made {
    method made {self};
};
isa-ok $action.made-value([1 but Do-made,2 but Do-made]), "Array";
isa-ok $action.made-value([1 but Do-made]), 'Int';

my $jCard-multi-value = from-json '["adr", {}, "text",
    [
     "", "",
     ["My Street", "Left Side", "Second Shack"],
     "Hometown", "PA", "18252", "U.S.A."
    ]
]';
cmp-ok $grammar.parse($_, actions => $action.new, :rule<content-line>).made, 'eqv', $jCard-multi-value, 'Equality testing - jCard from-json contains an array in property-value' with 'ADR:;;My Street,Left Side,Second Shack;Hometown;PA;18252;U.S.A.';

is-deeply $grammar.parse($_, actions => $action.new, :rule<parameter>).made, 'type' => <work voice>.Array, 'Parameter TYPE was converted to lowercase and its value is hashArray of values: work, voice' with 'TYPE=work,voice';
is-deeply $grammar.parse($_, actions => $action.new, :rule<content-line>).made, $["tel", {:type($["work", "voice"])}, "uri", "tel:+1-111-555-1212"], 'The structure of content-line is following: string-tel, hashArray-type, string-uri, string-value' with 'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212';
is $grammar.parse($_, actions => $action.new, :rule<property-value>).made, 'United, States; of A\\merica', 'Formating property-value - testing whether allowed backslashed characters were modified correctly' with 'United\, States\; of A\\merica';
is-deeply $grammar.parsefile('./t/test-cards/test-card1.vcard', actions => $action.new, :rule<vcard>).made, from-json(slurp './t/test-cards/test-card3.jcard'), 'The comparsion of test-card3.jcard from-json and expected result - test-card1.vcard.';
is $grammar.parse($_, actions => $action.new, :rule<content-line>).made[1], "${:group("MyGroup")}", 'Jcard contains a group parameter' with 'MyGroup.ORG:Bubba Gump Shrimp Co.';

subtest 'Testing types of property-value.', {
    plan 6;
    my %type-of-property-value = %(
        'x-qq:21588891' => 'unknown',
        'group.X-prop:tel:454' => 'unknown',
        'TEL;TYPE=work,voice;VALUE=uri:tel:+1-111-555-1212' => 'uri',
        'EMAIL;PID=4.2,5.1:jdoe@example.com' => 'text',
        'EMAIL;PID=4.2,5.1;VALUE=date:jdoe@example.com' => 'date',
        'ANNIVERSARY:20090808T1430-0500' => 'date-and-or-time',
    );
    for %type-of-property-value.pairs {
        is my $tmp = $grammar.parse($_.key, actions => $action.new, :rule<content-line>).made[2], $_.value, "A type of property-value for: $/ is: $tmp";
    };
};

done-testing;
