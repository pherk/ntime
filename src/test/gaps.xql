xquery version "3.0";
(: ~
 : time period test
 : 
 : @author Peter Herkenrath
 : @version 0.1
 : 2015-07-30
 : 
 : 
 :)
module namespace gapt ="http://enahar.org/enahar/test/gap-test";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace ntlm ="http://eNahar.org/ns/lib/ical/tlm" at "../content/timeLineMoment.xqm";

declare variable $gapt:tps1 := 
    (
        <tp><start value="2015-07-03T08:30:00"/><end value="2015-07-03T10:00:00"/></tp>
    ,   <tp><start value="2015-07-03T09:00:00"/><end value="2015-07-03T10:00:00"/></tp>
    ,   <tp><start value="2015-07-03T09:30:00"/><end value="2015-07-03T12:00:00"/></tp>
    ,   <tp><start value="2015-07-03T10:30:00"/><end value="2015-07-03T11:30:00"/></tp>
    ,   <tp><start value="2015-07-03T12:00:00"/><end value="2015-07-03T14:00:00"/></tp>
    ,   <tp><start value="2015-07-03T10:00:00"/><end value="2015-07-03T12:30:00"/></tp>
    ,   <tp><start value="2015-07-03T12:30:00"/><end value="2015-07-03T13:00:00"/></tp>
    ,   <tp><start value="2015-07-03T13:00:00"/><end value="2015-07-03T14:00:00"/></tp>
    ,   <tp><start value="2015-07-03T15:00:00"/><end value="2015-07-03T16:00:00"/></tp>
    );
declare variable $gapt:tlms1 := ntlm:insertAll((), $gapt:tps1);
declare variable $gapt:tps2 := 
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T09:30:00"/></tp>
    ,   <tp><start value="2015-06-25T11:00:00"/><end value="2015-06-25T11:30:00"/></tp>
    );
declare variable $gapt:tlms2 := ntlm:insertAll((), $gapt:tps2); 
(:
example range within timeline
let $wk :=
  (
      <tp><start value="2015-12-07T08:00:00"/><end value="2015-12-07T09:30:00"/></tp>
    , <tp><start value="2015-12-07T08:00:00"/><end value="2015-12-07T09:30:00"/></tp>
    , <tp><start value="2015-12-07T09:30:00"/><end value="2015-12-07T11:00:00"/></tp>
    , <tp><start value="2015-12-07T11:00:00"/><end value="2015-12-07T12:15:00"/></tp>
    , <tp><start value="2015-12-07T11:00:00"/><end value="2015-12-07T12:15:00"/></tp>
    , <tp><start value="2015-12-07T13:00:00"/><end value="2015-12-07T14:00:00"/></tp>
    , <tp><start value="2015-12-07T13:00:00"/><end value="2015-12-07T14:00:00"/></tp>
  )
let $r1 := <tp><start value="2015-12-07T08:00:00"/><end value="2015-12-07T12:00:00"/></tp>

let $r2 := <tp><start value="2015-12-07T13:00:00"/><end value="2015-12-07T16:00:00"/></tp>
:)

declare %test:setUp function gapt:setup()
{
    ()
};

declare %test:tearDown function gapt:cleanup()
{
    ()
};
(: ----------------------------
 : Actual tests below this line
 : ----------------------------
 :)

declare %test:assertTrue function gapt:gaps-all1() as xs:boolean
{
   count(ntlm:gaps(<tp><start value="2015-07-03T08:00:00"/><end value="2015-07-03T17:00:00"/></tp>, $gapt:tlms1)) = 3
};

declare %test:assertTrue function gapt:gaps-pre1() as xs:boolean
{
   count(ntlm:gaps(<tp><start value="2015-07-03T08:00:00"/><end value="2015-07-03T10:00:00"/></tp>, $gapt:tlms1)) = 2 (: incl inner gap :)
};
declare %test:assertTrue function gapt:gaps-inner1() as xs:boolean
{
   count(ntlm:gaps(<tp><start value="2015-07-03T08:30:00"/><end value="2015-07-03T16:00:00"/></tp>, $gapt:tlms1)) = 1
};
  declare %test:assertTrue function gapt:gaps-post1() as xs:boolean
{
   count(ntlm:gaps(<tp><start value="2015-07-03T15:00:00"/><end value="2015-07-03T17:00:00"/></tp>, $gapt:tlms1)) = 2 (: incl. inner gap :)
};

declare %test:assertTrue function gapt:gaps-all2() as xs:boolean
{
   count(ntlm:gaps(<tp><start value="2015-06-25T08:30:00"/><end value="2015-06-25T12:00:00"/></tp>, $gapt:tlms2)) = 3
};
