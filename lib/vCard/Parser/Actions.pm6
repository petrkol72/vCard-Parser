unit class vCard::Parser::Actions;

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
method TOP ($/) { make $<vcard>».made }
method vcard ($/) {
    make ["vcard",
      [
        ["version", %(), "text", "4.0"],
        |$<content-line>».made;
      ]
    ]
};
method content-line ($/) {
    #preparing a hashArray of parameters
    my %parameter = %($<parameter>».made);
    my $parameter-of-type-value = %parameter<value>[0] // %default-type-of-value{$<property-name>.lc} // 'unknown';
    %parameter<value>:delete;

    #add a group to hashArray of parameters if-exists
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
