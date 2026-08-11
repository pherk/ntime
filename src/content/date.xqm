xquery version "3.1";
(: 
 : function library for date conversion.
 : @author Peter Herkenrath
 : @version 1.3
 : @see http://www.enahar.org
 :
 :)
module namespace ndate="http://eNahar.org/ns/lib/ical/date";


declare variable $ndate:tzrex := "(Z|[+-](?:2[0-3]|[01][0-9])(?::?(?:[0-5][0-9]))?)";
declare variable $ndate:daterex := "^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[01]|0[1-9]|[12][0-9]).*"; (: ignores rest :)
declare variable $ndate:dtrex   := "^(\d{4})-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)(\.\d+)?(([+-]\d\d:\d\d)|Z)?$";
declare variable $ndate:startSPZ := "1994-08-01T08:00:00";
declare variable $ndate:endSPZ   := "2029-04-01T00:00:00";

(:
 : ignores all but date, no Timezone
 :)
declare function ndate:iso2date($dateString as xs:string) as xs:date?
{
   if (fn:empty($dateString) or $dateString="")
   then ()
   else if (fn:not(fn:matches($dateString, $ndate:daterex)))
        then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString, $ndate:daterex, '$1-$2-$3'))
};

(:
 : ignores Milliseconds, no Timezone
 :)
declare function ndate:iso2dateTime($dtString as xs:string) as xs:dateTime?
{
   if (fn:empty($dtString) or $dtString="")
   then ()
   else if (fn:not(fn:matches($dtString, $ndate:dtrex)))
        then fn:error(xs:QName('ndate:Invalid_DateTime_Format'))
   else xs:dateTime(fn:replace($dtString, $ndate:dtrex, '$1-$2-$3T$4:$5:$6'))
};

declare function ndate:iso2instant($dtString as xs:string) as xs:dateTime?
{
   if (fn:empty($dtString) or $dtString="")
   then ()
   else if (fn:not(fn:matches($dtString, $ndate:dtrex)))
        then fn:error(xs:QName('ndate:Invalid_DateTime_Format'))
   else xs:dateTime($dtString)
};

declare function ndate:today() as xs:date
{
    xs:date(format-date(adjust-date-to-timezone(current-date()),"[Y0001]-[M01]-[D01]"))
};

declare function ndate:now() as xs:dateTime
{
    (: must get rid of second fractions aka dateTimeStamp :)
    xs:dateTime(format-dateTime(adjust-dateTime-to-timezone(current-dateTime()), "[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]"))
};

declare function ndate:noon() as xs:dateTime
{
    let $d := ndate:today()
    return
        fn:dateTime($d,xs:time('00:00:00'))
};

declare function ndate:shortTime(
    $dt as xs:dateTime
    )
{
    let $hour := fn:hours-from-dateTime($dt)
    let $min := fn:minutes-from-dateTime($dt)
    return
        concat(if ($hour=0) then "00" else $hour,':', if ($min=0) then "00" else $min)
};

(:~
 : converts several shortcuts to xs:date
 : ('auto','heute','h'), ('m'), ('nW'), ('nM'), ('\dw'), ('\dm'), ('dd.mm.yy'), 
 : 
 : @param $string   string
 : @return xs:date?
 :)
declare function ndate:easyDate($string as xs:string, $epoch as xs:date) as xs:date
{
    try {
        xs:date($string)
    } catch * {
        let $ls := lower-case($string)
        let $current := $epoch
        let $date :=
            if ($ls = ('auto','heute','h'))
            then $current
            else if ($ls = "m")
            then $current + xs:dayTimeDuration('P1D')       
            else if ($ls = "nw")
            then $current + 7*xs:dayTimeDuration('P1D')
            else if ($ls = "nm")
            then $current + 28*xs:dayTimeDuration('P1D')
            else if ($ls = "p90d")
            then current-date() + 90*xs:dayTimeDuration('P1D')
            else if (matches($ls,'^\dw$'))
            then $current + xs:int(substring($ls,1,1))*7*xs:dayTimeDuration('P1D')
            else if (matches($ls,'^\dm$'))
            then $current + xs:int(substring($ls,1,1))*28*xs:dayTimeDuration('P1D')
            else if (matches($string, '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$'))
                then if (contains($string,'.'))         (: short german date :)
                    then ndate:ddmmyy-to-date($string)
                    else if (contains($string,'-'))     (: short iso8601 :)
                    then ndate:yymmdd-to-date($string)
                    else $string
                else ndate:ddmmyyyy-to-date($string)     (: german date :)
        return
            xs:date(format-date(adjust-date-to-timezone($date),"[Y0001]-[M01]-[D01]"))
    }
};

