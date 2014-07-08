xquery version "1.0";

module namespace section-sgd="http://politicalmashup.nl/documentation/section/sgd";

declare function section-sgd:content() {
        <section id="sgd" class="topic">
          <h2>SGD Annotation</h2>
          <h6>Find, identify and visualise speakers in OCR data.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#sgd-project">KB Project</a></li>
                <li><a class="internal" href="#sgd-transformation">Transformation</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p>The processing of the old (pre 1995) Dutch proceedings required more specific steps and a higher quality, in part because of the external Koninklijke Bibliotheek project.</p>
              <p class="todo">Shouldn't there be more information about this project on the twiki?</p>
            </div>
            <div>
              <h3 id="sgd-project">KB project</h3>
              <p>The KB ran a project wherein all historical proceedings from 1814-1995, published only on paper, were digitised and automatically parsed with OCR.</p>
              <p>Part of the project, detecting speakers, was performed by us in a project related to PoliticalMashup.
                 Apart from detecting speakers in the text, the exact word-coordinates on the scanned images, and unique identification of those speakers we requested.
                 Some of the techniques and insights from this project were reused within PoliticalMashup.</p>
            </div>
            <div>
              <h3 id="sgd-transformation">Transformation</h3>
              <p>The transformation of the SGD data occurred in three stages.
                 The first stage consisted of transforming the PDF documents to relatively structured data.
                 The second stage was determining and adding the unique member ids to the data.
                 The third stage was a more recent clean-up script that is performed through the uploading process as described in the <a class="internal" href="#transformation">transformation</a> section.</p>
              <p>Redoing the entire process, specifically the first stage, will most likely be difficult due to (changed) dependencies, data locations etc.
                 The results however are still available.</p>
            </div>
          </div>
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://statengeneraaldigitaal.nl/">http://statengeneraaldigitaal.nl/</a></dt>
                <dd>Homepage of the Stagen Generaal Digitaal (SGD), the "digital archive of the combined commons and senate proceedings".</dd>
                <dt><a class="external" href="http://www.kb.nl/">http://www.kb.nl/</a></dt>
                <dd>Homepage of the Koninklijke Bibliotheek (KB), the "Dutch loyal library"</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://data.politicalmashup.nl/kb/overzicht.php">http://data.politicalmashup.nl/kb/overzicht.php</a></dt>
                <dd>Overview of some processed documents </dd>
                <dt><a class="politicalmashup" href="http://data.politicalmashup.nl/kb/oplevering/readme.html">http://data.politicalmashup.nl/kb/oplevering/readme.html</a></dt>
                <dd>Deliverable document (in Dutch) for the KB SGD project.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://data.politicalmashup.nl/kb/kb_permanent_presentation/nl.196919700000698-proc/nl.196919700000698-proc.annotated.xml">nl.196919700000698-proc.annotated.xml</a></dt>
                <dd>Document as processed for speaker (and other) detection.
                    Hover the mouse over the (purple) names to see identification information.</dd>
                <dt><a class="external" href="http://statengeneraaldigitaal.nl/document?id=sgd%3A19831984%3A0000980&amp;zoekopdracht[kamer][0]=Eerste+Kamer&amp;zoekopdracht[kamer][1]=Tweede+Kamer&amp;zoekopdracht[kamer][2]=Verenigde+Vergadering&amp;zoekopdracht[kamer][3]=UCV%2FOCV&amp;zoekopdracht[zoekwoorden]=economie&amp;zoekopdracht[vergaderjaar][van]=1814+-+1815&amp;zoekopdracht[vergaderjaar][tot]=1994+-+1995&amp;zoekopdracht[documentType]=Kamerverslagen&amp;zoekopdracht[kamerverslagen][datum][van][0]=&amp;zoekopdracht[kamerverslagen][datum][van][1]=&amp;zoekopdracht[kamerverslagen][datum][van][2]=&amp;zoekopdracht[kamerverslagen][datum][tot][0]=&amp;zoekopdracht[kamerverslagen][datum][tot][1]=&amp;zoekopdracht[kamerverslagen][datum][tot][2]=&amp;zoekopdracht[kamerverslagen][paginas][van]=&amp;zoekopdracht[kamerverslagen][paginas][tot]=&amp;zoekopdracht[kamerverslagen][besprokenKamerstukken]=&amp;zoekopdracht[kamerverslagen][sprekers][0]=Lubbers%2C+R.F.M.&amp;zoekopdracht[pagina]=1&amp;zoekopdracht[sortering]=relevantie">statengeneraaldigitaal.nl</a></dt>
                <dd>Document on the SGD with speakers highlighted.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PDCNameResolver">PDCNameResolver</a></dt>
                <dd>Description of the <code>mpid</code> name resolution script.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PmSgdAnnotator">PmSgdAnnotator</a></dt>
                <dd>Verbatim copy of the README in the git repository mentioned below (politicalmashup/mpid).</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/mpid">politicalmashup/mpid</a></dt>
                <dd>Contains member identification script with Levenshtein correction for OCR names, and scripts to process the data.
                    Precursor of the <code>id-members.xq</code> utility.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup1:/scratch/data/parliament/nl-sgd/</code></dt>
                <dd>Contains different stages, including the final versions, of the SGD data.</dd>
                <dt><code>mashup1:/scratch/scripts/transform/nl/mpid/</code><br/>
                    <code>mashup1:/scratch/anussel/pre-exist-parliament-code</code></dt>
                <dd class="old">Used working version for adding the member-ids.</dd>
                <dt><code>mashup0:/scratch/webservices/wwwroot/kb</code></dt>
                <dd>Hosts deliverable and example files found on http://data.politicalmashup.nl/kb/*.</dd>
                <dt><code></code></dt>
                <dd></dd>
                <dt><code></code></dt>
                <dd></dd>
              </dl>
            </section>
          </aside>
        </section>
};