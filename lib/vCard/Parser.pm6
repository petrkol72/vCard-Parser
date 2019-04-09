use v6.d;#error - version support
use vCard::Parser::Grammar;#error linking
use vCard::Parser::Actions;#error linking

unit class vCard::Parser:ver<0.0.1>;

sub line-folding (Str $_) {
    return $_.subst(/ \n [ ' ' | \t ] /, Q{}, :g);
};

multi vCard-to-jCard (Str $_) {
    my $preprocessed-vcard = line-folding($_);
    my $vcard = vCard.parse($preprocessed-vcard, actions => vCard::Parser::Actions.new);
    with $vcard { return $vcard.made }
    else { return };
};

my $test-card2 =
Q[BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
END:VCARD];

=begin pod

=head1 NAME

vCard::Parser - a basic parser of vCard

=head1 SYNOPSIS

=begin code :lang<perl6>

use vCard::Parser;
say vCard-to-jCard($vCard-string);

=end code

=head1 DESCRIPTION

vCard::Parser is a basic parser of vCard files of version 4.0.
It also serves as it's convertor to jCard, which is a JSON format for vCard data.

=head1 AUTHOR

 Petr Kolář <petrkol72@seznam.cz>

=head1 COPYRIGHT AND LICENSE

Copyright 2019 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod
