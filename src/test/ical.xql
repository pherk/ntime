xquery version "3.0";
module namespace ict ="http://enahar.org/enahar/test/ical-test";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace ical ="http://eNahar.org/ns/lib/ical/ical" at "../content/ical.xqm";

declare %test:setUp function ict:setup()
{
    ()
};

declare %test:tearDown function ict:cleanup()
{
    ()
};
(: ----------------------------
: Actual tests below this line
: ---------------------------- :)
(:
 : easter()
 :
 :)
declare %test:assertEquals("2015-04-05") function ict:easter() as xs:date
{
  ical:easter(2015)
};

