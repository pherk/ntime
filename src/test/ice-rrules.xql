xquery version "3.0";
module namespace ice-rrules="http://enahar.org/enahar/test/ice-rrules";

import module namespace test = "http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace ical = "http://eNahar.org/ns/lib/ical/ical" at "../content/ical.xqm";
import module namespace ice  = "http://eNahar.org/ns/lib/ical/ice" at "../content/ice.xqm";

declare %test:setUp function ice-rrules:setup()
{
    ()
};

declare %test:tearDown function ice-rrules:cleanup()
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
declare %test:assertXPath("count($result)=2") function ice-rrules:match-daily()
{
    let $start := xs:dateTime('2015-04-06T08:00:00')
    let $end   := xs:dateTime('2015-04-16T23:00:00')
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
            </rrule>
        </event>
    ,   
        <event xmlns="http://hl7.org/fhir">
            <rrule>
                <freq value="daily"/>
                <byDay value="Mi"/>
            </rrule>
        </event>
    )
    for $d in (0 to $nofd)
    let $date  := ical:dateTime($y,$m,$first,"08","00","00") + xs:dayTimeDuration('P1D')*$d
    return
        ice:match-rrules($date, $e)
};

declare %test:assertXPath("count($result)=2") function ice-rrules:match-monthly()
{
    let $start := xs:dateTime('2015-04-06T08:00:00')
    let $end   := xs:dateTime('2015-04-16T23:00:00')
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
                <freq value="monthly"/>
                <byDay value="2:Mi,4:Mi"/>
            </rrule>
        </event>
    ,   
        <event xmlns="http://hl7.org/fhir">
            <rrule>
                <freq value="monthly"/>
                <byDay value="-3:Mo"/>
            </rrule>
        </event>
    )
    for $d in (0 to $nofd)
    let $date  := ical:dateTime($y,$m,$first,"08","00","00") + xs:dayTimeDuration('P1D')*$d
    return
        ice:match-rrules($date, $e)
};
