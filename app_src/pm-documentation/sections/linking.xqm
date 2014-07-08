xquery version "1.0";

module namespace section-linking="http://politicalmashup.nl/documentation/section/linking";

declare function section-linking:content() {
        <section id="linking" class="topic">
          <h2>Linking</h2>
          <h6>Add references to other documents to create a rich network of political document relations.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#linking-relations">Relations</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p>One goal of the project, and argument for construction of XML documents, is the idea of <em>linked data</em>.
                 Where possible, relations between the documents and to outside sources are added explicitly to enable context-sensitve research queries on the data.</p>
              <p>Linking is done mostly during the <a class="iinternal" href="#transformation">transformation</a> phase that, apart from structure, adds: the lookup of documents, identification of members, querying dbpedia etc.
                 One exception is the querying of wikipedia-links, which is done during scraping for members, and was defined manually for the parties.</p>
            </div>
            <div>
              <h3 id="linking-relations">Relations</h3>
              <p>The relations between documents and to outside sources are listed below.</p>
              
              <dl>
                <dt>proceedings -&gt; members</dt>
                <dd>Members speaking and present are explicitly linked to member documents.</dd>
                
                <dt>proceedings -&gt; parties</dt>
                <dd>Parties of speaking members are linked to party documents.</dd>
                
                <dt>proceedings -&gt; parliamentary documents</dt>
                <dd>Votes on amendments link to the specific amendment document.</dd>
                
                <dt>parliamentary documents -&gt; parliamentary documents</dt>
                <dd>Amendments are sometimes (often) updated with newer versions, typically because of new content or new people backing the amendment.
                    Links to the replaced documents are made explicit.</dd>
                <dd class="nb">Links are added to new documents, and were retroactively added to about half of the available documents; not all replacements are explicit yet.</dd>
                
                <dt>parliamentary documents -&gt; proceedings</dt>
                <dd>Once an amendment has been voted upon, a link to the actual vote within the proceedings is added.</dd>
                <dd class="nb">Adding a link to a vote almost always occurs later than during the first processing of the parliamentary document (since votes typically become available later).
                    After the switch to the new eXist setup, this detection had to be rewritten and is not enabled.
                    A concept solution is available as a <code>redo.xq</code> "source" that can be "scraped", as is required for the full validation and logging process.</dd>
                
                <dt>parliamentary documents -&gt; members</dt>
                <dd>Amendments are introduced or backed by politicians and linked.
                    Parties of the backing politicians are not added.</dd>
                
                <dt>parliamentary documents -&gt; parties</dt>
                <dd>If a amendment links to a vote, the vote is copied into the meta-data, and thereby contains the parties and how they voted.</dd>
                
                <dt>members -&gt; parties</dt>
                <dd>Members (of the upper or lower house) are always seated for a specific party (as opposed to government members who are typically affiliated to a party but act "neutral").
                    Each seat-period is linked to a party.</dd>
                    
                <dt>parties -&gt; members</dt>
                <dd>Parties are implicitly linked to members as the number of seats representing them.
                    These seats are counted based on the members, but not explicitly linked to members.</dd>
                    
                <dt>parties -&gt; parties</dt>
                <dd>Parties tend to split up or combine into new parties.
                    Ancestor and descendant relations, when applicable, are made explicit.</dd>
                
                <dt>members -&gt; external</dt>
                <dd>Members are linked with the source <a href="http://www.parlement.com/">parlement.com</a>, <a href="http://www.wikipedia.org/">Wikipedia</a>, <a href="http://dbpedia.org/">dbpedia</a> and, when available through dbpedia, with <a href="http://www.freebase.com/">freebase</a>.</dd>
                <dd class="nb">During writing, an identification process is running that detects politicians in newspaper archives. When done, members are also linked with specific newspaper articles available at the KB.</dd>
                
                <dt>parties -&gt; external</dt>
                <dd>Parties are linked with <a href="http://www.wikipedia.org/">Wikipedia</a>, <a href="http://www.parlement.com/">parlement.com</a>, <a href="http://dbpedia.org/">dbpedia</a> and, when available through dbpedia, with <a href="http://www.freebase.com/">freebase</a>.</dd>
                
                <dt>proceedings -&gt; external</dt>
                <dd>Proceedings are linked with their source documents, when they can be uniquely determined during transformation.
                    The Ducth source data also has eplicit document references, which are displayed as actual data links in the HTML view.</dd>
              </dl>
            </div>
          </div>
          <aside>
            <h3>Links</h3>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.parldoc.d.kst-32469-18?view=html">nl.parldoc.d.kst-32469-18?view=html</a></dt>
                <dd>Parliamentary document with: a link to the parliamentary document it replaces; links to the politicians that introduced the amendment; links to several sources; a link to the vote in the proceedings; and links to the parties that voted.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.m.03183?view=html">nl.m.03183?view=html</a></dt>
                <dd>Member document with external links and a link to the last party someone was seated for.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.p.vvd?view=html">nl.p.vvd?view=html</a></dt>
                <dd>Party document with external links and a reference to an ancestor.</dd>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20102011-92-11?view=html">nl.proc.ob.d.h-tk-20102011-92-11?view=html</a></dt>
                <dd>Proceedings document with: links to members, parties, parliamentary documents, and inline source references.</dd>
              </dl>
            </section>
          </aside>
        </section>
};