(:~
 : converts several shortcuts to xs:dateTime
 : ('auto','heute','h'), ('m'), ('nW'), ('nM'), ('\dw'), ('\dm'), ('dd.mm.yy')
 : actual time is used to fill
 : 
 : @param $string   string
 : @return xs:dateTime?
 :)
declare function ndate:easyDateTime($string as xs:string, $epoch as xs:dateTime) as xs:dateTime
{
    try {
        xs:dateTime($string)
    } catch * {
        let $ls := lower-case($string)
        let $current := $epoch
        let $dt :=
            switch ($ls)
            case "auto"  return $current
            case "heute" return $current
            case "h"     return $current  
            case "m"     return $current +    xs:dayTimeDuration('P1D')       
            case "nw"    return $current +  7*xs:dayTimeDuration('P1D')
            case "nm"    return $current + 28*xs:dayTimeDuration('P1D')
            case "p90d"  return current-dateTime() + 90*xs:dayTimeDuration('P1D')
            default return
                if (matches($ls,'^\dw$'))
                then $current + xs:int(substring($ls,1,1))*7*xs:dayTimeDuration('P1D')
                else if (matches($ls,'^\d\dw$'))
                then $current + xs:int(substring($ls,1,2))*7*xs:dayTimeDuration('P1D')
                else if (matches($ls,'^\dm$'))
                then $current + xs:int(substring($ls,1,1))*28*xs:dayTimeDuration('P1D')
                else if (matches($ls,'^\d\dm$'))
                then $current + xs:int(substring($ls,1,2))*28*xs:dayTimeDuration('P1D')
                else if (matches($string, '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$'))
                    then if (contains($string,'.'))         (: short german date :)
                        then xs:dateTime(concat(ndate:ddmmyy-to-date($string), 'T08:00:00'))
                        else if (contains($string,'-'))     (: short iso8601 :)
                        then xs:dateTime(concat(ndate:yymmdd-to-date($string), 'T08:00:00'))
                        else $string
                    else if (contains($string,'-'))
                        then xs:dateTime(concat(ndate:yyyymmdd-to-date($string), 'T08:00:00'))     (: iso date :)
                        else xs:dateTime(concat(ndate:ddmmyyyy-to-date($string), 'T08:00:00'))     (: german date :)
        return
            xs:dateTime(format-dateTime(adjust-dateTime-to-timezone($dt),"[Y0001]-[M01]-[D01]T[H01]:[m01]:[s01]"))
    }
};

(:~
 : show dateTime with simplifications for recent times
 : 
 : @param $dateTime
 : @return string
 :)
declare function ndate:formatDateTime($dateTime as xs:dateTime) {
    let $diff := ndate:now() - $dateTime
    let $daysAgo := days-from-duration($diff)
    let $hoursAgo := hours-from-duration($diff)
    let $minAgo := minutes-from-duration($diff)
    let $secsAgo := seconds-from-duration($diff)
    return
        if ($daysAgo eq 0) then
            if($hoursAgo eq 0) then
                if ($minAgo eq 0) then
                    "just now"
                else
                    $minAgo || " minutes ago"
                
            else
                $hoursAgo || " hours ago"
        else if ($daysAgo lt 14) then
            $daysAgo || " days ago"
        else
            format-dateTime($dateTime, "EEE, d MMM yyyy HH:mm:ss")
};

declare function ndate:mmddyyyy-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$',
                        '$3-$1-$2'))
};

declare function ndate:mmddyy-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$')))
        then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$',
                        '20$3-$1-$2'))
};
 
declare function ndate:ddmmyyyy-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$')))
        then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$',
                        '$3-$2-$1'))
};
 
declare function ndate:ddmmyy-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$',
                        '20$3-$2-$1'))
};
 
   
declare function ndate:yyyymmdd-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{4})\D*(\d{2})\D*(\d{2})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{4})\D*(\d{2})\D*(\d{2})\D*$',
                        '$1-$2-$3'))
};
 
declare function ndate:yymmdd-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$',
                        '20$1-$2-$3'))
};
 
(:  
declare function ndate:yyyyddmm-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{4})\D*(\d{2})\D*(\d{2})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{4})\D*(\d{2})\D*(\d{2})\D*$',
                        '$1-$3-$2'))
};
 
declare function ndate:yyddmm-to-date 
  ( $dateString as xs:string? )  as xs:date? {
       
   if (fn:empty($dateString))
   then ()
   else if (fn:not(fn:matches($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$')))
   then fn:error(xs:QName('ndate:Invalid_Date_Format'))
   else xs:date(fn:replace($dateString,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{2})\D*$',
                        '20$1-$3-$2'))
};
:)
