xquery version "3.1";
(: ~
 : Allen interval realations
 : 
 : @author Peter Herkenrath
 : @version 0.2
 : 2015-06-29
 : 2026-06-29
 : 
 : 
 :)
module namespace nallen ="http://eNahar.org/ns/lib/ical/allen";


declare function nallen:before($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value < $b/*:start/@value and $a/*:end/@value < $b/*:end/@value)
};

declare function nallen:meets($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value < $b/*:start/@value and $a/*:end/@value = $b/*:start/@value)
};

declare function nallen:overlaps($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value < $b/*:start/@value and $a/*:end/@value > $b/*:start/@value and $a/*:end/@value < $b/*:end/@value)
};

declare function nallen:finishedBy($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value < $b/*:start/@value and $a/*:end/@value = $b/*:end/@value)
};

declare function nallen:contains($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value < $b/*:start/@value and $a/*:end/@value > $b/*:end/@value)
};

declare function nallen:starts($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value = $b/*:start/@value and $a/*:end/@value < $b/*:end/@value)
};

declare function nallen:equals($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value = $b/*:start/@value and $a/*:end/@value = $b/*:end/@value)
};

declare function nallen:startedBy($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value = $b/*:start/@value and $a/*:end/@value > $b/*:end/@value)
};

declare function nallen:during($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value > $b/*:start/@value and $a/*:end/@value < $b/*:end/@value)
};

declare function nallen:finishes($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value > $b/*:start/@value and $a/*:end/@value = $b/*:end/@value)
};

declare function nallen:overlapedBy($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value > $b/*:start/@value and $a/*:start/@value < $b/*:end/@value and $a/*:end/@value > $b/*:end/@value)
};

declare function nallen:metBy($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value = $b/*:end/@value and $a/*:end/@value > $b/*:end/@value)
};

declare function nallen:precededBy($a as item(), $b as item()) as xs:boolean
{
    ($a/*:start/@value > $b/*:end/@value and $a/*:end/@value > $b/*:end/@value)
};

(:~
 : Allen's Interval Relations
 : p before
 : m meets
 : o overlaps
 : F finishedBy
 : D contains
 : s starts
 : e equals
 : S startedBy
 : d during
 : f finishes
 : O overlapedBy
 : M metBy
 : P precededBy
 :) 
declare function nallen:relation($a as item(), $b as item()) as xs:string
{
    if ($a/*:start/@value < $b/*:start/@value)
    then
        if      ($a/*:end/@value < $b/*:start/@value) then "p"
        else if ($a/*:end/@value = $b/*:start/@value) then "m"
        else if ($a/*:end/@value > $b/*:start/@value and $a/*:end/@value < $b/*:end/@value) then "o"
        else if ($a/*:end/@value = $b/*:end/@value )  then "F"
        else                               "D"
    else if ($a/*:start/@value = $b/*:start/@value)
    then
        if      ($a/*:end/@value < $b/*:end/@value)   then "s"
        else if ($a/*:end/@value = $b/*:end/@value)   then "e"
        else                               "S"
    else if ($a/*:start/@value > $b/*:start/@value and $a/*:start/@value < $b/*:end/@value)
    then
        if      ($a/*:end/@value < $b/*:end/@value)   then "d"
        else if ($a/*:end/@value = $b/*:end/@value)   then "f"
        else                               "O"
    else if ($a/*:start/@value = $b/*:end/@value)     then "M"
    else                                   "P"
};
