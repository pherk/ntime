xquery version "3.1";
import module namespace ntime= "http://eNahar.org/ns/lib/ical/ntime";


let $t1s  := "2017-03-13T09:30:00"
let $t1e  := "2017-03-13T11:30:00"
let $t2s  := "2017-03-13T13:30:00"
let $t2e  := "2017-03-13T15:30:00"
let $a1s  := "2017-03-13T08:00:00"
let $a1e  := "2017-03-13T12:00:00"
let $a2s  := "2017-03-13T08:00:00"
let $a2e  := "2017-03-13T11:00:00"
let $a3s  := "2017-03-13T12:00:00"
let $a3e  := "2017-03-13T14:00:00"
let $a4s  := "2017-03-13T12:00:00"
let $a4e  := "2017-03-13T14:00:00"

let $rawTPs0 :=
    (
      ntime:new($t1s,$t1e,"")
    )
let $rawTPs1 :=
    (
      ntime:new($t2s,$t2e,"")
    )
let $rawTPs2 :=
    (
      ntime:new($t1s,$t1e,"")
    , ntime:new($t2s,$t2e,"")
        
    )
let $absent0 :=
    (
        ntime:new($a1s,$a1e,"")
    )
let $absent1 :=
    (
        ntime:new($a2s,$a2e,"")
    )
let $absent2 :=
    (
        ntime:new($a3s,$a3e,"")
    )
let $absent3 :=
    (
      ntime:new($a1s,$a1e,"")
    , ntime:new($a3s,$a3e,"")
    )
let $absent4 :=
    (
        ntime:new($a4s,$a4e,"")
    )
return
<result>
    <test id="00">{ntime:subtractPeriods($rawTPs0, $absent0)}</test>
    <test id="10">{ntime:subtractPeriods($rawTPs1, $absent0)}</test>
    <test id="20">{ntime:subtractPeriods($rawTPs2, $absent0)}</test>
    <test id="01">{ntime:subtractPeriods($rawTPs0, $absent1)}</test>
    <test id="11">{ntime:subtractPeriods($rawTPs1, $absent1)}</test>
    <test id="21">{ntime:subtractPeriods($rawTPs2, $absent1)}</test>
    <test id="02">{ntime:subtractPeriods($rawTPs0, $absent2)}</test>
    <test id="12">{ntime:subtractPeriods($rawTPs1, $absent2)}</test>
    <test id="13">{ntime:subtractPeriods($rawTPs1, $absent3)}</test>
    <test id="22">{ntime:subtractPeriods($rawTPs2, $absent2)}</test>
    <test id="23">{ntime:subtractPeriods($rawTPs2, $absent3)}</test>
    <test id="24">{ntime:subtractPeriods($rawTPs2, $absent4)}</test>
</result>
