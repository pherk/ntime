xquery version "3.0";
module namespace ice-hd="http://enahar.org/enahar/test/ice-hd";

import module namespace test = "http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";
import module namespace ical = "http://eNahar.org/ns/lib/ical/ical" at "../content/ical.xqm";
import module namespace ice  = "http://eNahar.org/ns/lib/ical/ice" at "../content/ice.xqm";

declare namespace fhir = "http://hl7.org/fhir";

declare variable $ice-hd:hds :=
      <holidays xmlns="http://hl7.org/fhir">
        <description value="Holiday Profile for Germany/Nordrhein-Westphalen."/>
        <className value="holiday"/>
        <backgroundColor value="#006400"/>
        <textColor value="#ffffff"/>
        <editable value="false"/>
        <event>
            <name value="neujahr"/>
            <description value="Neujahr"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="h3k"/>
            <description value="Heilige 3 Könige"/>
            <type value="rk"/>
            <start value="1900-01-06T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="weiberfastnacht"/>
            <description value="Weiberfastnacht"/>
            <type value="traditional"/>
            <start value="1900-01-01T12:00:00"/>
            <end value="1900-01-01T23:59:59"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="-52"/>
            </rrule>
        </event>
        <event>
            <name value="karfreitag"/>
            <description value="Karfreitag"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="-2"/>
            </rrule>
        </event>
        <event>
            <name value="ostern"/>
            <description value="Ostersonntag"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="0"/>
            </rrule>
        </event>
        <event>
            <name value="ostermontag"/>
            <description value="Ostermontag"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="1"/>
            </rrule>
        </event>
        <event>
            <name value="1mai"/>
            <description value="1. Mai"/>
            <type value="official"/>
            <start value="1900-05-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="christihimmelfahrt"/>
            <description value="Christi Himmelfahrt"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="39"/>
            </rrule>
        </event>
        <event>
            <name value="pfingsten"/>
            <description value="Pfingsten"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="49"/>
            </rrule>
        </event>
        <event>
            <name value="pfingstmontag"/>
            <description value="Pfingstmontag"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
        </event>
        <event>
            <name value="fronleichnam"/>
            <description value="Fronleichnam"/>
            <type value="official"/>
            <start value="1900-01-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
                <byEaster value="60"/>
            </rrule>
        </event>
        <event>
            <name value="3okt"/>
            <description value="Tag der deutschen Einheit"/>
            <type value="official"/>
            <start value="1990-10-03T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="allerheiligen"/>
            <description value="Allerheiligen"/>
            <type value="official"/>
            <start value="1900-11-01T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="stmartin"/>
            <description value="Sankt Martin"/>
            <type value="rk"/>
            <start value="1900-11-11T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="nikolaus"/>
            <description value="Nikolaus"/>
            <type value="rk"/>
            <start value="1900-12-06T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="heiligabend"/>
            <description value="Heilig Abend"/>
            <type value="traditional"/>
            <start value="1900-12-24T12:00:00"/>
            <end value="1900-12-24T23:59:59"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="weihnachten"/>
            <description value="Weihnachten"/>
            <type value="official"/>
            <start value="1900-12-25T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="2weihnachtstag"/>
            <description value="2. Weihnachtstag"/>
            <type value="official"/>
            <start value="1900-12-26T00:00:00"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
        <event>
            <name value="silvester"/>
            <description value="Silvester"/>
            <type value="traditional"/>
            <start value="1900-12-31T12:00:00"/>
            <end value="1900-12-31T23:59:59"/>
            <rrule>
                <freq value="yearly"/>
            </rrule>
        </event>
    </holidays>;

declare %test:setUp function ice-hd:setup()
{
    ()
};

declare %test:tearDown function ice-hd:cleanup()
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
declare %test:assertXPath("count($result)=19") function ice-hd:match()
{
    let $start := xs:dateTime('2015-01-01T08:00:00')
    let $end   := xs:dateTime('2015-12-31T23:00:00')
    let $y  := year-from-date($start)
    let $m  := month-from-date($start)
    let $first := day-from-date($start)
    let $last  := day-from-date($end)
    let $nofd  := xs:integer(floor(($end - $start) div xs:dayTimeDuration('P1D')))
    let $dur := xs:dayTimeDuration('P14D')
    for $d in (0 to $nofd)
    let $date  := ical:dateTime($y,$m,$first,"08","00","00") + xs:dayTimeDuration('P1D')*$d
    return
        ice:match-rrules($date, $ice-hd:hds/*:event)
};

