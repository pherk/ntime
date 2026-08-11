xquery version "3.1";
(: ~
 : iCalendar engine
 : matches rrule, rdate, exdate
 : 
 : @author Peter Herkenrath
 : @version Nabu 0.9
 : @since Nabu v0.6 2015-03-29
 : @date 2018-01-29
 : @date 2026-07-29
 : 
 : 
 :)
module namespace nice ="http://eNahar.org/ns/lib/ical/ice";

import module namespace nical ="http://eNahar.org/ns/lib/ical/ical";

declare namespace fhir = "http://hl7.org/fhir";
declare default element namespace "http://hl7.org/fhir";

(:~
 : filter events
 : 
 : @param $date
 : @param $events
 : 
 : @return events
 :)
declare function nice:match-simple($date as xs:dateTime, $events as element(fhir:event)* ) as element(fhir:event)*
{
        $events[start/@value <= $date and end/@value >= $date]
};

(:~
 : filter events with rdates
 : 
 : @param $date
 : @param $events
 : 
 : @return events
 :)
declare function nice:match-rdates($date as xs:dateTime, $events as element(fhir:event)* ) as element(fhir:event)*
{
    for $e in $events
    return
        if ($e/rdate) then
            if ($e/rdate/period) then
                nice:match-rperiod($date, $e)
            else 
                nice:match-rdate($date, $e)
        else ()
};

(:~
 : filter event with rdates defined by period
 : 
 : @param $date
 : @param $event
 : 
 : @return event?
 :)
declare function nice:match-rperiod($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
    if (nice:match-interval($date,$event/rdate/period)) then
            $event
    else ()
};

(:~
 : filter event with rdates defined by date
 : 
 : @param $date
 : @param $event
 : 
 : @return events?
 :)
declare function nice:match-rdate($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
    for $rd in $event/rdate
    return
    if (xs:date($date)=xs:date($rd/@value)) then
            $event
    else ()
};

(:~
 : filter events with exdates
 : 
 : @param $date
 : @param $events*
 : 
 : @return events*
 :)
declare function nice:match-exdates($date as xs:dateTime, $events as element(fhir:event)* ) as element(fhir:event)*
{
    for $e in $events
    return
        if ($e/exdate) then
            nice:match-exdate($date, $e)
        else ()
};

(:~
 : filter event with exdate defined by date
 :
 : @param $date
 : @param $event
 :
 : @return events*
 :)
declare function nice:match-exdate($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)*
{
    for $xd in $event/exdate
    return
        if (xs:date($date)=xs:date($xd/@value)) then
            $event
        else ()
};


declare %private function nice:match-interval($date as xs:dateTime, $period as element(fhir:period)) as xs:boolean
{
    let $start := xs:dateTime($period/start/@value)
    let $end   := xs:dateTime($period/end/@value)
    return
      ($date >= $start and $date <= $end)
};

declare function nice:match-rrules($date as xs:dateTime, $events as element(fhir:event)* ) as element(fhir:event)*
{
    for $e in $events[exists(rrule)]
    return
        switch ($e/rrule/freq/@value)
        case 'daily'   return nice:match-daily($date, $e)
        case 'weekly'  return nice:match-weekly($date, $e)
        case 'monthly' return nice:match-monthly($date, $e)
        case 'yearly'  return nice:match-yearly($date, $e)
        default return fn:error(fn:QName('http://www.w3.org/2005/xqt-errors', 'err:FOER0000'))
};

declare function nice:match-daily($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
    if (nice:match-byWeekNo($date,$event/rrule/byWeekNo)) then
        if (nice:match-byDay($date,$event/rrule/byDay)) then
            $event
        else ()
    else ()
};

declare function nice:match-weekly($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
    let $rday := $event/rrule/byDay
    return
        if (nice:match-byDay($date,$rday)) then
            $event
        else ()
};

declare function nice:match-monthly($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
    if (true() = nice:match-byRDay($date,$event/rrule/byDay)) then
            $event
    else ()
};

declare function nice:match-yearly($date as xs:dateTime, $event as element(fhir:event)) as element(fhir:event)?
{
if ($event/rrule/byEaster) then
    if (nice:match-byEaster($date, xs:integer($event/rrule/byEaster/@value))) then
        $event
    else ()
else
    if (nice:match-byDayMonth($date, $event/rrule/byMonth/@value, $event/rrule/byDay/@value)) then
        $event
    else ()
};

declare function nice:match-byDay($date as xs:dateTime, $byDay as element(fhir:byDay)?) as xs:boolean
{
if ($byDay) then
    let $dn := nical:day-of-week-shortname($date)
    return
        contains($byDay/@value,$dn)
else true()
};

declare %private function nice:match-byRDay($date as xs:dateTime, $rday as element(fhir:byDay)?) as xs:boolean*
{
    let $dn := nical:day-of-week-shortname($date)
    let $d  := day-from-date($date)
    for $rd in tokenize($rday/@value,',')
    return
        nice:match-singleRDay($date,$d,$dn,$rd)
};

declare %private function nice:match-singleRDay(
            $date as xs:dateTime,
            $d as xs:integer, $dn as xs:string, $rday as xs:string
        ) as xs:boolean
{
    let $rtoks := tokenize($rday,':')
    let $rdn := $rtoks[2]
    let $rno := xs:integer($rtoks[1])
    return
        if ($dn=$rdn) then
            if ($rno>0)
            then (($d - 1) idiv 7)=($rno - 1)            (: nth-weekday => DOW and NthDay :)
            else                                         (: nthlast-weekday :)
                let $m  := month-from-date($date)
                let $nextMonth := if($m<12) then $m+1 else 1
                let $year  := if ($m<12) then year-from-date($date) else year-from-date($date)+1
                let $dow := nical:dayname-to-dow($rdn)
                return
                    (xs:date($date) = (nical:first-weekday-of-month($year,$nextMonth,$dow) + xs:dayTimeDuration('P1D') * 7 * $rno))
        else false()
};

declare %private function nice:match-byWeekNo($date as xs:dateTime, $byWeekNo as element(fhir:byWeekNo)?) as xs:boolean
{
    if ($byWeekNo and $byWeekNo/@value!='') then
        let $wno := nical:week-of-year($date)
        let $odd := $wno mod 2 = 1
        return
            if ($byWeekNo/@value='odd' and $odd) then
                true()
            else if ($byWeekNo/@value='even' and not($odd)) then
                true()
            else let $kws := tokenize($byWeekNo/@value,',')
                return
                    xs:string($wno) = $kws
    else true()
};


declare %private function nice:match-byEaster($date as xs:dateTime, $add as xs:integer) as xs:boolean
{
    let $easter := nical:easter(year-from-date($date))
    return
        (xs:date($date) = ($easter + xs:dayTimeDuration('P1D') * $add))
};

declare %private function nice:match-byDayMonth($date as xs:dateTime, $month as xs:integer?, $day as xs:integer?) as xs:boolean
{
    (fn:day-from-dateTime($date) = $day  and fn:month-from-dateTime($date) = $month)
};

