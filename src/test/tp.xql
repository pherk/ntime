xquery version "3.0";
(: ~
 : time line test
 : 
 : @author Peter Herkenrath
 : @version 0.1
 : 2015-07-30
 : 
 : 
 :)
module namespace tpt ="http://enahar.org/enahar/test/tp-test";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace tp ="http://eNahar.org/ns/lib/ical/ntime" at "../content/timePeriod.xqm";

declare variable $tpt:tps1 := 
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


declare variable $tpt:tpPrecedes1 := (: a precedes b :)
    (
        <tp><start value="2015-06-25T08:00:00"/><end value="2015-06-25T09:00:00"/></tp>
    ,   <tp><start value="2015-06-25T09:30:00"/><end value="2015-06-25T10:30:00"/></tp>
    );
declare variable $tpt:tpPrecedes2 := (: a precededBy b :)
    (
        <tp><start value="2015-06-25T09:30:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T08:00:00"/><end value="2015-06-25T09:00:00"/></tp>
    );
declare variable $tpt:tpMeets1 := (: a meets b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T10:30:00"/><end value="2015-06-25T11:00:00"/></tp>
    );
declare variable $tpt:tpMeets2 := (: a metBy b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T08:00:00"/><end value="2015-06-25T11:00:00"/></tp>
    );
declare variable $tpt:tpOverlaps1 := (: a overlaps b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T10:00:00"/><end value="2015-06-25T11:30:00"/></tp>
    );
declare variable $tpt:tpOverlaps2 := (: a overlapedBy b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T08:00:00"/><end value="2015-06-25T09:30:00"/></tp>
    );
declare variable $tpt:tpFinishedBy1 := (: a finishedBy b :)
    (
        <tp><start value="2015-06-25T08:30:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    );
declare variable $tpt:tpFinishedBy2 := (: a finishes b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T08:30:00"/><end value="2015-06-25T10:00:00"/></tp>
    );
declare variable $tpt:tpContains1 := (: a contains b :)
    (
        <tp><start value="2015-06-25T08:30:00"/><end value="2015-06-25T10:30:00"/></tp>
    ,   <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    );
declare variable $tpt:tpContains2 := (: a during b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T08:30:00"/><end value="2015-06-25T10:30:00"/></tp>
    );
declare variable $tpt:tpStarts1 := (: a><start values b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:30:00"/></tp>
    );
declare variable $tpt:tpStartedBy2 := (: a><start valueedBy b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T09:30:00"/></tp>
    );
declare variable $tpt:tpEquals := (: a equals b :)
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    ,   <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T10:00:00"/></tp>
    );

declare %test:setUp function tpt:setup()
{
    ()
};

declare %test:tearDown function tpt:cleanup()
{
    ()
};
(: ----------------------------
 : Actual tests below this line
 : ----------------------------
 :)

declare %test:assertTrue function tpt:combinePeriods() as xs:boolean
{
   count(tp:combinePeriods($tpt:tps1)) = 2
};

