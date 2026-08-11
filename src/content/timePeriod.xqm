xquery version "3.1";
(: ~
 : time period
 : 
 : @author Peter Herkenrath
 : @version 0.2.1
 : 2016-01-23
 : 
 : TODO: handle indefinite periods, e.g. without defined start or end
 :)
module namespace ntime ="http://eNahar.org/ns/lib/ical/ntime";

(: provides highest, lowest, sort :)
import module namespace nxxpath = "http://eNahar.org/ns/lib/ical/xxpath";

import module namespace nallen = "http://eNahar.org/ns/lib/ical/allen";
import module namespace ntlm   = "http://eNahar.org/ns/lib/ical/tlm";

(:~
 : Time Period
 : properties
 :     start
 :     end
 :     duration
 :     hasStart
 :     hasEnd
 :     isAnytime
 :     isMoment
 : start, end, and duration of the time period
 : hasStart is true if the Start time is defined
 : hasEnd is true if the End time is defined
 : isAnytime is true if neither the Start nor the End times are defined
 : isMoment is true if Start and End hold identical values
 :)

declare variable $ntime:minValue := "1970-01-01T00:00:00";
declare variable $ntime:maxValue := "2029-04-01T23:59:59";

declare function ntime:clone($tp as item(), $start as xs:dateTime, $end as xs:dateTime) as item()
{
  let $ln := local-name($tp)
  let $ns := namespace-uri($tp)
  let $base := $tp/*[not(self::*:start or self::*:end or self::*:allen)]
  return
    element {fn:QName($ns,$ln)} {
          $base
        , element {fn:QName($ns,"start")} {
            attribute { "value" } { xs:string($start) }
          }
        , element {fn:QName($ns,"end")} {
            attribute { "value" } { xs:string($end) }
          }
      }
};

declare function ntime:clone($tp as item(), $start as xs:dateTime, $end as xs:dateTime, $allen as xs:string) as item()
{
  let $ln := local-name($tp)
  let $ns := namespace-uri($tp)
  let $base := $tp/*[not(self::*:start or self::*:end or self::*:allen)]
  return
    if ($start <= $end)
    then 
      element {fn:QName($ns,$ln)} {
          $base
        , element {fn:QName($ns,"start")} {
            attribute { "value" } { xs:string($start) }
          }
        , element {fn:QName($ns,"end")} {
            attribute { "value" } { xs:string($end) }
          }
        , element {fn:QName($ns,"allen")} {
              attribute { "value" } { xs:string($allen) }
          }
        }
    else
        error(xs:QName("ntime:error"), "invalid time period")
};

declare function ntime:new($start as xs:dateTime, $end as xs:dateTime, $allen as xs:string?) as item()
{
  if ($allen)
  then
      ntime:clone(<tp></tp>, $start, $end, $allen)
  else
      ntime:clone(<tp></tp>, $start, $end)
};

(:~
 : start
 : get start of first period
 : 
 : @param $tps sequence of tp
 : 
 : @return dateTime
 :)
declare function ntime:start($tps as item()*) as xs:dateTime
{
    if (count($tps)=1)
    then xs:dateTime($tps/*:start/@value)
    else xs:dateTime(nxxpath:lowest(function($tp){xs:dateTime($tp/*:start/@value)},$tps)/*:start/@value)
};

(:~
 : end
 : get end of last period
 : 
 : @param $tps sequence of tp
 : 
 : @return dateTime
 :)
declare function ntime:end($tps as item()*) as xs:dateTime
{
    if (count($tps)=1)
    then xs:dateTime($tps/*:end/@value)
    else xs:dateTime(nxxpath:highest(function($tp){xs:dateTime($tp/*:end/@value)},$tps)/*:end/@value)
};


(:~
 : hasInside
 : 
 : @param $tp     time period
 : @param $moment 
 :
 : @return boolean
 :)
declare function ntime:hasInside($tp as item(), $moment as xs:dateTime) as xs:boolean
{
    ($moment > $tp/*:start/@value and $moment < $tp/*:end/@value)
};

(:~
 : intersectsWith
 :
 : @param $tp1  time period
 : @param $tp2  time period to be tested
 :
 : @return boolean
 :)
declare function ntime:intersectsWith($tp1 as item(), $tp2 as item()) as xs:boolean
{
    ntime:hasInside($tp1, $tp2/*:start/@value) or
    ntime:hasInside($tp1, $tp2/*:end/@value) or
    ($tp2/*:start/@value <= $tp1/*:start/@value and $tp2/*:end/@value >= $tp1/*:end/@value)
};

(:~
 : slice
 : divides time period in subintervals with given duration
 : 
 : @param $tp     timeperiod (tp)
 : @param $durint duration in minutes (xs:integer)
 : 
 : return item()*
 :)
declare function ntime:slice($tp as item(), $durint as xs:integer) as item()*
{
    let $duration := (xs:dateTime($tp/*:end/@value) - xs:dateTime($tp/*:start/@value)) div xs:dayTimeDuration("PT1M")
    let $dur  := xs:dayTimeDuration("PT1M") * $durint
    let $ns   := $duration idiv $durint
    let $start := xs:dateTime($tp/*:start/@value)
    return
        for $i in (1 to $ns)
        let $tps := $start + ($dur * ($i - 1))
        return
            ntime:clone($tp, $tps, $tps + $dur)
(:
    ,   if (($duration mod $durint) > 0)
        then <tp start="{$start + ($dur*$ns)}" end="{$tp/*:end/@value}"/>
        else ()
    )
:)
};

(:~
 : overlap
 : true if tp overlaps all $os

 : @param $os
 : @param $tp
 : @return boolean
 :)
declare function ntime:overlap($os as item()+, $tp as item()) as xs:boolean
{
    count($os) = count($os[nallen:relation($tp,.)=("e","s","d","f","o","S","D","F","O")])

};

(:~
 : combinePeriods
 : combine time periods if adjacent
 : 
 : @param $tlms  sequence of tlm
 : 
 : @return sequence of tp
 :)
declare function ntime:combinePeriods($tps as item()*) as item()*
{
    reverse(fold-left(tail($tps), head($tps), function($acc, $tp) {
        let $tail := tail($acc)
        let $head := head($acc)
        return
            if (nallen:startedBy($head,$tp) or nallen:equals($head,$tp) or nallen:finishedBy($head,$tp) or nallen:contains($head, $tp))
            then $acc
            else if (nallen:overlaps($head,$tp) or nallen:meets($head,$tp) or nallen:starts($head,$tp))
            then (ntime:clone($head, $head/*:start/@value,$tp/*:end/@value), $tail)
            else ($tp,$acc)
    }))
};

(:~
 : intersectPeriods
 : intersect sequence of time periods (sorted by *:start/@value)
 : 
 : @param $tps  sequence of tp
 : 
 : @return sequence of tp
 :)
declare function ntime:intersectPeriods($tps as item()*) as item()*
{
    let $list := fold-left(tail($tps), head($tps), function($old, $tp) {
        let $tail := tail($old)
        let $head := head($old)
        let $new := if ($head/*:allen/@value=("","f"))
            then $tail
            else $old
        let $allen := nallen:relation($head, $tp)
        return
            switch ($allen)
            case "p" return (ntime:clone($head,$tp/*:start/@value,$tp/*:end/@value, "f"), $new)
            case "m" return (ntime:clone($head,$tp/*:start/@value,$tp/*:end/@value, "f"), $new)
            case "o" return (ntime:clone($head,$head/*:end/@value,$tp/*:end/@value,'f'),ntime:clone($head,$tp/*:start/@value,$head/*:end/@value, "i"), $tail)
            case "F" return (ntime:clone($head,$tp/*:start/@value,$head/*:end/@value, "i"), $tail)
            case "D" return (ntime:clone($head,$tp/*:end/@value,$head/*:end/@value,"f"), ntime:clone($head,$tp/*:start/@value,$tp/*:end/@value, "i"), $tail)
            case "s" return (ntime:clone($head,$head/*:end/@value,$tp/*:end/@value,'f'),ntime:clone($head,$head/*:start/@value,$head/*:end/@value, "i"), $tail)
            case "e" return (ntime:clone($head,$head/*:start/@value,$head/*:end/@value, "i"), $tail)
            case "S" return (ntime:clone($head,$tp/*:end/@value,$head/*:end/@value,"f"), ntime:clone($head,$tp/*:start/@value,$tp/*:end/@value, "i"), $tail)
            case "O" return (ntime:clone($head,$head/*:start/@value,$tp/*:end/@value, "i"), $tail)
            (: should not happen if list sorted :)
            case "d" return (ntime:clone($head,$head/*:start/@value,$head/*:end/@value, "i"), $tail)
            case "f" return (ntime:clone($head,$head/*:start/@value,$tp/*:end/@value, "i"), $tail)
            case "M" return $tail
            case "P" return $tail
            default return $tail
    })
    return
        if (head($list)/*:allen/@value="i")
        then reverse($list)
        else reverse(tail($list))
};
(: 
-- Given a list of intervals, select those which overlap with at least one other inteval in the set.
import Data.List

type Interval = (Integer, Integer)

overlap (a1,b1)(a2,b2) | b1 < a2 = False
                       | b2 < a1 = False
                       | otherwise = True

mergeIntervals (a1,b1)(a2,b2) = (min a1 a2, max b1 b2)

sortIntervals::[Interval]->[Interval]
sortIntervals = sortBy (\(a1,b1)(a2,b2)->(compare a1 a2))

sortedDifference::[Interval]->[Interval]->[Interval]
sortedDifference [] _ = []
sortedDifference x [] = x
sortedDifference (x:xs)(y:ys) | x == y = sortedDifference xs ys
                              | x < y  = x:(sortedDifference xs (y:ys))
                              | y < x  = sortedDifference (x:xs) ys

groupIntervals::[Interval]->[Interval]
groupIntervals = foldr couldCombine []
  where couldCombine next [] = [next]
        couldCombine next (x:xs) | overlap next x = (mergeIntervals x next):xs
                                 | otherwise = next:x:xs

findOverlapped::[Interval]->[Interval]
findOverlapped intervals = sortedDifference sorted (groupIntervals sorted)
  where sorted = sortIntervals intervals

sample = [(1,3),(12,14),(2,4),(13,15),(5,10)]
:)

(:~
 : subtractPeriods
 : compute valid gaps for tp sequence
 : 
 : @param $tps1  sequence of tp
 : @param $tps2  sequence of tp
 : 
 : @return sequence of tp
 :)
declare function ntime:subtractPeriods($tps1 as item()*, $tps2 as item()*) as item()*
{
    if (count($tps1)=0)
    then ()
    else if (count($tps2)=0)
    then $tps1 (: evtl combined :)
    else
        (: combine periods :)
        let $tps1c := ntime:combinePeriods($tps1)
        let $tps2c := ntime:combinePeriods($tps2)
	      (: invert subtracting periods :)
	      let $limits := ntime:clone(head($tps1c),ntime:start($tps1c), ntime:end($tps1c))
        let $lll := util:log-app("TRACE","apps.eNabar",$limits)
        let $lll := util:log-app("TRACE","apps.eNahar",$tps2c)
	      let $gaps   := ntime:gaps( $limits, $tps2c)
        let $lll := util:log-app("TRACE","apps.eNahar",$gaps)
        let $sorted := for $t in ($tps1c, $gaps)
	          order by $t/*:start/@value/string()
	          return
		            $t
        return
	          ntime:intersectPeriods( $sorted )
};

(:~
 : gaps
 : compute gaps for tp sequence within range
 : 
 : @param $range  tp
 : @param $tps  sequence of tp
 : 
 : @return sequence of tp
 :)
declare function ntime:gaps($range as item(), $tps as item()*) as item()*
{
    let $iw := filter($tps, function($tp) {
                ntime:intersectsWith($tp, $range)
            })
    return
        if (count($iw) > 0)
        then ntlm:gaps( $range, ntlm:tp2tlm($iw) )
        else $range
};



