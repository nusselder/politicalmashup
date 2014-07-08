xquery version "1.0";

import module namespace section-scraping="http://politicalmashup.nl/documentation/section/scraping" at "sections/scraping.xqm";
import module namespace section-transformation="http://politicalmashup.nl/documentation/section/transformation" at "sections/transformation.xqm";
import module namespace section-linking="http://politicalmashup.nl/documentation/section/linking" at "sections/linking.xqm";
import module namespace section-validation="http://politicalmashup.nl/documentation/section/validation" at "sections/validation.xqm";
import module namespace section-access="http://politicalmashup.nl/documentation/section/access" at "sections/access.xqm";
import module namespace section-exist="http://politicalmashup.nl/documentation/section/exist" at "sections/exist.xqm";
import module namespace section-handle="http://politicalmashup.nl/documentation/section/handle" at "sections/handle.xqm";
import module namespace section-sgd="http://politicalmashup.nl/documentation/section/sgd" at "sections/sgd.xqm";

(:
TODO: exist, transformation, sgd, related projects, exposure
TODO: layout: on small-view, some sentence-endings disappear!
:)

declare option exist:serialize "method=html5 media-type=text/html";

<html class="no-js" lang="en">
  <head>
    <meta charset="utf-8"/>
    <title>PoliticalMashup - Documentation</title>
    <meta name="description" content="Documentation for the PoliticalMashup project, with references to all available code, applications and detailed documentation."/>
    <meta name="author" content="Arjan Nusselder"/>

<!-- /ht Andy Clarke - http://front.ie/lkCwyf -->
    <meta http-equiv="cleartype" content="on"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  
    <link rel="shortcut icon" href="images/politicalmashup-icon.png"/>
    <link rel="apple-touch-icon" href="/link/to/apple-touch-icon.png"/>

<!-- /ht Jeremy Keith - http://front.ie/mLXiaS -->
    <link rel="stylesheet" href="css/global.css" media="all"/>
    <link rel="stylesheet" href="css/layout.css" media="all and (min-width: 33.236em)"/>
<!-- 30em + (1.618em * 2) = 33.236em / Eliminates potential of horizontal scrolling in most cases -->

