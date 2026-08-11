xquery version "3.0";
module namespace ice-simple="http://enahar.org/enahar/test/ice-simple";

import module namespace test = "http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace ical = "http://eNahar.org/ns/lib/ical/ical" at "../content/ical.xqm";
import module namespace ice  = "http://eNahar.org/ns/lib/ical/ice" at "../content/ice.xqm";

declare namespace fhir = "http://hl7.org/fhir"; 

declare %test:setUp function ice-simple:setup()
{
    ()
};

declare %test:tearDown function ice-simple:cleanup()
{
    ()
};
(: ----------------------------
: Actual tests below this line
: ---------------------------- :)
(:
 : match-simple()
 :
 :)
declare %test:assertXPath("count($result)=2") function ice-simple:match-simple()
{
    let $start := xs:dateTime('2014-05-20T08:00:00')
    let $end   := xs:dateTime('2014-05-30T23:00:00')
    let $y  := year-from-date($start)
    let $m  := month-from-date($start)
    let $first := day-from-date($start)
    let $last  := day-from-date($end)
    let $nofd  := xs:integer(floor(($end - $start) div xs:dayTimeDuration('P1D')))
    let $dur := xs:dayTimeDuration('P14D')
    let $e :=
    (
        <event xmlns="http://hl7.org/fhir">
            <start value="2014-05-28T00:00:00"/>
            <end value="2014-05-28T12:00:00"/>
        </event>
    ,  
        <event xmlns="http://hl7.org/fhir">
            <start value="2014-05-28T08:00:00"/>
            <end value="2014-05-28T12:00:00"/>
        </event>
    ,   
        <event xmlns="http://hl7.org/fhir">
            <start value="2014-05-28T10:00:00"/>
            <end value="2014-05-28T12:00:00"/>
        </event>
    )
    for $d in (0 to $nofd)
    let $date  := ical:dateTime($y,$m,$first,"08","00","00") + xs:dayTimeDuration('P1D')*$d
    return
        ice:match-simple($date, $e)
};

declare %test:assertXPath("count($result)=2") function ice-simple:match-kw()
{
    let $start := xs:dateTime('2018-06-06T08:00:00')
    let $end   := xs:dateTime('2018-06-16T23:00:00')
    let $y  := year-from-date($start)
    let $m  := month-from-date($start)
    let $first := day-from-date($start)
    let $last  := day-from-date($end)
    let $nofd  := xs:integer(floor(($end - $start) div xs:dayTimeDuration('P1D')))
    let $dur := xs:dayTimeDuration('P14D')
    let $e :=
    (
        <event xmlns="http://hl7.org/fhir">
            <rrule>
                <freq value="daily"/>
                <byWeekNo value="KW26"/>
                <byDay value="Mi"/>
            </rrule>
        </event>
    ,   
        <event xmlns="http://hl7.org/fhir">
            <rrule>
                <freq value="daily"/>
                <byWeekNo value="KW26"/>
                <byDay value="Mo"/>
            </rrule>
        </event>
    )
    for $d in (0 to $nofd)
    let $date  := ical:dateTime($y,$m,$first,"08","00","00") + xs:dayTimeDuration('P1D')*$d
    return
        ice:match-rrules($date, $e)
  };
