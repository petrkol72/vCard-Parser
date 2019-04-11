[![Build Status](https://travis-ci.org/petrkol72/vCard-Parser.svg?branch=master)](https://travis-ci.org/petrkol72/vCard-Parser)

NAME
====

vCard::Parser - a basic parser of vCard

SYNOPSIS
========

```perl6
use vCard::Parser;

my $vcard = 'BEGIN:VCARD
VERSION:4.0
N:Gump;Forrest;;Mr.;
x-qq:21588891
END:VCARD';

say from-vCard($vcard);

use JSON::Tiny;
say to-json(from-vCard($vcard)); #Output is jCard
```

DESCRIPTION
===========

vCard::Parser is a basic parser of vCard files of version 4.0. It also serves as it's convertor to jCard, which is a JSON format for vCard data.

AUTHOR
======

    Petr Kolář <petrkol72@seznam.cz>

COPYRIGHT AND LICENSE
=====================

Copyright 2019 

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