<!--[if (lt IE 9) & (!IEMobile)]>
<link rel="stylesheet" href="css/layout.css" media="all">
<![endif]-->

    <script src="js/libs/modernizr-1.7.min.js"></script>
  </head>

  <body>
    <div id="container" class="cf">
      <header>
        <img src="images/politicalmashup.png" alt="PoliticalMashup Logo" id="header-logo"/>
      </header>
      
      <div id="main" role="main">
      
        <section class="topic">
          <h1>PoliticalMashup Documentation</h1>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#scraping">Scraping</a></li>
                <li><a class="internal" href="#transformation">Transformation</a></li>
                <li><a class="internal" href="#linking">Linking</a></li>
                <li><a class="internal" href="#validation">Validation</a></li>
                <li><a class="internal" href="#access">Data Access</a></li>
                <li><a class="internal" href="#exist">eXist</a></li>
                <li><a class="internal" href="#handle">Handle</a></li>
                <li><a class="internal" href="#sgd">SGD Annotation</a></li>
                <li><a class="internal" href="#related">Related Data and Projects</a></li>
                <li><a class="internal" href="#exposure">Exposure</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p class="intro">Documentation of the PoliticalMashup project; NWO number <span class="todo">(add NWO number)</span>.</p>
              <p class="intro">The goal of the project is to collect some of the many available online sources of political data, and make these available for political researchers in a structured, accessible manner.
                               A strong focus lies on the proceedings/hansards from several European countries, and Dutch members of parliament and political parties.</p>
              <p class="intro">This document describes all steps taken to acquire, process and combine (i.e. mashup) the data.</p>
            </div>
            <div>
              <p>The data exists in three stages.
                 First is the original source, located somewhere online in many different forms.
                 Second are the clean xml versions of the data, collected through a <a class="internal" href="#scraping">scraping</a> process.
                 Third is a <a class="internal" href="#transformation">transformed</a>, fully specified and <a class="internal" href="#validation">validated</a> set of structured documents.
                 The final documents have been <a class="internal" href="#linking">enriched</a> with explicit links to other documents, both internal and external.</p>
               <p>The concluding data set is stored in the native xml database <a class="internal" href="#exist">eXist</a>, and <a class="internal" href="#access">accessible</a> through a multitude of search and listing interfaces.
                  Permanent identifiers for the documents are available through the <a class="internal" href="#handle">Handle</a> system.</p>
               <p>Related <a class="internal" href="#related">projects</a> include the <a class="internal" href="#sgd">annotation of speakers</a> in the Dutch proceedings archive.</p>
             </div>
             <div>
               <h3 class="todo">General todo remarks</h3>
               <p class="todo">crontab automatically pulls transformers/schema from git; this has been disabled due to lack of further development.</p>
               <p class="todo">Our data resides in the urn:nbn:nl:ui:35 namespace (see e.g. OAI).</p>
               <p class="todo">Check http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashup for twiki links.</p>
            </div>
          </div>
          <aside>
            <h3>Legend</h3>
            <section class="legend">
              <dl>
                <dd><a class="internal" href="">Internal link in this documentation.</a></dd>
                <dd><a class="politicalmashup" href="">Link to data/process from PoliticalMashup.</a></dd>
                <dd><a class="external" href="">Link to external source.</a></dd>
                <dd><code>Literal technical term.</code></dd>
                <dd class="nb">Important (status) remark.</dd>
                <dd class="old">Old (outdated) remark.</dd>
                <dd class="todo">Todo (remove when done).</dd>
              </dl>
            </section>
          </aside>
        </section>

        {section-scraping:content()}
        
        {section-transformation:content()}

        {section-linking:content()}
        
        {section-validation:content()}
        
        {section-access:content()}
        
        {section-exist:content()}
        
        {section-handle:content()}

        {section-sgd:content()}

        
        
        
        
        <section id="related" class="topic">
          <h2>Related Data and Projects</h2>
          <h6>Several projects have been build using methods created for the PoliticalMashup project.</h6>
          <div class="section-content">
            <div>
              <h3 class="todo" id="related-xml.politicalmashup.nl">xml.politicalmashup.nl</h3>
              <p><a href="http://ilps.science.uva.nl/twiki/bin/view/Main/WebSearch?search=xml.politicalmashup.nl&amp;scope=all&amp;web=Main">twiki search</a></p>
              <p>old exist database with old demo's</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/WomenInParliament</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/PartyIdentifiers ???</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/SkewnessInParliament</p>
              <p>http://xml.politicalmashup.nl/XQueries/debates/inoutdegree.xq</p>
              <p>http://xml.politicalmashup.nl/XQueries/debates/debatverdeling.xq?period=kok1</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/NewMembersParliament</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/PentaPoliticaWrapper</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/PlanningLente2011</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/NRCDataProcessing</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/MigratingExist</p>
              <p>http://xml.politicalmashup.nl/XQueries/debates/kamerleden.xq (old semi-working demo?)</p>
              <p>german data by Hendrike? http://ilps.science.uva.nl/twiki/bin/view/Main/HendrikeRDFPlanning</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/ViewProceedings politicalmashup HAN in xml.poli..</p>
              <p>SIGMOD: http://ilps.science.uva.nl/twiki/bin/view/Main/SigmodRecordInterviews</p>
              <p></p>
              <p></p>
              <p></p>
              <p></p>
              <p>possibly these applications:??<br/>
                 Pentapolitica<br/>
                 Studenten-applicaties<br/>
                 openkamer.tv<br/>
                 PoliDocs<br/>
                 Verkiezingskijker<br/>
                 Barcode Browser</p>
            </div>
            <div>
              <h3 class="todo">Amendments</h3>
              <p>Amendment analysis for the "Dienst Informatievoorziening".</p>
              <p>http://data.politicalmashup.nl/arjan/amendementen/readme.html</p>
            </div>
            <div>
              <h3 class="todo">rdf triple store/sparql</h3>
              <p>a virtuoso database with sparql end-point, fed with all rdf views of the data, can be queried</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/PublishingLinkedPoliticalMashup</p>
            </div>
            <div>
              <h3 class="todo">Populisme, rise-of comparison between nl and scandinavia.</h3>
              <p>---</p>
            </div>
            <div>
              <h3 class="todo">War in Parliament</h3>
              <p>---</p>
            </div>
            <div>
              <h3 class="todo">Namescape</h3>
              <p>---</p>
            </div>
            <div>
              <h3 class="todo">Loe de Jong</h3>
              <p>---</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/VerrijktKoninkrijk</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/VerrijktKoninkrijkSetup</p>
            </div>
            <div>
              <h3 class="todo">NRC?</h3>
              <p>---</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/NRCDataProcessing</p>
            </div>
            <div>
              <h3 class="todo">ikkieswijzer.nl / euverkiezingskijker.iets?</h3>
              <p>---</p>
            </div>
            <div>
              <h3 class="todo">KB Kranten</h3>
              <p>---</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupKBPapers</p>
              <p>data: mashup1:/scratch1/data/KB/</p>
            </div>
            <div>
              <h3 class="todo">Folia</h3>
              <p>---</p>
              <p>http://ilps.science.uva.nl/twiki/bin/view/Main/LarsPipeline</p>
            </div>
          </div>
          
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="...">...</a></dt>
                <dd>Something external.</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="...">...</a></dt>
                <dd>Something of us online.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="...">...</a></dt>
                <dd>Something example.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/...">...</a></dt>
                <dd>Something twiki.</dd>
                <dt>arjan logs</dt>
                <dd>add personal logpages etc. from arjan</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/...">politicalmashup/...</a></dt>
                <dd>Something git.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup0123:/some/path</code></dt>
                <dd>Something data.</dd>
              </dl>
            </section>
          </aside>
        </section>

        <section id="exposure" class="topic">
          <h2>Exposure</h2>
          <h6>PoliticalMashup has collaborated with journalists, and published and presented at scientific conferences.</h6>
          <div class="section-content">
            <div>
              <h3 class="todo">Members</h3>
              <p>list people? maarten marx, arjan nusselder, bart de goede, justin van wees, johan doornik, lars buitinck, isaac sijaranamual, anne schuth, steven grijzenhout?</p>
              <p>scrape arjan's twiki for info:
              http://ilps.science.uva.nl/twiki/bin/view/Main/ArjanNusselderTODO
              http://ilps.science.uva.nl/twiki/bin/view/Main/ArjanNusselderTodoArchive
              http://ilps.science.uva.nl/twiki/bin/view/Main/ArjanNusselderLogBook</p>
            </div>
            <div>
              <h3 class="todo">Publications</h3>
              <p>list publications? list conferences? (dir, okcon, ding in enschede van bart-en-justin, etc?)</p>
            </div>
            <div>
              <h3 class="todo">Newspapers</h3>
              <p>VN, nrc, ?</p>
            </div>
            <div>
              <h3 class="todo">Blog</h3>
              <p>politicalmashup.nl</p>
            </div>
            <div>
              <h3 class="todo">KB/Dienst informatie voorziening?</h3>
              <p>---</p>
            </div>
            <div>
              <h3 class="todo">Other collaborations?</h3>
              <p>Marina Lacroix, Wijfjes, ?</p>
            </div>
          </div>
          
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="...">...</a></dt>
                <dd>Something external.</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="...">...</a></dt>
                <dd>Something of us online.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="...">...</a></dt>
                <dd>Something example.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/...">...</a></dt>
                <dd>Something twiki.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/...">politicalmashup/...</a></dt>
                <dd>Something git.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup0123:/some/path</code></dt>
                <dd>Something data.</dd>
              </dl>
            </section>
          </aside>
        </section>

      </div>
      <footer>PoliticalMashup version 0.5
              <br/>Last update: 2013-06-26
              <br/><span class="todo">add contact information?</span></footer>
    </div>
  </body>
</html>