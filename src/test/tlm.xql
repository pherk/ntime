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
module namespace tlmt ="http://enahar.org/enahar/test/tlm-test";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace ntime ="http://eNahar.org/ns/lib/ical/ntime" at "../content/timePeriod.xqm";
import module namespace ntlm  ="http://eNahar.org/ns/lib/ical/tlm"   at "../content/timeLineMoment.xqm";

declare variable $tlmt:tps1 := 
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
declare variable $tlmt:tlms1 := ntlm:tp2tlm($tlmt:tps1);

declare variable $tlmt:tps2 := 
    (
        <tp><start value="2015-06-25T09:00:00"/><end value="2015-06-25T09:30:00"/></tp>
    ,   <tp><start value="2015-06-25T11:00:00"/><end value="2015-06-25T11:30:00"/></tp>
    );
declare variable $tlmt:tlms2 := ntlm:tp2tlm($tlmt:tps2); 

declare variable $tlmt:tps1sorted := 
    (
        <tp><start value="2015-07-03T08:30:00"/><end value="2015-07-03T10:00:00"/></tp>
    ,   <tp><start value="2015-07-03T09:00:00"/><end value="2015-07-03T10:00:00"/></tp>
    ,   <tp><start value="2015-07-03T09:30:00"/><end value="2015-07-03T12:00:00"/></tp>
    ,   <tp><start value="2015-07-03T10:00:00"/><end value="2015-07-03T12:30:00"/></tp>
    ,   <tp><start value="2015-07-03T10:30:00"/><end value="2015-07-03T11:30:00"/></tp>
    ,   <tp><start value="2015-07-03T12:00:00"/><end value="2015-07-03T14:00:00"/></tp>
    ,   <tp><start value="2015-07-03T12:30:00"/><end value="2015-07-03T13:00:00"/></tp>
    ,   <tp><start value="2015-07-03T13:00:00"/><end value="2015-07-03T14:00:00"/></tp>
    ,   <tp><start value="2015-07-03T15:00:00"/><end value="2015-07-03T16:00:00"/></tp>
    ,   <tp><start value="2015-07-03T15:30:00"/><end value="2015-07-03T16:30:00"/></tp>
    );
declare variable $tlmt:range := 
    (
        <tp><start value="2015-07-03T08:30:00"/><end value="2015-07-03T13:00:00"/></tp>
    );
declare variable $tlmt:leaves :=
    (
        <tp><start value="2015-07-03T09:00:00"/><end value="2015-07-03T10:00:00"/></tp>
    ,   <tp><start value="2015-07-03T10:30:00"/><end value="2015-07-03T11:30:00"/></tp>
    );


declare %test:setUp function tlmt:setup()
{
    ()
};

declare %test:tearDown function tlmt:cleanup()
{
    ()
};
(: ----------------------------
 : Actual tests below this line
 : ----------------------------
 :)


declare %test:assertTrue function tlmt:subtract() as xs:boolean
{
    count(ntime:subtractPeriods($tlmt:range,$tlmt:leaves)) = 3
};
