xquery version "1.0";

module namespace section-transformation="http://politicalmashup.nl/documentation/section/transformation";

declare function section-transformation:content() {
        <section id="transformation" class="topic">
          <h2>Transformation</h2>
          <h6>Transform the scraped, structurally different xml files into a common verifiable xml structure.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#transformation-xslt">XSLT</a></li>
                <li><a class="internal" href="#transformation-identifiers">Document Identifiers</a></li>
                <li><a class="internal" href="#transformation-structure">Document Structure</a></li>
                <li><a class="internal" href="#transformation-monitor">Monitor</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <h3 id="transformation-xslt">XSLT tranformation</h3>
              <p>Input for the transformer, as said above, is always valid xml.
                 Transformation is triggered by uploading a file to the <a class="internal" href="#transformation-monitor">monitor</a>.
                 This file is input to an XSLT transformation, that extracts content from the file and outputs this content in a pre-defined "politicalmashup" structure.
                 The result of a transformation is stored in the permanent <a class="internal" href="#exist-collections">collection</a>, if it was successfully <a class="internal" href="#validation">validated</a>.</p>
              <p>Transformers are created by first importing a set of basic templates.
                 These templates, if used correctly, ensure that the output is xml valid with respect to specifically designed schemata.
                 The importing source-specific template typically defines the methods for extracting the correct data elements.</p>
            </div>
            <div>
              <h3 id="transformation-identifiers">Document identifiers</h3>
              <p>The most important resposibility of a transformer is the construction of a unique identifier for that document.
                 The identifier is typically based on an existing unique id for a document, padded with our information on the specific collection and sub-structural element.
                 The identifiers are used to <a class="internal" href="#linking">link</a> documents to each other, and <a class="internal" href="#access-resolver">resolve</a> them.</p>
              <p>From the documentation of the resolver module:
<pre class="codedocumentation">
Identifiers must follow a specific structure, exemplified below.
The identifier is provided by the controller.xql as the $path parameter,
and is the url-part after the resolver base url, without any
get-parameters or #hash parts.


Path/identifier for the bulk of our data (proceedings mostly):
nl.proc.sgd.d.192619270000382.2.14.4
^^^^^^^^^^^ * =============== ++++++
|           | |               \----> document section(s), dot separated
|           | \--------------------> local id (document basename)
|           \----------------------> {{d,m,p}}
\----------------------------------> collection

{{d,m,p}} stand for {{document, member, party}} respectively
Identifiers are always unique within our entire data set..

The document sections are currently only relevant for 'd' documents,
and point to a specific part (e.g. a paragraph or a topic) of the
document. These sections are automatically numbered and given during
processing. As such, if .2.14.4 exists, .2.14 will also exist as its
parent element.

The local id is a string that can not contain a dot but otherwise
any sequence of alphanumeric characters or dashes. It is unique within
a specific collection.

The collection part must match exactly a collection hierarchy, within
the permanent data+document+path collection. For instance, nl.proc.sgd.d
will be located in the /db/data/permanent/d/nl/proc/sgd collection.
nl.m.01234 (a member) is local-id 01234 in the collection
/db/data/permanent/m/nl.
The identifier-collection + document-type + local-id together form the
unique identifier for a single xml document in the database.
</pre> 
              </p>
            </div>
            <div>
              <h3 id="transformation-structure">Structure of transformed documents</h3>
              <p class="todo">This section only contains short descriptions, and deserves to be more detailed.</p>
              <p>Written here are global descriptions of the resulting structure of transformed documents.
                 Exact definitions of the structure are given with the <a class="internal" href="#validation-relaxng">validation RelaxNG</a> schemas.
                 Elements are always in the <code>pm</code> (politicalmashup) namespace, unless specified otherwise (e.g. <code>dc:rights</code>).
                 Documents can be "validly" expanded by putting new or additional information in a separate namespace, and using the "document"X.rnc extendable schemass that allow foreign nodes.</p>
              <p>Each document always consists of a root, with:<br/>
                 first a docinfo (with information about the status of the transformation and validation);
                 second a meta with meta-data like the date of proceedings, type of document, identifier, rights etc.;
                 third a document-type specific element, e.g. <code>pm:proceedings</code> for proceedings.</p>
              <p>After successful transformation, the monitor adds validation information to the document docinfo and before storing it in the database.
                 N.B. this has been added, but has not been processed retro-actively, so typically only relatively recent data lists all validation results.</p>
              
              <h4 class="todo" id="transformation-structure-proceedings">Proceedings</h4>
              <p class="todo">proceedings consist of one or more topics.
                              a topic consist, either of scenes with speeches, or directly of speeches.
                              speeches link to members and contain paragraphs.
                              for specific, separate content, stage-directions are used</p>
              <p class="todo">also, roles are added (mp, chair or government)</p>
              <p class="todo">N.B. danish member-refs differ from all our toher refs because they do not start with "dk.m.", because of a legacy decision to stay with the ids as they are found in the proceedings.</p>
              
              <h4 class="todo" id="transformation-structure-members">Members</h4>
              <p class="todo">quite self-explanatory, member, birthdate, names.
                 explain in detail: alternative names (is, the original name with overridden/added alternative fields)
                 explain in detail: functions-government are the used government activities; memberships-commons/senate are the used dates to see if someone is part of the house or not
                 (memberships-government are about government-periods, and do not necessarily reflect the actual activity of a person).
                 due to rights, only the basic information can be shown the resolver (see below); the complete information is available in the database and used for e.g. the member identification (todo: link) script</p>
              <p class="todo">uk members are a bit different, and have specific membership-session-ids and are identified as such in the source data.</p>
              
              <h4 id="transformation-structure-parties">Parties</h4>
              <p>Only Dutch parties are available, which are transformed based on manually defined source documents.</p>
              <p>The one interesting thing here is the calculation of the seats distribution, which is calculated based on the number of politicians having a membership for that party on each day, and combining that information to periods with numbers of seats.
                 Because the person seat/membership info is not perfect (actual politicians sometimes temporarily leave or join parties for instance), there are some deviations from the correct number of seats per day.
                 The distribution is however good enough for our purposes, and works better than the earlier approach of scraping wikipedia for seats distributions.</p>
              
              <h4 id="transformation-structure-parldoc">Parliamentary Documents</h4>
              <p>Parliamentary documents are quite different from proceedings.
                 They typically contain an introduction, textual body, and the signers who introduced or back the proposal.</p>
            </div>
            <div>
              <h3 id="transformation-monitor">Monitor</h3>
              <p>The monitor logs all transformation results. These logs are also read by the <a class="internal" href="#scraping-scrapy">scrapy</a> crawler to inspect the transformation status from the last uploaded document.
                 Because eXist can be a bit slow, all uploading is done sequentially.
                 This also makes it much easier to see how transformation went, and this gives JVM some time to do its required garbage collection.</p>
              <p>The monitor inferface can be reached at <a class="politicalmashup" href="http://monitor.politicalmashup.nl/monitor/">http://monitor.politicalmashup.nl/monitor/</a>.
                 Login and password are the same as the administration login credentials found in the installation folder.</p>
              <p class="nb">During heavy load from transformations, the number of open files on the monitor can rise quickly towards the (linux default) maximum allowed +/- 1000.</p>
            </div>
          </div>
          <aside>
            <h3>Links</h3>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://transformer.politicalmashup.nl/">transformer.politicalmashup.nl/</a></dt>
                <dd>Live checkout of the xslt transformation sheets, with an out-of-date README.
                    Required by the eXist <a class="internal" href="#transformation-monitor">monitor</a> to apply transformations to scraped data.</dd>
                <dt><a class="politicalmashup" href="http://monitor.politicalmashup.nl/monitor/">http://monitor.politicalmashup.nl/monitor/</a></dt>
                <dd>Transformation monitor interface.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/ParliamentTransformers">ParliamentTransformers</a></dt>
                <dd class="old">Very out of date page on the transformers.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/AmendMents">AmendMents</a></dt>
                <dd class="old">Old, first version of the amendment processing.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/transformers">politicalmashup/transformers</a></dt>
                <dd>Repository of the xslt transformation sheets.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup0:/scratch/webservices/wwwroot/transformer -&gt; /scratch/data/transformer/</code></dt>
                <dd>Physical location of the live transformer checkout.</dd>
                <dt><code>mashup1:/scratch/scripts/transform/PoliticalMashupParliamentTransformers</code></dt>
                <dd class="old">Early version of the transformation sheets.</dd>
              </dl>
            </section>
          </aside>
        </section>
};