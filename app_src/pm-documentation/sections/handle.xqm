xquery version "1.0";

module namespace section-handle="http://politicalmashup.nl/documentation/section/handle";

declare function section-handle:content() {
        <section id="handle" class="topic">
          <h2>Handle</h2>
          <h6>All documents can be resolved, and referenced elsewhere, through the handle resolution system.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#handle-system">System</a></li>
                <li><a class="internal" href="#handle-identifiers">Identifiers</a></li>
                <li><a class="internal" href="#handle-update">Update</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <h3 id="handle-system">System</h3>
              <p><q>The Handle System provides efficient, extensible, and secure resolution services for unique and persistent identifiers of digital objects, and is a component of CNRI's Digital Object Architecture.</q> - <a class="external" href="http://handle.net/">http://handle.net/</a>.</p>
              <p>Handle is used for instance by DOI, and provides a uniform, scalable framework for referencing all things digital.
                 The simplest use, and our method currently, is the resolution of a "handle" (an identifier), to an online location (our <a class="internal" href="#access-resolver">resolver</a>).</p>
              <p>Each handle contains a set of information rows, called "Handle Values". These Values consist of four fields: the Index, the Type, a Timestamp, and the Data.
                 The <a class="internal" href="#handle-examples">examples</a> below are the best explanation.
                 Additional information on running a server and adding handles can be found on the <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/HandleIdentifiers">twiki</a>.</p>
              <p class="nb">There is currently no backup server.
                 If the virtual machine breaks down/gets deleted, due to bad maintance or otherwise, the handles are gone.
                 Keep this in mind when handles are added manually.
                 The PoliticalMashup handles are easily added again through the <a class="internal" href="#access-list-handle">list-handle.xq</a> script and the batch processing of the GUI tool.
                 Passwords for the current server are available on paper only in room C3.230.</p>
            </div>
            <div>
              <h3 id="handle-identifiers">Identifiers</h3>
              <p>All documents, as available on <em>2013-06-21</em>, are available through handle as <code>pm:[identifier]</code>.
                 The only exception is the Dutch proceedings drafts, since these officially may not be republished.</p>
            </div>
            <div>
              <h3 id="handle-update">Update</h3>
              <p>Updating the handles should be done manually, mainly because the password should not end up in an automation script.
                 Manual updates require two steps: download handle definitions as batch file; and process the batch file with the GUI tool.
                 This does not require access to the handle server.</p>
              <p>Download the handle software through <a class="external" href="http://handle.net/download.html">http://handle.net/download.html</a>.
                 Then download the server files from the twiki <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/pub/Main/HandleIdentifiers/gui-required-files.tar.gz">gui-required-files.tar.gz</a>.</p>
              <p>Assuming both files were saved to <code>/path/</code>, extract both files there.
                 Then, start the gui tool with <code>/path/hsj-*/bin/hdl-admintool</code>.</p>
                 
              <h4>Download batch file</h4>
              <p>This example downloads and updates the Dutch modern proceedings.</p>
              <p><a class="politicalmashup" href="http://backend.politicalmashup.nl/list-handle.xq?prefix=11145&amp;project=pm&amp;keyfile=/path/to/admpriv.bin&amp;password=copypasswordfrompaper&amp;since=2013-06-10T00:00:00&amp;collection=d%2Fnl%2Fproc%2Fob&amp;view=table">http://backend.politicalmashup.nl/list-handle.xq?prefix=11145&amp;project=pm&amp;keyfile=/path/to/admpriv.bin&amp;password=copypasswordfrompaper&amp;since=2013-06-10T00:00:00&amp;collection=s%2Fnl%2Fproc%2Fob&amp;view=table</a>.</p>
              <p>Now, change the 'keyfile' field to the physical, absolute path where the admpriv.bin file is located <em>on the machine you are running the GUI tool</em>, i.e. <code>/path/gui-required-files/admpriv.bin</code>.
                 Change the 'password' field to the password that is required to use the admpriv.bin (i.e. not the server certificate password).
                 Change the 'view' field to csv.
                 And click search. Copy paste this text into a file, e.g. <code>update_collection.batch</code>. Use the GUI tool to process this batch.</p>
                 
              <h4>Use GUI tool</h4>
              <p>In the open GUI, click right-bottom "Authenticate".
                 Then, enter <code>0.NA/11145</code> (zero.NA, not ooh.NA); select Public/Private Key.
                 Click "Select Key File.." and browse to <code>/path/gui-required-files/admpriv.bin</code>.
                 Click "OK", and enter the handle admin password to decrypt the key.</p>
              <p>Click File, Open Batch File. Select <code>update_collection.batch</code> and press OK.
                 If you want, logging the output to file is possible with Send Output To, but the context window is fine for small batches.
                 Then, press Run Batch(es), and it will start. When handles already exist, they will generate FAILURE message, which is fine.</p>
            </div>
          </div>
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://handle.net/">http://handle.net/</a></dt>
                <dd>Homepage of the Handle System.</dd>
              </dl>
            </section>
            <section class="examples">
              <h4 id="handle-examples">examples</h4>
              <dl>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd?noredirect">11145/pm:nl.p.vvd?noredirect</a></dt>
                <dd>Displays all information about a handle, as it is stored in our locally run handle server.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd">11145/pm:nl.p.vvd</a></dt>
                <dd>Automatically redirect to the actual data, as supplied in the "URL" field of the handle.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd@view=html">11145/pm:nl.p.vvd@view=html</a></dt>
                <dd>Additional arguments can be supplied using templates.
                    A single template is defined that translates @[...] in the handle to ?[...] at the resulting url.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd?urlappend=.html">11145/pm:nl.p.vvd?urlappend=.html</a></dt>
                <dd>Additional arguments to a url can always be supplied with the ?urlappend=.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.proc.ob.d.h-tk-20102011-43-3@view=html&amp;q=waterstand#nl.proc.ob.d.h-tk-20102011-43-3.1.4.1">11145/pm:nl.proc.ob.d.h-tk-20102011-43-3@view=html&amp;q=waterstand#nl.proc.ob.d.h-tk-20102011-43-3.1.4.1</a></dt>
                <dd>A more complex example.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd?index=1&amp;noredirect">11145/pm:nl.p.vvd?index=1&amp;noredirect</a></dt>
                <dd>Request specific value by index.</dd>
                <dt><a class="external" href="http://hdl.handle.net/11145/pm:nl.p.vvd?type=URL&amp;noredirect">11145/pm:nl.p.vvd?type=URL&amp;noredirect</a></dt>
                <dd>Request specific value by type.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/HandleIdentifiers">HandleIdentifiers</a></dt>
                <dd>Description of the handle identifiers and server installation and configuration.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupRunningServices#Handle_ilps_vm02_science_uva_nl">PoliticalMashupRunningServices#Handle_ilps_vm02_science_uva_nl</a></dt>
                <dd>Information on how to start the server.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/pub/Main/HandleIdentifiers/gui-required-files.tar.gz">gui-required-files.tar.gz</a></dt>
                <dd>siteinfo.bin and admpriv.bin files on the twiki (as copied from the virtual machine).</dd>
              </dl>
            </section>
            <section class="hdd">
              <h4>hdd</h4>
              <dl>
                <dt><code>146.50.56.76:/home/ilps_bg/handle/</code></dt>
                <dt><code>ilps-vm02.science.uva.nl:/home/ilps_bg/handle/</code></dt>
                <dd>Location of the official handle installation, on the VM (URL should point to this IP).</dd>
                <dt><code>mashup0:/scratch/anussel/handle/</code></dt>
                <dd>Location of the temporary handle.</dd>
                <dd class="nb">The test server is shut down.</dd>
              </dl>
            </section>
          </aside>
        </section>
};