unit grammar vCard::Parser::Grammar;
    
    token TOP  { <vcard>+ %% \n }

    token vcard  { <begin> \n <version> \n <content-line>+ %% \n <endI> };
    
    token version  { :i 'Version:4.0' };
    token begin    { :i 'BEGIN:VCARD' };
    token endI     { :i 'END:VCARD'   };

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
    token parameter-name:sym<mediatype>       { :i mediatype }
    token parameter-name:sym<label>           { :i label }
    token parameter-name:sym<languague>       { :i languague }
    token parameter-name:sym<value>           { :i value }
    token parameter-name:sym<pref>            { :i pref }
    token parameter-name:sym<altid>           { :i altid }
    token parameter-name:sym<type>            { :i type }
    token parameter-name:sym<pid>             { :i pid }
    token parameter-name:sym<geo>             { :i geo }
    token parameter-name:sym<index>           { :i index }
    token parameter-name:sym<level>           { :i level }
    token parameter-name:sym<group>           { :i group }
    token parameter-name:sym<tz>              { :i tz }
    token parameter-name:sym<sort-as>         { :i sort'-'as }
    token parameter-name:sym<calscale>        { :i calscale }
    token parameter-name:sym<x-name>          { <[xX]> '-' <.alpha-num-dash>+ }

#https://tools.ietf.org/html/rfc6350#page-73 - Vcard
#https://tools.ietf.org/html/rfc7095         - Jcard
#https://www.iana.org/assignments/vcard-elements/vcard-elements.xhtml#value-data-types - Iana