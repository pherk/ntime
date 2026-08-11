xquery version "3.1";
(: ~
 : iCalendar common functions
 : 
 : @author Peter Herkenrath
 : @version 0.6
 : 2015-03-29
 : 2026-03-29
 : 
 : 
 :)
module namespace nical ="http://eNahar.org/ns/lib/ical/ical";

declare variable $nical:month-lengths := (0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
declare variable $nical:start-of-week := 1; (: Montag :)
declare variable $nical:infos :=
    <info lang="german">
        <firstDay>1</firstDay>
        <monat value="1"  label="Januar"    short="Jan"/>
        <monat value="2"  label="Februar"   short="Feb"/>
        <monat value="3"  label="März"      short="Mar"/>
        <monat value="4"  label="April"     short="Apr"/>
        <monat value="5"  label="Mai"       short="Mai"/>
        <monat value="6"  label="Juni"      short="Jun"/>
        <monat value="7"  label="Juli"      short="Jul"/>
        <monat value="8"  label="August"    short="Aug"/>
        <monat value="9"  label="September" short="Sep"/>
        <monat value="10" label="Oktober"   short="Okt"/>
        <monat value="11" label="November"  short="Nov"/>
        <monat value="12" label="Dezember"  short="Dez"/>
        <day   value="1"  label="Montag"     short="Mo"/>
        <day   value="2"  label="Dienstag"   short="Di"/>
        <day   value="3"  label="Mittwoch"   short="Mi"/>
        <day   value="4"  label="Donnerstag" short="Do"/>
        <day   value="5"  label="Freitag"    short="Fr"/>
        <day   value="6"  label="Samstag"    short="Sa"/>
        <day   value="0"  label="Sonntag"    short="So"/>
        <weekend>Sa</weekend>
        <weekend>So</weekend>
    </info>;

(:~
 : day-of-week
 : 
 : @param $date 
 : 
 : @return the day of week (0..6)
 :)
declare function nical:day-of-week( $date as xs:anyAtomicType? )  as xs:integer?
{
    if (empty($date))
    then ()
    else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7
};

(:~
 : first-weekday-of-month
 : 
 : @param $y   year
 : @param $m   month
 : @param $dow dow
 : 
 : @return date
 :)
declare function nical:first-weekday-of-month($y as xs:integer, $m as xs:integer, $dow as xs:integer) as xs:date
{
    let $first := nical:date($y,$m,1)
    return
    $first + ((7 + $dow - nical:day-of-week($first)) mod 7) * xs:dayTimeDuration('P1D')
};

(:~
 : nth-last-weekday-of month
 : 
 : @param $y   year
 : @param $m   month
 : @param $dow dow
 : @param $nth
 : 
 : @return date
 :)
declare function nical:nth-last-weekday-of-month($y,$m,$dow, $nth)
{
    nical:first-weekday-of-month($y,$m+1,$dow) + xs:dayTimeDuration('P1D') * 7 * $nth
};

(:~
 : is-leap-year
 : 
 : @param $year
 : 
 : @return boolean
 :)
declare function nical:is-leap-year($year) as xs:boolean
{
     ($year mod 4 = 0 and $year mod 100 != 0) or $year mod 400 = 0
};

(:~
 : days-in-month
 : 
 : @param $date
 : 
 : @return integer
 :)
declare function nical:days-in-month( $date as xs:anyAtomicType? )  as xs:integer?
{
   if (month-from-date(xs:date($date)) = 2 and
       nical:is-leap-year($date))
   then 29
   else
   (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31)
    [month-from-date(xs:date($date))]
 } ;


declare %private function nical:repeat-string( $stringToRepeat as xs:string?, $count as xs:integer )  as xs:string
{
    string-join((for $i in 1 to $count return $stringToRepeat), '')
};
 
declare %private function nical:pad-integer-to-length 
  ( $integerToPad as xs:anyAtomicType? ,
    $length as xs:integer )  as xs:string {
       
   if ($length < string-length(string($integerToPad)))
   then error(xs:QName('nical:Integer_Longer_Than_Length'))
   else concat
         (nical:repeat-string(
            '0',$length - string-length(string($integerToPad))),
          string($integerToPad))
};

(:~
 : Date and Time Conversions
 :)

(:~
 : date
 : convert strings to xs:date
 : 
 : @param $year
 : @param $month
 : @param $day
 : 
 : @return date
 :)
declare function nical:date 
  ( $year as xs:anyAtomicType,
    $month as xs:anyAtomicType,
    $day as xs:anyAtomicType )  as xs:date {
       
   xs:date(
     concat(
       nical:pad-integer-to-length(xs:integer($year),4),'-',
       nical:pad-integer-to-length(xs:integer($month),2),'-',
       nical:pad-integer-to-length(xs:integer($day),2)))
};

(:~
 : mmddyyy-to-date
 : convert string to xs:date
 : 
 : @param $date
 : 
 : @return date
 :)
declare function nical:mmddyyyy-to-date( $date as xs:string? )  as xs:date? {
       
   if (empty($date))
   then ()
   else if (not(matches($date,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$')))
   then error(xs:QName('nical:Invalid_Date_Format'))
   else xs:date(replace($date,
                        '^\D*(\d{2})\D*(\d{2})\D*(\d{4})\D*$',
                        '$3-$1-$2'))
};

(:~
 : time
 : convert strings to xs:time
 : 
 : @param $hour
 : @param $minute
 : @param second
 : 
 : @return time
 :)
declare function nical:time 
  ( $hour as xs:anyAtomicType ,
    $minute as xs:anyAtomicType ,
    $second as xs:anyAtomicType )  as xs:time {
       
   xs:time(
     concat(
       nical:pad-integer-to-length(xs:integer($hour),2),':',
       nical:pad-integer-to-length(xs:integer($minute),2),':',
       nical:pad-integer-to-length(xs:integer($second),2)))
};

(:~
 : dateTime
 : convert strings to xs:time
 : 
 : @param $year
 : @param $month
 : @param $day
 : @param $hour
 : @param $minute
 : @param second
 : 
 : @return dateTime
 :)
declare function nical:dateTime 
  ( $year as xs:anyAtomicType ,
    $month as xs:anyAtomicType ,
    $day as xs:anyAtomicType ,
    $hour as xs:anyAtomicType ,
    $minute as xs:anyAtomicType ,
    $second as xs:anyAtomicType )  as xs:dateTime {
       
   xs:dateTime(
     concat(nical:date($year,$month,$day),'T',
            nical:time($hour,$minute,$second)))
};

(:~
 : day-of-week-name
 : @param $date
 : 
 : @return string
 :)
declare function nical:day-of-week-name( $date as xs:anyAtomicType? )  as xs:string? 
{
    let $dow := nical:day-of-week($date)
    return
        $nical:infos//day[@value=$dow]/@label/string()
};

(:~
 : day-of-week-shortname
 : @param $date
 : 
 : @return string
 :)
declare function nical:day-of-week-shortname( $date as xs:anyAtomicType? )  as xs:string? 
{
    let $dow := nical:day-of-week($date)
    return
        $nical:infos//day[@value=$dow]/@short/string()
};

(:~
 : day-name-to-dow
 : 
 : @param $dn   day name
 : 
 : @return integer (0..6)
 :)
declare function nical:dayname-to-dow($dn as xs:string) as xs:integer
{
    xs:integer($nical:infos//day[@short=$dn]/@value/string())
};

(:~
 : month-name
 : 
 : @param $date
 : 
 : @return string
 :)
declare function nical:month-name( $date as xs:anyAtomicType? )  as xs:string? 
{
    let $mo := month-from-date(xs:date($date))
    return
        $nical:infos//month[@value=$mo]/@label/string()
};

(:~
 : month-name-short
 : 
 : @param $date
 : 
 : @return string
 :)
declare function nical:month-name-short( $date as xs:anyAtomicType? )  as xs:string? 
{
    let $mo := month-from-date(xs:date($date))
    return
        $nical:infos//month[@value=$mo]/@short/string()
};

(:~
 : name-mo
 : 
 : @param $mn   month name
 : 
 : @return integer
 :)
declare function nical:name-to-mo($mn as xs:string) as xs:integer
{
    xs:integer($nical:infos//month[@short=$mn]/@value/string())
};

(:~
 : Week funktions
 :)

(:~
 : first-day-of-week
 : 
 : @param $date
 : 
 : @return dateTime
 :)
declare function nical:first-day-of-week($date as xs:dateTime) as xs:dateTime
{
    $date - (xs:dayTimeDuration("P1D") * (nical:day-of-week($date)-$nical:start-of-week))
};

(:~
 : week-of-month
 : first week in month which includes Thursday = 1, non-iso 8601 definition
 : 
 : @param $date
 : 
 : @return integer
 :)
declare function nical:week-of-month($date as xs:dateTime) as xs:integer 
{
    let $first := nical:first-day-of-month($date)
    let $week0 := nical:first-day-of-week($first)
    let $dow1  := nical:day-of-week($first)
    return
        if ($dow1 > 3)
        then nical:diffInWeeks($week0, $date) + 1
        else nical:diffInWeeks($week0, $date) + 2     
};

(:
 : week-of-year
 : the week of the year as a number. First week = 1
 : 
 : @param $date
 : 
 : @return integer
 :)
declare function nical:week-of-year( $date-time as xs:dateTime ) as xs:integer
{
    let $year  := fn:year-from-dateTime( $date-time )
    let $day   := fn:day-from-dateTime( $date-time )
    let $month := fn:month-from-dateTime( $date-time )

    let $days  := sum( subsequence( $nical:month-lengths, 1, $month ) )
    let $is-leap := ($year mod 4 = 0 and $year mod 100 != 0) or $year mod 400 = 0
    return nical:_week-of-year($year, $days + $day + (if ($is-leap and $month > 2) then 1 else 0))
};

declare %private function nical:_week-of-year( $year as xs:integer, $month-days as xs:integer) as xs:integer
{
    let $previous-year := $year - 1
    let $is-leap := ($year mod 4 = 0 and $year mod 100 != 0) or $year mod 400 = 0
    let $dow := ($previous-year + floor($previous-year div 4) -
        floor($previous-year div 100) + floor($previous-year div 400) +
        $month-days) mod 7
    let $day-of-week := if ($dow > 0) then $dow else 7
    let $start-day := ($month-days - $day-of-week + 7) mod 7
    let $week-number := floor(($month-days - $day-of-week + 7) div 7)
cast as xs:integer
    return
        if ($start-day >= 4) then $week-number + 1
        else if ($week-number = 0) then
            let $leap-day := if ((not($previous-year mod 4) and
                        $previous-year mod 100) or not($previous-year mod 400)) then 1 else 0
            return nical:_week-of-year( $previous-year, 365 + $leap-day )
            else $week-number
};

(:~
 : Month Functions
 :)

(:
 : first-of-month
 : 
 : @param $date
 : 
 : @return dateTime
 :)
declare function nical:first-day-of-month( $date as xs:anyAtomicType? )  as xs:dateTime?
{
    nical:dateTime(year-from-date(xs:date($date)), month-from-date(xs:date($date)), 1,
                    hours-from-dateTime($date), minutes-from-dateTime($date), seconds-from-dateTime($date))
};

(:
 : last-of-month
 : 
 : @param $date
 : 
 : @return dateTime
 :)
declare function nical:last-day-of-month( $date as xs:anyAtomicType? )  as xs:dateTime?
{
    nical:dateTime(year-from-date(xs:date($date)), month-from-date(xs:date($date)), nical:days-in-month($date),
                    hours-from-dateTime($date), minutes-from-dateTime($date), seconds-from-dateTime($date))
};

(:~
 : Year Functions
 :)

(:
 : first-day-of-year
 : 
 : @param $date
 : 
 : @return dateTime
 :)
declare function nical:first-day-of-year( $date as xs:anyAtomicType? )  as xs:dateTime?
{
    nical:dateTime(year-from-date(xs:date($date)), 1, 1, 0, 0, 0)
};

(:
 : last-day-of-year
 : 
 : @param $date
 : 
 : @return dateTime
 :)
declare function nical:last-day-of-year( $date as xs:anyAtomicType? )  as xs:dateTime?
{
    nical:dateTime(year-from-date(xs:date($date)), 12, 31, 0, 0, 0)
};
 
 
(:~
 : Durations
 : from functx
 :)

(:~
 : total-seconds-from-duration
 : This is different from the built-in fn:seconds-from-duration function because the latter will normalize the value
 : and only give you the remainder number of seconds between 1 and 60.
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-seconds-from-duration( $duration as xs:dayTimeDuration? )  as xs:decimal?
{       
    $duration div xs:dayTimeDuration('PT1S')
};

(:~
 : total-minutes-from-duration
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-minutes-from-duration( $duration as xs:dayTimeDuration? )  as xs:decimal?
{
    $duration div xs:dayTimeDuration('PT1M')
};

(:~
 : total-hours-from-duration
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-hours-from-duration( $duration as xs:dayTimeDuration? )  as xs:decimal? 
{
    $duration div xs:dayTimeDuration('PT1H')
};

(:~
 : total-days-from-duration function returns the total number of days in $duration.
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-days-from-duration( $duration as xs:dayTimeDuration? )  as xs:decimal? 
{   
    $duration div xs:dayTimeDuration('P1D')
};

(:~
 :  total-months-from-duration
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-months-from-duration( $duration as xs:yearMonthDuration? )  as xs:decimal?
{
    $duration div xs:yearMonthDuration('P1M')
};

(:~ 
 : total-years-from-duration function
 : 
 : @param $duration
 : 
 : @return decimal
 :)  
declare function nical:total-years-from-duration( $duration as xs:yearMonthDuration? )  as xs:decimal?
{
    $duration div xs:yearMonthDuration('P1Y')
};

(:~
 : subtract-dates
 : normalizes the dates to UTC
 : 
 : @param $date1
 : @param $date2
 : 
 : @return duration
 :)  
declare function nical:subtract-dates($d1 as xs:date, $d2 as xs:date) as xs:dayTimeDuration
{
  (: Discard the time and time-zone information. :)
  let $utc1 := nical:date-as-utc($d1)
  let $utc2 := nical:date-as-utc($d2)
  return $utc2 - $utc1
};

(:~
 : subtract-dateTimes
 : normalizes the dates to UTC and subtract
 : 
 : @param $date1
 : @param $date2
 : 
 : @return duration
 :) 
declare function nical:subtract-dateTimes($d1 as xs:dateTime, $d2 as xs:dateTime) as xs:dayTimeDuration
{
    (: Discard the time and time-zone information. :)
    let $utc1 := nical:dateTime-as-utc($d1)
    let $utc2 := nical:dateTime-as-utc($d2)
    return $utc2 - $utc1
};

(:~
 : diffInDays
 : 
 : @param $date1
 : @param $date2
 : 
 : @return integer
 :) 
declare function nical:diffInDays($d1 as xs:dateTime, $d2 as xs:dateTime) as xs:integer
{
    let $diff := $d2 - $d1
    return
        $diff div xs:dayTimeDuration("P1D") 
};

(:~
 : diffInWeeks
 : 
 : @param $date1
 : @param $date2
 : 
 : @return integer
 :) 
declare function nical:diffInWeeks($d1 as xs:dateTime, $d2 as xs:dateTime) as xs:integer
{
    let $diff := nical:first-day-of-week($d2) - nical:first-day-of-week($d1)
    return
        $diff div xs:dayTimeDuration("P7D") 
};

(:~
 : diffInMonths
 : 
 : @param $date1
 : @param $date2
 : 
 : @return integer
 :) 
declare function nical:diffInMonths($d1 as xs:dateTime, $d2 as xs:dateTime) as xs:integer
{
    let $diff := $d2 - $d1
    return
        $diff div xs:dayTimeDuration("P1M") 
};

(:~
 : UTC Functions
 :)

(:~
 : date-as-utc
 : normalizes the date to UTC
 : 
 : @param $date
 : 
 : @return dateTime
 :) 
declare function nical:date-as-utc($date as xs:date) as xs:dateTime
{
  fn:adjust-dateTime-to-timezone (xs:dateTime($date), xs:dayTimeDuration ("PT0H"))
};

(:~
 : dateTime-as-utc
 : normalizes the dateTime to UTC
 : 
 : @param $date
 : 
 : @return dateTime
 :) 
declare function nical:dateTime-as-utc($date as xs:dateTime) as xs:dateTime
{
    adjust-dateTime-to-timezone ($date, xs:dayTimeDuration ("PT0H"))
};

(:~
 : current-as-utc
 : normalizes the current-dateTime to UTC
 : 
 : @return dateTime
 :) 
declare function nical:current-as-utc() as xs:dateTime
{
    nical:dateTime-as-utc (fn:current-dateTime())
};


(:~
 : unix-to-utc
 : current-dateTime as UNIX time
 : 
 : @return dateTime
 :) 
declare function nical:unix-to-utc($unixtime as xs:integer) as xs:dateTime
{ 
    xs:dateTime("1970-01-01T00:00:00-00:00") + xs:dayTimeDuration('PT1S') * $unixtime
};

(:~
 : UNIX time functions
 :)

(:~
 : getUnixTime
 : current-dateTime as UNIX time
 : 
 : @return dateTime
 :) 
declare function nical:getUnixTime() as xs:dateTime
{ 
    (fn:current-dateTime() - xs:dateTime("1970-01-01T00:00:00-00:00")) div xs:dayTimeDuration("PT0.001S") 
};

(:~
 : The Easter functions
 :)

(:~
 : easter
 : 
 : @param $year
 : 
 : @return date
 :)
declare function nical:easter($year as xs:integer) as xs:date
{
let $y := $year
(:  # g - Golden year - 1
    # c - Century
    # h - (23 - Epact) mod 30
    # i - Number of days from March 21 to Paschal Full Moon
    # j - Weekday for PFM (0=Sunday, etc)
    # p - Number of days from March 21 to Sunday on or before PFM
    #     (-6 to 28 methods 1 & 3, to 56 for method 2)
    # e - Extra days to add for method 2 (converting Julian
    #     date to Gregorian date)
:)
let $g := $y mod 19
let $e := 0
let $c := $y idiv 100
let $h := ($c - ($c idiv 4) - (8 * $c + 13) idiv 25 + 19 * $g + 15) mod 30
let $i := $h - ($h idiv 28) * (1 - ($h idiv 28)*(29 idiv ($h + 1))*((21 - $g) idiv 11))
let $j := ($y + ($y idiv 4) + $i + 2 - $c + ($c idiv 4)) mod 7
(: 
    # p can be from -6 to 56 corresponding to dates 22 March to 23 May
    # (later dates apply to method 2, although 23 May never actually occurs)
:)
let $p := $i - $j + $e
let $d := 1 + ($p + 27 + ($p + 6) idiv 40) mod 31
let $m := 3 + ($p + 26) idiv 30
return nical:date($y, $m, $d)
};

