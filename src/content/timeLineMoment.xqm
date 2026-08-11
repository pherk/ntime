xquery version "3.1";
(: ~
 : time line moments
 : 
 : @author Peter Herkenrath
 : @version 0.1
 : 2015-07-03
 : 
 : 
 :)
module namespace ntlm = "http://eNahar.org/ns/lib/ical/tlm";

(:~
 : TimeLineMoment
 : sequence of start and end points of time periods (polymorphic items)
 : use to calculate a balance of intersecting/overlapping periods
 : 
 : properties
 :     startCount
 :     endCount
 :     moment
 :)

declare function ntlm:clone-tp($tp as item(), $start as xs:dateTime, $end as xs:dateTime) as item()
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

declare function ntlm:new($moment as xs:dateTime) as element(tlm)
{
    <tlm startCount="0" endCount="0" moment="{$moment}"/> 
};

declare function ntlm:balance($tlm as element(tlm)) as xs:integer
{
    xs:integer($tlm/@startCount) - xs:integer($tlm/@endCount)
};

declare function ntlm:isEmpty($tlm as element(tlm)) as xs:integer
{
    $tlm/@startCount='0' and $tlm/@endCount='0'
};

declare function ntlm:addStart($tlm as element(tlm)) as element(tlm)
{
    let $new := xs:integer($tlm/@startCount) + 1
    return
        <tlm startCount="{$new}" endCount="{$tlm/@endCount/string()}" moment="{$tlm/@moment/string()}"/>
};


declare function ntlm:subStart($tlm) as element(tlm)
{
    let $new := xs:integer($tlm/@startCount) - 1
    return
        <tlm startCount="{$new}" endCount="{$tlm/@endCount/string()}" moment="{$tlm/@moment/string()}"/>
};

declare function ntlm:addEnd($tlm) as element(tlm)
{
    let $new := xs:integer($tlm/@endCount) + 1
    return
        <tlm startCount="{$tlm/@startCount/string()}" endCount="{$new}" moment="{$tlm/@moment/string()}"/>
};


declare function ntlm:subEnd($tlm) as element(tlm)
{
    let $new := xs:integer($tlm/@endCount) - 1
    return
        <tlm startCount="{$tlm/@startCount/string()}" endCount="{$new}" moment="{$tlm/@moment/string()}"/>
};


declare function ntlm:insertStart($tlms as element(tlm)*, $m as xs:dateTime) as element(tlm)*
{
    let $tlm := $tlms[@moment=$m]
    return
        if ($tlm)
        then
            for $tlm in $tlms  
            return
                if ($tlm/@moment=$m)
                then ntlm:addStart($tlm)
                else $tlm
        else
            (
              ntlm:addStart(ntlm:new($m))
            , $tlms
            )
};

declare function ntlm:insertEnd($tlms as element(tlm)*, $m as xs:dateTime) as element(tlm)*
{
    let $tlm := $tlms[@moment=$m]
    return
        if ($tlm)
        then
            for $tlm in $tlms  
            return
                if ($tlm/@moment=$m)
                then ntlm:addEnd($tlm)
                else $tlm
        else
            (
              ntlm:addEnd(ntlm:new($m))
            , $tlms
            )
};


declare function ntlm:insert($tlms as element(tlm)*, $tp as item()) as element(tlm)*
{
    let $tlms1 := ntlm:insertStart($tlms, xs:dateTime($tp/*:start/@value/string()))
    let $tlms2 := ntlm:insertEnd($tlms1,  xs:dateTime($tp/*:end/@value/string()))
    return 
        ntlm:sort($tlms2)
};


declare function ntlm:insertAll($tlms as element(tlm)*, $tps as item()*) as element(tlm)*
{
  if (count($tps)=0)
  then 
    $tlms
  else
    let $tlms2 := fn:fold-left($tps, $tlms, function ($tlms0, $tp)
        { 
            let $tlms1 := ntlm:insertStart($tlms0, xs:dateTime($tp/*:start/@value/string()))
            return
                ntlm:insertEnd($tlms1, xs:dateTime($tp/*:end/@value/string()))
        })
    return 
        ntlm:sort($tlms2)
};

declare function ntlm:sort($tlms as element(tlm)*) as element(tlm)*
{
    for $tlm in $tlms
    order by $tlm/@moment/string()
    return
        $tlm
};

declare function ntlm:hasOverlaps($tlms as element(tlm)*) as xs:boolean*
{
	if ( count($tlms) > 1 )
	then
        count(fn:filter(ntlm:weights($tlms), function($w){ $w > 1 })) > 0
  else false()
};

declare function ntlm:hasGaps($tlms as element(tlm)*) as xs:boolean*
{
    0 = ntlm:weights($tlms)
};

declare function ntlm:weights($tlms as element(tlm)*) as xs:integer*
{
	fn:fold-left(tail($tlms), ntlm:balance(head($tlms)), function($bals, $tlm) {
            let $bal := $bals[last()] + ntlm:balance($tlm)
            return ($bals, $bal)
	    })
};

(:~
 : gaps
 : calculates gaps for time line within range
 : 
 : cave: if range falls within timeline all inner gaps will be returned
 :       can be avoided if only periods intersecting range are inserted
 : 
 : @param $range  time period for which gaps are calculated
 : @param $tlms   time line moments
 : 
 : @eturn sequence of tp
 :)
declare function ntlm:gaps($range as item(), $tlms as element(tlm)*) as item()*
{
    if ( $tlms )
    then 
	let $pre :=
	    if ($range/*:start/@value < head($tlms)/@moment)
	    then 
          let $end := if ($range/*:end/@value < head($tlms)/@moment) then $range/*:end/@value else head($tlms)/@moment
          return
	          ntlm:clone-tp($range, $range/*:start/@value, $end)
	    else ()
          let $inner := 
            for $i in index-of(reverse(tail(reverse(ntlm:weights($tlms)))), 0)
 	          let $gapStart := $tlms[$i]/@moment/string()
            let $gapEnd   := $tlms[$i+1]/@moment/string()
            return
	            ntlm:clone-tp($range, $gapStart, $gapEnd)
	let $post :=
	    if ($range/*:end/@value > $tlms[last()]/@moment)
	    then
          let $start := if ($range/*:start/@value > $tlms[last()]/@moment) then $range/*:start/@value else $tlms[last()]/@moment
          return
	          ntlm:clone-tp($range, $start, $range/*:end/@value)
	    else  ()
        return
	    ($pre, $inner, $post)
    else ()
};

(:~
 : tp2tlm
 : convert tp sequence to gap sequence with all start and end points
 : 
 : @param $tps  sequence of tp
 : 
 : @return sequence of tlm
 :)
declare function ntlm:tp2tlm($tps as item()*) as element(tlm)*
{
    ntlm:insertAll((), $tps)
};

