use v6.d;
use vCard::Parser;
use JSON::Tiny;
use Test;

is-deeply from-vCard(slurp './t/test-cards/test-card1.vcard'), from-json(slurp './t/test-cards/test-card3.jcard'), 'Testing from-vCard routine.';

done-testing;
