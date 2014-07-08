xquery version "1.0";

module namespace section-access="http://politicalmashup.nl/documentation/section/access";

declare function section-access:content() {
        <section id="access" class="topic">
          <h2>Data Access</h2>
          <h6>Multiple ways to access and search the data have been implemented.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#access-resolver">Resolver</a></li>
                <li><a class="internal" href="#access-search">Full-text Search</a></li>
                <li><a class="internal" href="#access-backend">Backend Utilities</a></li>
                <li><a class="internal" href="#access-oai">OAI</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <h3 id="access-resolver">Resolver</h3>
              <p>All data is stored internally as XML documents.
                 Each document is available on the PoliticalMashup <a class="politicalmashup">resolver</a>.
                 The resolver should be supplied the <a class="internal" href="#transformation-identifiers">identifier</a> of a document or sub-element, and returns the relevant XML.</p>
              <p>Parts of documents (sub-elements) can also be requested with the document idententier, and the specific part supplied separately, as <code>[identifier]?part=[part]</code>.</p>
              <p>Apart from the raw xml, we also provide an HTML and RDF view of the data.
                 This is acquired by adding <code>?view=html/rdf</code> to the url.
                 For simplified data harvesting, content-types can also be specified as <code>[identifier].xml/.html/.rdf</code> or, for the rdf view only, through header content negotiation.</p>
              <p>The documents on the resolver can also be reached by means of <a class="internal" href="#handle">handles</a>.</p>
              <p>Apart from content elements, the document information and meta data can also be requested separately by adding <code>.docinfo</code> and <code>.meta</code> respectively to a document identifier (i.e. no element identifiers or other views are supported).</p>
              <p>Finally, Lucene query words can be highlighted by adding <code>?q=[query]</code> to the url.
                 This can be quite slow however, due to implementation restrictions.</p>
              <p class="nb">Due to rights restrictions, the public data presentation of members excludes any membership, curriculum and education information.
                 This data is available for internal processing, and used for instance during the identification of members in proceedings.</p>
            </div>
            <div>
              <h3 id="access-search">Full-text search engine for Dutch proceedings.</h3>
              <p>Full-text search, see  <a class="politicalmashup" href="http://search.politicalmashup.nl/">search.politicalmashup.nl</a>, is implemented with the Lucene backend available in eXist.
                 This interface is built specifically for the Dutch proceedings, with restrictions specific to Dutch parliament/government members and political parties.
                 Searching other collections is available through the <a class="politicalmashup" href="http://backend.politicalmashup.nl/demo-search.xq">demo-search.xq</a> utility script.</p>
              <p>The basic idea behind Lucene in combination with eXist, is that each xml-element (when defined in a configuration file) is treated as a single "document" and presented to Lucene.
                 Lucene document retrievel thus reduces to xml-element retrieval.</p>
              <p>The search is complemented with filters that restrict searches to: speakers, roles (mp, government or chair), political party, house (commons or senate), date of the meeting.
                 Because of the added structure, we allow for <em>entry-point retrieval</em>.</p>
              <p>One of the advantages of the structured documents as made available in the PoliticalMashup project, is the ability to retrieve and thus search on specific levels.
                 The search engine can search in topic titles, entire topics, speaker scenes, and specific speeches.
                 The demo-search searches in speeches or single paragraphs.</p>
              <p>For each result, the context is always completely specified and retrieved.
                 Additional explanation is given (in Dutch) on <a class="politicalmashup" href="http://search.politicalmashup.nl/help.xq">http://search.politicalmashup.nl/help.xq</a></p>
            </div>
            <div>
              <h3 id="access-backend">Backend Utilities Scripts</h3>
              <dl>
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/analyse-members.xq">analyse-members.xq</a></dt>
                <dd>Allow analysis of members and their interactions, per legislative period: list all active members, list all text paragraphs from a member, list all scenes for inspection, and list all <em>interruptions</em>.</dd>

                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/announce-available.xq">announce-available.xq</a></dt>
                <dd>Script where the transformation <a class="internal" href="#transformation-monitor">monitor</a> can announce an newly transformed document.
                    Relevant only for the main, active frontend eXist.</dd>
                <dd class="nb">Required for the live presentation and propagation of new, up to date data.</dd>

                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/check-party-seats.xq">check-party-seats.xq</a></dt>
                <dd>Old script used to analyse the seats distribution, to check if it is corectly extracted from the member data.
                    Currently not very useful, but could be updated.</dd>

                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/complete.xq">complete.xq</a></dt>
                <dd>Analyses if the data is <em>complete</em>, by determining the sessions and items that should at least be availble, and checking for them.
                    Note that this can be a computation-intensive script to run.</dd>

                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/demo-search.xq">demo-search.xq</a></dt>
                <dd>Search interface for the proceedings data.
                    Has fewer options than <a class="politicalmashup" href="http://search.politicalmashup.nl/">search.politicalmashup.nl</a> but is generally faster, and allows searching in all different language proceedings.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/export.xq">export.xq</a></dt>
                <dd>Facilitates listing all available data, with multiple input source and output format options.
                    Useful for listings fed to <code>curl</code> etc.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/get-votes.xq">get-votes.xq</a></dt>
                <dd>Old, flaky, but important script that searches for votes in the proceedings based on a dossier- and sub-number.
                    Throws an error when called without arguments, as an example see <a class="politicalmashup" href="http://backend.politicalmashup.nl/get-votes.xq?dossiernummer=32469&amp;ondernummer=18">kst-32469-18</a>.</dd>
                <dd class="nb">Required for the transformation of <a class="internal" href="#transformation-structure-parldoc">parliamentary documents</a>.</dd>

                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/id-members.xq?view=table">id-members.xq</a></dt>
                <dd>Identify political members based on their name and additional context. Explicitit member documents are available for Dutch an UK politicians.
                    Possibly the most important script.</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-proceedings">proceedings</a>.</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-parldoc">parliamentary documents</a>.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/id-parldoc.xq?view=table">id-parldoc.xq</a></dt>
                <dd>Identify parliamentary documents based on a dossier number and dossier subnumber. Script is able to correctly detect reprints.</dd>
                <dd class="nb">Required for the identification of parliamentary documents in votes, during the transformation of <a class="internal" href="#transformation-structure-proceedings">proceedings</a>.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/id-parties.xq?view=table">id-parties.xq</a></dt>
                <dd>Identify parties based on a string and a date.</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-proceedings">proceedings</a>.</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-members">members</a>.</dd>
                <dd class="todo">Add input type checking.</dd>
                
                <dt id="access-list-handle"><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-handle.xq?view=table">list-handle.xq</a></dt>
                <dd>List a data collection as a <a class="internal" href="handle">Handle</a> batch-script.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-members.xq?col=nl">list-members.xq</a></dt>
                <dd>List all members given filters (date, house, member-id etc.). More or less id-members.xq without a query.
                    Used in the past to supply people with a lists of politicians in xml.</dd>
                <dd class="nb">Used (and required) during the update-fix for the SGD proceedings to add party-links where they are not mentioned in the (older) data.
                    Not actively used.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-parldoc.xq">list-parldoc.xq</a></dt>
                <dd>List all available parliamentary documents (currently only amendments) and their number of votes.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-parties.xq">list-parties.xq</a></dt>
                <dd>List all parties, given some filters.</dd>
                <dd class="nb">Required for the listing of active parties, during the transformation of <a class="internal" href="#transformation-structure-proceedings">proceedings</a>.</dd>
                <dd class="nb">Required to infer votes from non-listed parties (e.g. "the rest voted against", who is this rest).</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-party-seats.xq">list-party-seats.xq</a></dt>
                <dd>List the seats of a party given some date and house. The seats are calculated dynamically during transformation, based on the people being a member for that party of that house.</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-parties">parties</a>.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-updates.xq">list-updates.xq</a></dt>
                <dd>List all documents added or updated since a given <code>xs:dateTime</code>.</dd>
                <dd class="nb">Secondary eXist databases (e.g. search.politicalmashup.nl) use update-available.xq to get the latest updates, requiring list-updates.xq on the main live backend.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-votes.xq">list-votes.xq</a></dt>
                <dd>List all <em>votes</em> per legislative period. Useful for the analyses requested by newspapers etc.</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/run-backup.xq">run-backup.xq</a></dt>
                <dd>Immediately triggers the backup script.</dd>
                <dd class="todo">This is to immediate. Make sure it requests a password or something similar (see monitor code).</dd>
                
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/stats.xq">stats.xq</a></dt>
                <dd>Calculate <em>statistics</em> on the size of the data and <em>percentage of members identified</em>.</dd>
                
                <dt id="access-backend-update-available"><a class="politicalmashup" href="http://backend.politicalmashup.nl/update-available.xq">update-available.xq</a></dt>
                <dd>Update a secondary <a class="internal" href="#exist-update">eXist</a> database with newly available documents.
                    This script is not useful/relevant on the main resolver eXist, since this is the reference database.
                    Used most importantly by the search.politicalmashup.nl database.</dd>
                <dd class="nb">Requires a running main eXist server with backend.politicalmashup.nl/list-updates.xq.</dd>
              </dl>
              
              <p class="todo">Some script could/should be updated to fully utilise the export.xqm module and create a useable webinterface:
                 get-votes.xq, list-members.xq, list-parldoc.xq, list-parties.xq, list-party-seats.xq</p>
              
              <h4 id="access-backend-other">Other scripts</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://search.politicalmashup.nl/autocomplete/query.xq?term=cohen">autocomplete/query.xq</a></dt>
                <dd>Script returning a set of possible members matching a term in JSON format.
                    Used for autocomplete options in the main search interface.</dd>
                    
                <dt><a class="politicalmashup" href="http://monitor.politicalmashup.nl/proc/nl-prev-doc.xq">monitor.politicalmashup.nl/proc/nl-prev-doc.xq</a></dt>
                <dd>Find the previous document of dutch proceedings document, to copy over the current chair information (this is not repeated in the source of consecutive items).</dd>
                <dd class="nb">Required during the transformation of <a class="internal" href="#transformation-structure-proceedings">proceedings</a>.</dd>
                    
                <dt><a class="politicalmashup" href="http://monitor.politicalmashup.nl/proc/logs.xq">monitor.politicalmashup.nl/proc/logs.xq</a></dt>
                <dd>Read the transformation logs to see if a document was actually (and properly) processed.</dd>
                <dd class="nb">Required after the <a class="internal" href="#transformation">transformation</a> of documents by <a class="internal" href="#scraping">scrapy</a> to check if transformation was successful.</dd>
              </dl>
            </div>
            
            <div>
              <h3 id="access-oai">OAI</h3>
              <p>XML data is also available for harvesting through the <a class="politicalmashup" href="http://oai.politicalmashup.nl/">OAI-PMH</a> protocol.
                 With this protocol, meta-data is listed according to specification, with links to the actual data on the resolver.
                 OAI uses a set of <code>verb</code> commands <a class="politicalmashup" href="http://oai.politicalmashup.nl/doc/index.html">documented separately</a>.
                 For example, retrieve the data for Dutch political parties as <a class="politicalmashup" href="http://oai.politicalmashup.nl/?verb=ListRecords&amp;set=p:nl">http://oai.politicalmashup.nl/?verb=ListRecords&amp;set=p:nl</a></p>
            </div>
          </div>
          
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://www.openarchives.org/">OAI</a></dt>
                <dd>Homepage of the Open Archives Initiative (OAI).</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/">http://resolver.politicalmashup.nl/</a></dt>
                <dd>Base location for document resolving through identifiers.</dd>
                <dt><a class="politicalmashup" href="http://search.politicalmashup.nl/">http://search.politicalmashup.nl/</a></dt>
                <dd>Search interface for the Dutch proceedings.</dd>
                <dt><a class="politicalmashup" href="http://oai.politicalmashup.nl/">http://oai.politicalmashup.nl/</a></dt>
                <dd>OAI harvesting.</dd>
                <dt><a class="politicalmashup" href="http://oai.politicalmashup.nl/doc/index.html">http://oai.politicalmashup.nl/doc/index.html</a></dt>
                <dd>OAI end-point documentation.</dd>
                <dt><a class="politicalmashup" href="http://backend.politicalmashup.nl/">http://backend.politicalmashup.nl/</a></dt>
                <dd>Base location of the backend utilities.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11">nl.proc.ob.d.h-tk-20102011-92-11</a></dt>
                <dd>Resolving a document.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11?view=html">nl.proc.ob.d.h-tk-20102011-92-11?view=html</a></dt>
                <dd>View as html.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11.xml">nl.proc.ob.d.h-tk-20102011-92-11.xml</a></dt>
                <dd>Download as XML document.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11.1.15">nl.proc.ob.d.h-tk-20102011-92-11.1.15</a></dt>
                <dd>Specify specific part as identifier.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11?part=1.15">nl.proc.ob.d.h-tk-20102011-92-11?part=1.15</a></dt>
                <dd>Specify specific part through GET.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11?view=html#nl.proc.ob.d.h-tk-20102011-92-11.1.15">nl.proc.ob.d.h-tk-20102011-92-11?view=html#nl.proc.ob.d.h-tk-20102011-92-11.1.15</a></dt>
                <dd>Highlight specific part in context.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11?part=1.22.1&amp;view=html&amp;q=aanwezige">nl.proc.ob.d.h-tk-20102011-92-11?part=1.22.1&amp;view=html&amp;q=aanwezige</a></dt>
                <dd>Highlight query in html view of one part.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11.meta">nl.proc.ob.d.h-tk-20102011-92-11.meta</a></dt>
                <dd>Request metadata.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11.docinfo">nl.proc.ob.d.h-tk-20102011-92-11.docinfo</a></dt>
                <dd>Request document information.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupPermanentIdentifiers">PoliticalMashupPermanentIdentifiers</a></dt>
                <dd>Some information on the resolver in relation to the document identifiers.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/ExploratorySearch">ExploratorySearch</a></dt>
                <dd class="old">Partly relevant backgound motivation for search in structured data.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/parliament-frontend">politicalmashup/parliament-frontend</a></dt>
                <dd>Frontend code that contains the resolver, search interface, backend utilities and oai.</dd>
                <dd class="nb">Use the <code>production</code> branch.</dd>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/parliament-backend">politicalmashup/parliament-backend</a></dt>
                <dd>Transformation code that contains the previous-proceedings selector.</dd>
                <dd class="nb">Use the <code>production</code> branch.</dd>
              </dl>
            </section>
          </aside>
        </section>
};