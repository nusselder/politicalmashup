(: 
Author: Arjan Nusselder
Date : Oktober 2011
Purpose: Show statistics over collections.

(GET) Parameters
col = see collections.xqm
speakers = true/false
missing-speakers = true/false
:)


declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace pm = "http://www.politicalmashup.nl";
declare namespace exist ="http://exist.sourceforge.net/NS/exist";
declare namespace local ="local";

import module namespace util="http://exist-db.org/xquery/util";
import module namespace kwic="http://exist-db.org/xquery/kwic"; 

 
import module namespace request="http://exist-db.org/xquery/request";
import module namespace session="http://exist-db.org/xquery/session";

import module namespace export="http://politicalmashup.nl/modules/export";


declare function local:session-url($house, $legislative-period, $session) {
    let $house := if ($house eq 'commons') then 'TK' else if ($house eq 'senate') then 'EK' else 'VV'
    return concat('https://zoek.officielebekendmakingen.nl/handelingen/',$house,'/',$legislative-period,'/',$session)
};



(: TODO: put everything that queries the data in functions, so we can easily translate to upload data. :)

declare function local:doc-in-session($lp-col, $session) {
  $lp-col[.//pm:session-number eq $session]
};

declare function local:legislative-periods($collection) {
  distinct-values($collection//pm:legislative-period)
};

declare function local:legislative-house-documents($collection, $lp, $house) {
  $collection[.//pm:legislative-period eq $lp][.//pm:house/@pm:house eq $house]
};

declare function local:topic-count($lp-col) {
  count($lp-col//pm:topic)
};

declare function local:session-numbers($lp-col) {
  distinct-values($lp-col//pm:session-number)
};


declare function local:matching-page-number($col, $page) {
  if (empty($col//pm:proceedings[./pm:topic[1][xs:integer(@pm:source-start-page) le $page] and ./pm:topic[last()][xs:integer(@pm:source-end-page) ge $page]])) then false() else true()
};

(: TODO: this function needs two formats, one for 1995 and one for 2011 :)
declare function local:open-close-checks($lp-col-session) {
          <oc>
          {
          for $c in $lp-col-session//pm:proceedings
            let $s := $c//pm:topic[1]/@pm:source-start-page
            let $e := $c//pm:topic[last()]/@pm:source-end-page
            order by $s, $e
            return
              <openclose>
                <open>{if ($c//pm:stage-direction[@pm:type eq 'intro']) then 'yes' else 'no'}</open>
                <close>?</close>
              </openclose>
          }
          </oc>
};

declare function local:page-start($lp-col-session) {
  string(min($lp-col-session//pm:topic[1]/@pm:source-start-page))
};

declare function local:page-end($lp-col-session) {
  string(max($lp-col-session//pm:topic[last()]/@pm:source-end-page))
};

declare function local:page-present($lp-col-session) {
  for $lp in $lp-col-session
    let $s := $lp//pm:topic[1]/@pm:source-start-page
    let $e := $lp//pm:topic[last()]/@pm:source-end-page
    return
      (xs:integer($s) to xs:integer($e))
};

declare function local:col-with-items($lp-col) {
  $lp-col[.//pm:item-number/text() ne '']
};

declare function local:session-item-string($lp) {
  concat($lp//pm:session-number,'-',$lp//pm:item-number)
};

declare function local:item-numbers($lp-col-sessions) {
  $lp-col-sessions//pm:item-number
};

declare function local:dates($lp-col) {
  string-join(distinct-values($lp-col//dc:date), " ")
};



declare function local:sessions($lp-col) {
  let $lp-sessions := local:session-numbers($lp-col)
  let $lp-session-count := count($lp-sessions)
  let $lp-sessions := for $s in $lp-sessions return if ($s castable as xs:double) then $s else <pm:session-number>0</pm:session-number>
  let $lp-session-min := min($lp-sessions[. ne '0'])
  let $lp-session-max := max($lp-sessions[. ne '0'])
  let $lp-session-missing := (xs:integer($lp-session-min) to xs:integer($lp-session-max))[not(. = $lp-sessions)]
  return
    <result>
      <count>{$lp-session-count}</count>
      <sessions>{$lp-sessions}</sessions>
      <min>{$lp-session-min}</min>
      <max>{$lp-session-max}</max>
      <missing>{for $m in $lp-session-missing return <m>{$m}</m>}</missing>
      <string>{concat($lp-session-count,' (',$lp-session-min,'-',$lp-session-max,')')}</string>
    </result>
};


declare function local:openclose($lp-col,$house,$lp) {
  let $lp-sessions := local:session-numbers($lp-col)

  let $lp-session-pages :=
    <sessions>
      {
      for $session in $lp-sessions
        let $lp-col-session := local:doc-in-session($lp-col,$session)
        
        let $lp-col-ordered := local:open-close-checks($lp-col-session)
            
        return
          <session>
            <session>{$session}</session>
            <open>{$lp-col-ordered/openclose[1]/open}</open>
            <close>{$lp-col-ordered/openclose[last()]/close}</close>
          </session>
      }
    </sessions>

  return
    <result>
      <sessions>{$lp-sessions}</sessions>
      <string>{for $lp-p in $lp-session-pages/session where $lp-p/open ne 'yes' order by xs:integer($lp-p/session) return <p><a href="{local:session-url($house,$lp,$lp-p/session)}">{normalize-space($lp-p/session)}</a>: {$lp-p/open}-{$lp-p/close}</p>}</string>
    </result>
};


declare function local:pages($lp-col,$house,$lp) {
  let $lp-sessions := local:session-numbers($lp-col)

  let $lp-session-pages :=
    <sessions>
      {
      for $session in $lp-sessions
        let $lp-col-session := local:doc-in-session($lp-col,$session)
      
        let $lp-page-start := local:page-start($lp-col-session)
        let $lp-page-end := local:page-end($lp-col-session)
        let $lp-page-range := (xs:integer($lp-page-start) to xs:integer($lp-page-end))
        let $lp-page-present := local:page-present($lp-col-session)
        
        let $lp-page-dates := local:dates($lp-col-session)
        
        (:
        let $lp-missing-pages :=
          for $lp-page in $lp-page-range
          where not(local:matching-page-number($lp-col-session, $lp-page))
          return $lp-page
        :)
        let $lp-missing-pages := $lp-page-range[not(. = $lp-page-present)]
        
        let $lp-missing-pages-starts :=
          for $i in $lp-missing-pages
            where not(($i - 1) = $lp-missing-pages)
            return $i
            
        let $lp-missing-pages-ends :=
          for $i in $lp-missing-pages
            where not(($i + 1) = $lp-missing-pages)
            return $i

        let $lp-missing-pages-collapsed :=
          for $i in 1 to count($lp-missing-pages-starts)
            let $s := $lp-missing-pages-starts[position() eq $i]
            let $e := $lp-missing-pages-ends[position() eq $i]
            return
              if ($s eq $e) then $e else concat($s,'-',$e)
             
        
        return
          <session>
            <session>{$session}</session>
            <session-order>{if ($session castable as xs:double) then $session else 0}</session-order>
            <min>{$lp-page-start}</min>
            <max>{$lp-page-end}</max>
            <missing>{$lp-missing-pages}</missing>
            <missing-col>{$lp-missing-pages-collapsed}</missing-col>
            <string>[({$lp-page-start}-{$lp-page-end}) {$lp-page-dates}]</string>
          </session>
      }
    </sessions>

  return
    <result>
      <sessions>{$lp-sessions}</sessions>
      <missing>{for $lp-p in $lp-session-pages/session where $lp-p/missing ne '' order by xs:integer($lp-p/session-order) return <p><span><a href="{local:session-url($house,$lp,$lp-p/session)}">{normalize-space($lp-p/session)}</a>: {string-join($lp-p/missing-col,",")}</span><span style="color: grey;">{$lp-p/string/text()}</span></p>}</missing>
      <string-full>{for $lp-p in $lp-session-pages/session order by xs:integer($lp-p/session-order) return <p><span><a href="{local:session-url($house,$lp,$lp-p/session)}">{normalize-space($lp-p/session)}</a>: {$lp-p/min}-{$lp-p/max}</span></p>}</string-full>
      <string-collapsed>{for $lp-p in $lp-session-pages/session where $lp-p/missing ne '' order by xs:integer($lp-p/session-order) return <p><span><a href="{local:session-url($house,$lp,$lp-p/session)}">{normalize-space($lp-p/session)}</a>: {string-join($lp-p/missing-col,",")}</span></p>}</string-collapsed>
      <string></string>
    </result>
};

declare function local:items($lp-col,$house,$lp) {
  let $lp-col-with-items := local:col-with-items($lp-col)
    
  let $lp-concat := for $lp in $lp-col-with-items return local:session-item-string($lp)
  let $lp-items-count := count(distinct-values($lp-concat))
  
  let $lp-sessions := local:session-numbers($lp-col-with-items)
  let $lp-session-items :=
    <sessions>
      {
      for $session in $lp-sessions
        let $lp-col-sessions := local:doc-in-session($lp-col-with-items,$session)
        let $lp-items := local:item-numbers($lp-col-sessions)
        let $lp-item-count := count($lp-items)
        let $lp-item-min := min($lp-items)
        let $lp-item-max := max($lp-items)
        let $lp-items-string := string-join($lp-items, " ")
        let $lp-item-dates := local:dates($lp-col-sessions)
        let $lp-item-missing := for $i in (xs:integer($lp-item-min) to xs:integer($lp-item-max))[not(. = $lp-items)] return string($i)
        return
          <session>
            <session>{$session}</session>
            <count>{$lp-item-count}</count>
            <min>{$lp-item-min}</min>
            <max>{$lp-item-max}</max>
            <missing>{$lp-item-missing}</missing>
            <string>{concat(' [',$lp-item-count,' (',$lp-item-min,'-',$lp-item-max,')',' ',$lp-item-dates,']')}</string>
          </session>
      }
    </sessions>
    
  let $lp-missing-items :=
    for $session in $lp-session-items/session
    return
      $session
  
  return
    <result>
      <count>{$lp-items-count}</count>
      <sessions>{$lp-sessions}</sessions>
      <string>{for $lp-i in $lp-missing-items where $lp-i/missing/text() ne '' order by xs:integer($lp-i/session) return <p><span><a href="{local:session-url($house,$lp,$lp-i/session)}">{normalize-space($lp-i/session)}</a>: {string-join($lp-i/missing, ",")}</span><span style="color: grey;">{$lp-i/string/text()}</span></p>}</string>
    </result>
};






(: Build one house, all periods :)
declare function local:old-documents-code($collection, $house) {
  let $legislative-periods := local:legislative-periods($collection)
  let $legislative-periods := ('2011-2012')

  return
    <table style="margin-bottom: 15px;">
      <colgroup>
        <col style="width:80px;"/>
        <col style="width:70px;"/>
        <col style="width:100px;"/>
        <col style="width:80px;"/>
        <col style="width:350px;"/>
        <col style="width:80px;"/>
        <col style="width:70px;"/>
        <col style="width:auto;"/>
      </colgroup>
      <tr> 
        <th>verg. jaar</th>
        <th>house</th>
        <th>#sessies (van-tot)</th>
        <th>missende sessies</th>
        <th>missende bladzijdes (sessie:blz, [(van-tot) datum])</th>
        <th>#items (topics)</th>
        <th>sessie: opening - sluiting</th>
        <th>missende items (sessie:items, [aantal (van-tot) datum])</th>
      </tr>
      {
      for $lp in $legislative-periods
        let $lp-col := local:legislative-house-documents($collection, $lp, $house)
        let $lp-topic-cnt := local:topic-count($lp-col)
        let $lp-sessions := local:sessions($lp-col)
        let $lp-items := local:items($lp-col,$house,$lp)
        let $lp-pages := local:pages($lp-col,$house,$lp)
        (:let $lp-pages := <a><missing>hoi</missing></a>:)
        let $lp-openclose := local:openclose($lp-col,$house,$lp)
        let $b := ''
        order by $lp
        return
          <tr> 
            <td>{$lp}</td>
            <td>{$house}</td>
            <td>{$lp-sessions/string/text()}</td>
            <td>{for $m in $lp-sessions/missing/* return <a href="{local:session-url($house,$lp,$m)}">{normalize-space($m/text())}</a>}</td>
            <td>{$lp-pages/missing}</td>
            <td>{$lp-items/count/text()} ({$lp-topic-cnt})</td>
            <td>{$lp-openclose/string}</td>
            <td>{$lp-items/string}</td>
          </tr>
      }
    </table>
};

































(: Build one house, all periods :)
declare function local:documents($house, $collection, $lp) {

  let $column-names := export:xml-util-headers( ('verg. jaar', 'house', '#sessies (van-tot)', 'missende sessies', 'missende bladzijdes (sessie:blz, [(van-tot) datum])', '#items (topics)', 'sessie: opening - sluiting', 'missende items (sessie:items, [aantal (van-tot) datum])') )  
  let $description := export:xml-util-description('Completeness')

  let $items :=
    let $lp-col := local:legislative-house-documents($collection, $lp, $house)
    let $lp-topic-cnt := local:topic-count($lp-col)
    let $lp-sessions := local:sessions($lp-col)
    let $lp-items := local:items($lp-col,$house,$lp)
    let $lp-pages := local:pages($lp-col,$house,$lp)
    (:let $lp-pages := <a><missing>hoi</missing></a>:)
    let $lp-openclose := local:openclose($lp-col,$house,$lp)
    return
      export:xml-row(
          (
          export:xml-item($lp),
          export:xml-item($house),
          export:xml-item($lp-sessions/string),
          export:xml-item(for $m in $lp-sessions/missing/* return <a href="{local:session-url($house,$lp,$m)}">{normalize-space($m/text())}</a>, <options copy="true"/>),
          export:xml-item($lp-pages/missing/*, <options copy="true"/>),
          export:xml-item(concat($lp-items/count, ' (',$lp-topic-cnt,')')),
          export:xml-item($lp-openclose/string),
          export:xml-item($lp-items/string)
          (:export:xml-item(export:link-resolver(root($vote)//dc:identifier, 'html', $vote/@pm:id),
                       <options display="vote html" link="true"/>),:)
          )
      )
      
  let $xml := export:xml-output( ($description, $column-names, $items) )
  
  return $xml
};


let $col-proc := collection('/db/data/permanent/d/nl/proc/ob')

let $available-periods := export:data-util-legislative-periods($col-proc)

let $request := export:request-parameters( (<view default="table" accept="csv,table,xml"/>, <period accept="{string-join($available-periods,',')}"/>, <house accept="commons,senate,other,all"/>) )

let $serialization := export:set-serialization( if ($request/@view eq 'table') then 'html' else if ($request/@view eq 'csv') then 'text' else 'xml' )


let $houses := if ($request/@house eq 'all') then ('commons', 'senate','other') else (string($request/@house))

let $xml-outputs := if (not(empty($request/@period) or empty($request/@house))) then
                     for $house in $houses return local:documents($house, $col-proc, string($request/@period))
                   else ()


let $links-to-overviews :=
    <div>
      { export:html-util-generate-parameter-links($request, 'house', ('commons','senate','other','all')) }
      { export:html-util-generate-parameter-links($request, 'view', ('table','csv')) }
      { export:html-util-generate-parameter-links($request, 'period', $available-periods) }
    </div>

let $colgroup := <colgroup>
        <col style="width:80px;"/>
        <col style="width:70px;"/>
        <col style="width:100px;"/>
        <col style="width:80px;"/>
        <col style="width:350px;"/>
        <col style="width:80px;"/>
        <col style="width:70px;"/>
        <col style="width:auto;"/>
      </colgroup>

let $output := if ($request/@view eq 'table') then ($links-to-overviews, for $xml-output in $xml-outputs return export:html-output($xml-output, $colgroup))
               else if ($request/@view eq 'csv') then for $xml-output in $xml-outputs return export:csv-output($xml-output)
               else if ($request/@view eq 'xml') then $xml-outputs
               else ()

let $output := export:output($request/@view, $output, 'Complete')

return $output