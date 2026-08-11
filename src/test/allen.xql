xquery version "3.0";
module namespace allent ="http://enahar.org/enahar/test/allen-test";

import module namespace test="http://exist-db.org/xquery/xqsuite" at "resource:org/exist/xquery/lib/xqsuite/xqsuite.xql";

import module namespace nallen ="http://eNahar.org/ns/lib/ical/allen" at "../content/allen.xqm";

declare %test:setUp function allent:setup()
{
    ()
};

declare %test:tearDown function allent:cleanup()
{
    ()
};
(: ----------------------------
: Actual tests below this line
: ---------------------------- :)

declare %test:assertTrue function allent:before-s() as xs:boolean
{
  nallen:before(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T09:00:00"/></timeperiod>
               ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("p") function allent:before-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T09:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:meets-s() as xs:boolean
{
  nallen:meets(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T10:00:00"/></timeperiod>
              ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("m") function allent:meets-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T10:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};


declare %test:assertTrue function allent:overlaps-s() as xs:boolean
{
  nallen:overlaps(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T10:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("o") function allent:overlaps-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T10:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:finishedBy-s() as xs:boolean
{
  nallen:finishedBy(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
                   ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("F") function allent:finishedBy-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:contains-s() as xs:boolean
{
  nallen:contains(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T12:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("D") function allent:contains-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T08:30:00"/><end value="2000-01-01T12:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:starts-s() as xs:boolean
{
  nallen:starts(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T10:30:00"/></timeperiod>
               ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("s") function allent:starts-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T10:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:equals-s() as xs:boolean
{
  nallen:equals(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
               ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("e") function allent:equals-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:startedBy-s() as xs:boolean
{
  nallen:startedBy(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
                  ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("S") function allent:startedBy-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:during-s() as xs:boolean
{
  nallen:during(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T10:40:00"/></timeperiod>
               ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("d") function allent:during-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T10:40:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:finishes-s() as xs:boolean
{
  nallen:finishes(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("f") function allent:finishes-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T11:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:overlapedBy-s() as xs:boolean
{
  nallen:overlapedBy(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
                    ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("O") function allent:overlapedBy-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T10:30:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:metBy-s() as xs:boolean
{
  nallen:metBy(<timeperiod><start value="2000-01-01T11:00:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
              ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("M") function allent:metBy-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T11:00:00"/><end value="2000-01-01T11:30:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertTrue function allent:precededBy-s() as xs:boolean
{
  nallen:precededBy(<timeperiod><start value="2000-01-01T11:30:00"/><end value="2000-01-01T12:00:00"/></timeperiod>
                   ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};

declare %test:assertEquals("P") function allent:precededBy-r() as xs:string
{
  nallen:relation(<timeperiod><start value="2000-01-01T11:30:00"/><end value="2000-01-01T12:00:00"/></timeperiod>
                 ,<timeperiod><start value="2000-01-01T10:00:00"/><end value="2000-01-01T11:00:00"/></timeperiod>)
};
