use v6.d;
use vCard::Parser::Grammar;
use vCard::Parser::Actions;

unit class vCard::Parser:ver<0.0.1>;

sub line-folding (Str $_) {
    return $_.subst(/ \n [ ' ' | \t ] /, Q{}, :g);
};

sub from-vCard ($_) is export {
    my $preprocessed-vcard = line-folding($_);
    sub parser (|c) {vCard::Parser::Grammar.parse(|c)};
    my $vcard = parser($preprocessed-vcard, actions => vCard::Parser::Actions.new);
    with $vcard { 
        return $_.made
    };
};


=begin pod

=head1 NAME

vCard::Parser - a basic parser of vCard

=head1 SYNOPSIS

=begin code :lang<perl6>

use vCard::Parser;

my $vcard = 'BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
x-qq:21588891
END:VCARD';

say from-vCard($vcard);

use JSON::Tiny;
say to-json(from-vCard($vcard)); #Output is jCard

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
