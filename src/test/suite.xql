xquery version "3.0";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace gapt   ="http://enahar.org/enahar/test/gap-test"   at "gaps.xql";
import module namespace allent ="http://enahar.org/enahar/test/allen-test" at "allen.xql"; 
import module namespace tlmt   ="http://enahar.org/enahar/test/tlm-test"   at "tlm.xql"; 
import module namespace tpt    ="http://enahar.org/enahar/test/tp-test"   at "tp.xql"; 
import module namespace ict        ="http://enahar.org/enahar/test/ical-test"  at "ical.xql";
import module namespace ice-simple ="http://enahar.org/enahar/test/ice-simple" at "ice-simple.xql";
import module namespace ice-rdates ="http://enahar.org/enahar/test/ice-rdates" at "ice-rdates.xql";
import module namespace ice-rrules ="http://enahar.org/enahar/test/ice-rrules" at "ice-rrules.xql";
import module namespace ice-hd     ="http://enahar.org/enahar/test/ice-hd"     at "ice-hd.xql";


test:suite((
      util:list-functions("http://enahar.org/enahar/test/allen-test")
    , util:list-functions("http://enahar.org/enahar/test/gap-test")
    , util:list-functions("http://enahar.org/enahar/test/tlm-test")
    , util:list-functions("http://enahar.org/enahar/test/tp-test")
    , util:list-functions("http://enahar.org/enahar/test/ical-test")
    , util:list-functions("http://enahar.org/enahar/test/ice-simple")
    , util:list-functions("http://enahar.org/enahar/test/ice-rdates")
    , util:list-functions("http://enahar.org/enahar/test/ice-rrules")
    , util:list-functions("http://enahar.org/enahar/test/ice-hd")
))
