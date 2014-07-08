xquery version "1.0";

module namespace section-scraping="http://politicalmashup.nl/documentation/section/scraping";

declare function section-scraping:content() {
        <section id="scraping" class="topic">
          <h2>Scraping</h2>
          <h6>Dowload available documents from different sources, convert them if necessary, and save as clean utf-8 encoded xml.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#scraping-scrapy">Scrapy</a></li>
                <li><a class="internal" href="#scraping-source-xml">XML output</a></li>
                <li><a class="internal" href="#scraping-sources">Sources</a></li>
                <li><a class="internal" href="#scraping-logs">Process logging</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p>The process of automatically scraping data sources is handled by the <a class="internal" href="#scraping-scrapy">scrapy</a> toolkit, and managed with a bash script and the crontab.</p>
              <p>Different source types (html, xml, pdf) are all converted to valid <a class="internal" href="#scraping-source-xml">xml</a>.
                 This is ensured and a strict responsibility of the scraping module.
                 The next <a class="internal" href="#transformation">transformation</a> step requires valid xml as input.</p>
            </div>
            <div>
              <h3 id="scraping-scrapy">Scrapy</h3>
              <p>Scraping, the process of downloading and storing documents, is done with a python toolkit called <a class="external" href="http://scrapy.org/">Scrapy</a>.</p>
              <p><q cite="http://scrapy.org/">Scrapy is a fast high-level screen scraping and web crawling framework, used to crawl websites and extract structured data from their pages.</q></p>
              <p>Additional dependencies as imported in the python crawlers, apart from scrapy, include: <code>pyexist</code>, <code>lxml</code>, <code>BeautifulSoup</code>, <code>tidylib</code> and <code>wikitools</code>.
                 Make sure these modules are available.</p>
              <p>For each of the <a class="internal" href="#scraping-sources">data sources</a> listed with a [<code>source identifier</code>], a scrapy crawler has been implemented</p>
              <h4>Managing scrapers</h4>
              <p>A scraper implements the process of downloading source data, cleaning it, uploading it to the <a class="internal" href="#transformation">transformation</a> database and logging the results.
                 A scraper is started with the manage script also available in the <a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/scrapy-d">scrapy-d git</a> repository.
                 For example, to start the danish scraper, run <code>./manage.sh schedule dk-udpate</code>.
                 The manage script prevents multiple scraping sessions to run simultaneously, and is executed by the <code>ilps_bg</code> crontab according to the schema listed at the <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupScrapyD">PoliticalMashupScrapyD</a> twiki.</p>
            </div>
            <div>
              <h3 id="scraping-source-xml">XML output format</h3>
              <p>Because all other steps in the project require and utilise XML, valid XML is ensured as early as possible in the process.</p>
              <p>The data comes from three types of source documents: XML, HTML and PDF.
                 XML documents are downloaded as is.
                 HTML documents are cleaned, repaired if necessary, and stored as XML with the HTML elements intact.
                 PDF documents are converted to XML with the <code>pdf2xml</code> tool.</p>
              <p>All source data is downloaded and stored at <code>mashup1:/scratch/data/parliament/</code> in subfolders named as the source crawlers desribed below.</p>
              
              <h4>pdf2xml</h4>
              <p>Converting PDF files to XML is based on the output of <a class="external" href="http://pdftohtml.sourceforge.net/">pdftohtml</a>.
                 Multiple text columns, headers, and footers are reconstructed into a sequential, chronological account of the transcript.
                 Contextual information present on the online overview pages, but not present within the PDF's, can be added with a separately created <code>.dcmeta.xml</code> file.</p>
              <p>Sadly, extracting text from pdf files remains a problematic endeavour.
                 The collection of code used in <code>pdf2xml</code> is flaky, and should be considered working for the currently processed PDF data, but not for other data.</p>
            </div>
            <div>
              <h3 id="scraping-sources">Sources</h3>
              <p>All data was downloaded either with verbal permission, or is assumed without restrictions, unless stated otherwise.
                 Each xml document can be <a class="internal" href="#access-resolver">accessed</a> individually, and has its rights made as explicit as possible in the <code>dc:rights</code> field/element.
                 The permanent data <a class="internal" href="#exist-collections">collections</a> are listed below.</p>
              <p>Some data sets are available per meeting (few documents), others per topic (many documents).
                 We only collected documents from the senate for the Dutch proceedings. Some countries do have both a lower and upper house (commons and senate), but not all, see <a class="external" href="http://en.wikipedia.org/wiki/National_parliaments_of_the_European_Union">http://en.wikipedia.org/wiki/National_parliaments_of_the_European_Union</a> for more information.
                 Dutch proceedings have a third house type "other", that is sometimes used for combined meetings at the start of the legislative year.</p>
              
              <h4>Scraped sources</h4>
              <dl>
                <dt>[<code>nl-ob</code>] Officiele Bekendmakingen (OB)</dt>
                <dd>1994-2013, commons/senate</dd>
                <dd>XML documents</dd>
                <dd><a class="external" href="https://zoek.officielebekendmakingen.nl/">https://zoek.officielebekendmakingen.nl/</a></dd>
                <dd class="description">Current Dutch proceedings and other parliamentary documents are downloaded and available from 1995 and onward.
                    These documents were published digitally, and are generally available as well-formatted xml data.</dd>
                    
                <dt>[<code>nl-sgd</code>] Staten Generaal Digitaal (SGD)</dt>
                <dd>1814-1994, commons/senate</dd>
                <dd>PDF/XML documents</dd>
                <dd><a class="external" href="http://statengeneraaldigitaal.nl/">http://statengeneraaldigitaal.nl/</a></dd>
                <dd class="description">Older Dutch proceedings, from 1814 until 1995, were scanned, OCR processed, and made available as pdf and xml, by the Koninklijke Bibliotheek (KB, Dutch Royal Library).
                    For the data as created here, the PDF sources were used.
                    A project related to PoliticalMashup was the explicit identification and <a class="internal" href="#sgd">annotation</a> of speakers.</dd>

                <dt>[<code>nl-members</code>] Dutch Political Members</dt>
                <dd>1814-2013, commons/senate/government</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.parlement.com/">http://www.parlement.com/</a></dd>
                <dd class="description">The Parlementair Documentatie Centrum (PDC) has collected and maintains an up-to-date set of dutch politicians.</dd>

                <dt>[<code>nl-party</code>] Dutch Political Parties</dt>
                <dd>?-2013, commons/senate</dd>
                <dd>XML documents</dd>
                <dd><a class="politicalmashup" href="http://data.politicalmashup.nl/sources/nl-party/">http://data.politicalmashup.nl/sources/nl-party/</a></dd>
                <dd><a class="external" href="http://www.rug.nl/dnpp">http://www.rug.nl/dnpp</a></dd>
                <dd class="description">Manually created set of Dutch political parties, in collaboration with the Documentatiecentrum Nederlandse Politieke Partijen (DNPP).
                    Scraping is emulated (to make use of the existing, controlled and logged processing pipeline) from a local copy of the xml files.</dd>

                <dt>[<code>nl-draft</code>] Drafts of the Dutch Commons proceedings</dt>
                <dd>2011-2013, commons</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.tweedekamer.nl/kamerstukken/verslagen/index.jsp">http://www.tweedekamer.nl/kamerstukken/verslagen/index.jsp</a></dd>
                <dd class="description">The drafts are typically available directly after the meetings take place, and as such interesting for current affairs.
                    Officially they are restricted however, and may not be republished.</dd>

                <dt>[<code>uk</code>] UK proceedings</dt>
                <dd>1935-2013, commons</dd>
                <dd>XML documents</dd>
                <dd><a class="external" href="http://ukparse.kforge.net/parldata/scrapedxml/debates/">http://ukparse.kforge.net/parldata/scrapedxml/debates/</a></dd>
                <dd class="description">The UK proceedings have been processed for quite some time before the start of the PoliticalMashup project.
                    They are used for instance on TheyWorkForYou at <a class="external" href="http://www.theyworkforyou.com/">http://www.theyworkforyou.com/</a>.
                    We use the these processed versions, rather than the officially published documents.</dd>

                <dt>[<code>uk-members</code>] UK parliament members.</dt>
                <dd>?-2013, commons/lords/??</dd>
                <dd>XML documents</dd>
                <dd><a class="external" href="http://ukparse.kforge.net/parlparse/">http://ukparse.kforge.net/parlparse/</a></dd>
                <dd class="description">As with the UK hansards, the members of parliament are also collected and annotated in the TheyWorkForYou project.</dd>

                <dt>[<code>be-proc-vln</code>] Vlaams parlement, Flanders proceedings</dt>
                <dd>1995-2013, commons</dd>
                <dd>PDF documents</dd>
                <dd><a class="external" href="http://www.vlaamsparlement.be/vp/parlementairedocumenten/index.html">http://www.vlaamsparlement.be/vp/parlementairedocumenten/index.html</a></dd>
                <dd class="description">The Dutch-language proceedings of the Flanders parliament (i.e. not the Belgian combined parliament).
                    <br/>Draft documents are called "Voorlopige Tekst" and are not processed.</dd>

                <dt>[<code>be-members-vln</code>] Flanders members of parliament</dt>
                <dd>????-2013</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.vlaamsparlement.be/vp/vlaamsevolksvertegenwoordigers/index.html">http://www.vlaamsparlement.be/vp/vlaamsevolksvertegenwoordigers/index.html</a></dd>
                <dd class="description">The members of the Flanders parliament are collected into a static member set available at <a class="politicalmashup" href="http://transformer.politicalmashup.nl/id/be/vln-ids.xml">http://transformer.politicalmashup.nl/id/be/vln-ids.xml</a>.
                    They are not updated automatically however.
                    Identification of new members will therefore fail until the member set is updated manually.</dd>

                <dt>[<code>no</code>] Stortinget, Norwegian proceedings</dt>
                <dd>1998-2013, commons</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.stortinget.no/nn/Saker-og-publikasjoner/Publikasjoner/Referater/?mt=Stortinget">http://www.stortinget.no/nn/Saker-og-publikasjoner/Publikasjoner/Referater/?mt=Stortinget</a></dd>
                <dd class="description">The Norwegian parliamentary proceedings are all available in the same format.
                    The members are presented at <a class="external" href="http://www.stortinget.no/nn/Representanter-og-komiteer/Representantene/Biografier/">http://www.stortinget.no/nn/Representanter-og-komiteer/Representantene/Biografier/</a>.
                    The members were collected with an xslt sheet (because the data source was very clean xml-valid html) <a class="politicalmashup" href="http://transformer.politicalmashup.nl/id/no/scrape_no.xsl">http://transformer.politicalmashup.nl/id/no/scrape_no.xsl</a> into a static set of members, available at <a class="politicalmashup" href="http://transformer.politicalmashup.nl/id/no/no-ids.xml">http://transformer.politicalmashup.nl/id/no/no-ids.xml</a>.
                    New members will not be identified unless the member set is manually updated.
                    <br/>Draft documents are called "midlertidig" and are not processed.</dd>

                <dt>[<code>dk</code>] Folketinget, Danish proceedings</dt>
                <dd>1999-2013, commons</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.ft.dk/Dokumenter/Referater_efter_modedato.aspx">http://www.ft.dk/Dokumenter/Referater_efter_modedato.aspx</a></dd>
                <dd class="description">Current Danish proceedings are available in HTML format. The archive of old proceedings was processed from PDF files.
                    <br/>Members of parliament already have explicit ids in the source data, so they do not have to be identified by us.</dd>

                <dt>[<code>se</code>] Riksdagen, Swedish proceedings</dt>
                <dd>1990-2013, commons</dd>
                <dd>HTML documents</dd>
                <dd><a class="external" href="http://www.riksdagen.se/sv/Dokument-Lagar/Kammaren/Protokoll/">http://www.riksdagen.se/sv/Dokument-Lagar/Kammaren/Protokoll/</a></dd>
                <dd class="description">Swedish proceedings are all available in HTML format. Not all available documents have been processed (the actual format changes several times).
                    <br/>Draft documents are called "snabbprotokoll", and are processed and later updated with permanent documents, called "protokoll".</dd>

                <dt>[<code>es</code>] Spanish proceedings</dt>
                <dd>-</dd>
                <dd>PDF documents</dd>
                <dd class="description nb">Partly implemented but never actively used.</dd>
              </dl>
              
              <h4>Other sources</h4>
              <p>Three notable other sources are, or were, used: dbpedia, wikipedia and the PentaPolica feeds.</p>
              <p>The knowledge base <a class="external" href="http://dbpedia.org/">dbpedia</a> contains many relations between entities.
                 They are used to add relations to the political member and party documents.</p>
              <p>Information from <a class="external" href="http://www.wikipedia.org/">wikipedia</a> was used to extract knowledge about the Dutch governmental periods.</p>
              <p>Additional online resources for politicians, such as twitter accounts, were collected by PentaPolitica on <a class="external" href="http://stolp.lab.dispectu.com/export/feeds">http://stolp.lab.dispectu.com/export/feeds</a>.
                 These feeds were explicitly linked from the member documents, but are currently not added.</p>
              <p class="todo">more external sources?</p>
            </div>
            <div>
              <h3 id="scraping-logs">Process Logging</h3>
              <p>The entire scrape and transformation process is logged.
                 Logs of the scrape process include counting how many new, updated or existing documents were found, and whether they were <a class="internal" href="#transformation">transformed</a> correctly.</p>
              <p>These logs are stored, up to 15 iterations back, by scrapy, and interpreted by a companion script <code>daily-logs.sh</code>.</p> 
              <p>Summarising logs are emailed to <em>politicalmashup [at] gmail [dot] com</em>.
                 This email account is used for all process and server admin logs.
                 All message are labelled, and checking the last twenty or so messages quickly shows if everything is working.
                 Detailed logs of the current state of transformations, e.g. members being identified correctly, must be inspected using the <a class="internal" href="#transformation-monitor">monitor</a>.
                 Login credentials can be found on the twiki page.</p>
            </div>
          </div>
          
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://scrapy.org/">http://scrapy.org/</a></dt>
                <dd>Homepage of the scrapy toolkit.</dd>
                <dt><a class="external" href="http://pdftohtml.sourceforge.net/">http://pdftohtml.sourceforge.net/</a></dt>
                <dd>Homepage of the pdftohtml extraction tool.</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://data.politicalmashup.nl/sources/nl-party/">http://data.politicalmashup.nl/sources/nl-party/</a></dt>
                <dd>Online listing of our manual party source documents.</dd>
                <dt><a class="politicalmashup" href="http://mashup1.science.uva.nl:15432/">http://mashup1.science.uva.nl:15432/</a></dt>
                <dd>Web-interface of the scrapy daemon.</dd>
                <dt><code>politicalmashup [at] gmail [dot] com</code></dt>
                <dd>Email address where are process and system admin logs are sent. Password is available on twiki page below.</dd>
                <dt><a class="external" href="http://stolp.lab.dispectu.com/export/feeds">http://stolp.lab.dispectu.com/export/feeds</a></dt>
                <dd>List of politician feeds (e.g. twitter) from PentaPolitica.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupScrapyD">PoliticalMashupScrapyD</a></dt>
                <dd>Overview of the scrapy daemon usage, including the scraping schedule.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupScrapeProcess">PoliticalMashupScrapeProcess</a></dt>
                <dd class="old">Early description of the scrapy process.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/MashupMachines">MashupMachines</a></dt>
                <dd class="old">Old description of the server hardware used in the project.</dd>
                <dd>Includes a copy of the <code>ilps_bg</code> crontab for the <code>mashup0</code> and <code>mashup1</code> servers, should they accidentally be removed.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupNlDraft">PoliticalMashupNlDraft</a></dt>
                <dd class="old">Old information on the new dutch drafts proceedings.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/EthnicityInParliament">EthnicityInParliament</a></dt>
                <dd class="old">Some old background information (in Dutch) on dutch politicians.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/scrapy-d">politicalmashup/scrapy-d</a></dt>
                <dd>Scrapy crawler implementations.</dd>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/pdf2xml">politicalmashup/pdf2xml</a></dt>
                <dd>Conversion tool to create xml from pdfs.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup1:/scratch/data/parliament/</code></dt>
                <dd>Scraped, proper xml data.</dd>
                <dt><code>mashup1:/scratch/scripts/scrapy-d/</code></dt>
                <dd>Scrapy crawlers and <code>manage.sh script</code>.</dd>
                <dt><code>mashup1:/scratch/scripts/pdf2xml/</code></dt>
                <dd>Pdf to xml conversion tool.</dd>
                <dt><code>mashup0:/scratch/webservices/wwwroot/sources -> /scratch/data/pm-source-data/</code></dt>
                <dd>Physical location of the Dutch parties as used during the scraping process.</dd>
              </dl>
            </section>
          </aside>
        </section>
};
