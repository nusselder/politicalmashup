xquery version "1.0";

module namespace section-validation="http://politicalmashup.nl/documentation/section/validation";

declare function section-validation:content() {
        <section id="validation" class="topic">
          <h2>Validation</h2>
          <h6>Each processed document, after transformation and linking, is checked for structural and content validity.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#validation-relaxng">RelaxNG</a></li>
                <li><a class="internal" href="#validation-schematron">Schematron</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p>Directly after transformation is finished, the transformation <a class="internal" href="#transformation-monitor">monitor</a> checks the resulting document.
                 If the validation is accepted, meaning no problems or only warnings, the validation results are added to the <code>docinfo</code> of the document; otherwise the document is rejected and not stored. 
                 Two types of data validation are done: structural and content validation.</p>
            </div>
            <div>
              <h3 id="validation-relaxng">RelaxNg</h3>
              <p>The possibilities and limits of the <a class="internal" href="#transformation-structure">document structures</a> are explicitly defined in a RelaxNG (compact) definition.
                 These definitions are used to validate that each output document is structurally conformant to the same format.</p>
              <p>This means that, after a document has been validated, we know for certain that (x)queries will be correct for that type of data, and will succeed (or if it doesn't succeed, we know why it does not).</p>
              <h4>Jing</h4>
              <p>Validation of RelaxNG is done with the free tool jing.
                 A html, documented version of the schema below can be found at <a class="politicalmashup" href="http://schema.politicalmashup.nl/proceedings.html">http://schema.politicalmashup.nl/proceedings.html</a>.</p>
              <p>Example commandline validation: <code>java -jar /path/jing.jar  -c "http://schema.politicalmashup.nl/proceedings.rnc" /path/proceedings-document.xml</code>.</p>
            </div>
            <div>
              <h3 id="validation-schematron">Schematron</h3>
              <p>Rather than structure, schematron xslt sheets are used to validate the content of the data.</p>
              <p>Content validation is used to evaluate the quality of the content extraction, linking etc.</p>
              <p>Schematron validations are defined in XML as a set of rules, patterns and assertions.
                 Such an XML file is converted to an XSLT validator with a set of transformation tools provided by the Schematron developers.
                 The validator sheet in its turn, "transforms" a data document to a list of evaluations.</p>
              <h4>Saxon</h4>
              <p>Schematron defintions are available as <code>.sch</code> files in the git repository, and converted with the <code>sch-to-xsl.sh</code> (also available in the repository, requires saxon to be present in <code>/home/ilps/parsetools/</code>).
                 The xml definition of the validator below is available at <a class="politicalmashup" href="http://schema.politicalmashup.nl/proceedingsschematron.sch">http://schema.politicalmashup.nl/proceedingsschematron.sch</a>.</p>
              <p>Example commandline validation of a data document: <code>java -jar /path/saxon.jar /path/proceedings-document.xml "http://schema.politicalmashup.nl/proceedingsschematron.xsl"</code>.</p>
            </div>
          </div>
          
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://relaxng.org/">http://relaxng.org/</a></dt>
                <dd>Homepage of the RelaxNG language.</dd>
                <dt><a class="external" href="http://www.schematron.com/">http://www.schematron.com/</a></dt>
                <dd>Homepage of the Schematron language.</dd>
                <dt><a class="external" href="http://www.thaiopensource.com/relaxng/jing.html">http://www.thaiopensource.com/relaxng/jing.html</a></dt>
                <dd>Jing can interpret and process RelaxNG (compact and full) definitions.</dd>
                <dt><a class="external" href="http://saxon.sourceforge.net/">http://saxon.sourceforge.net/</a></dt>
                <dd>The saxon xslt processor. The HE version support xslt2/xquery1 and is free for use.</dd>
              </dl>
            </section>
            <section class="online">
              <h4>online</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://schema.politicalmashup.nl/schemas.html">http://schema.politicalmashup.nl/schemas.html</a></dt>
                <dd>Live checkout of the git schema repository, including an HTML view of the schemas, plus some documentation.
                    Hosts the actual schema files used during <a class="internal" href="#transformation">transformation</a>.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4>examples</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://resolver.politicalmashup.nl/nl.proc.ob.d.h-tk-20122013-73-2.docinfo">nl.proc.ob.d.h-tk-20122013-73-2.docinfo</a></dt>
                <dd>Docinfo with information about the transformation and successful validation.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/DataQuality">DataQuality</a></dt>
                <dd class="old">Remarks on data quality and validation.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/SchematronDataValidation">SchematronDataValidation</a></dt>
                <dd class="old">Some remarks on schematron validation.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/schema">https://github.science.uva.nl/politicalmashup/schema</a></dt>
                <dd>Schemas in git.</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>mashup0:/scratch/webservices/wwwroot/schemas -&gt; /scratch/data/schemas/</code></dt>
                <dd>Physical location of the live schema checkout.</dd>
              </dl>
            </section>
          </aside>
        </section>
};