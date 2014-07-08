xquery version "1.0";

module namespace section-exist="http://politicalmashup.nl/documentation/section/exist";

declare function section-exist:content() {
        <section id="exist" class="topic">
          <h2>eXist</h2>
          <h6>The data is stored and accessible through the eXist database server.
              Installation, code development, and database content structure.</h6>
          <aside>
            <h3>Contents</h3>
            <nav>
              <ul>
                <li><a class="internal" href="#exist-install">Installation</a></li>
                <li><a class="internal" href="#exist-coding">Coding and Development</a></li>
                <li><a class="internal" href="#exist-modules">Modules</a></li>
                <li><a class="internal" href="#exist-collections">Data Collections</a></li>
                <li><a class="internal" href="#exist-bugs">Bugs</a></li>
                <li><a class="internal" href="#exist-2">eXist 2.0</a></li>
              </ul>
            </nav>
          </aside>
          <div class="section-content">
            <div>
              <p>eXist is a native XML database.
                 It is used to store all data and xquery scripts, and apply data transformations and validations.</p>
              <p class="nb">We use version 1.4.3, notes on <a class="internal" href="#exist-2">exist 2</a> are given at the end.</p>
              <p>The current setup favours multiple differentiated databases, over one database that does everything.
                 A list of all <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupExistDatabases">running database instances</a>, and their use, is available on the twiki.
                 One important exception is an old database, that is still running and showcases old demo's.
                 More information is listed below on <a class="internal" href="#related-xml.politicalmashup.nl">xml.politicalmashup.nl</a>.</p>
            </div>
            <div>
              <h3 id="exist-install">Install eXist database/copy</h3>
              <p>Installation of a personal development (or new live) database is assisted with a deployment script.
                 This script automates many of the steps that necessary, such as setting listening ports during installation, and adding data or updating code to an installed database.</p>
              <p>The guide below walks through the actual installation process, and next gives an example of adding data.
                 In the guide, the <code>SSH</code> links are used, which allow for actual development but require a working <a class="politicalmashup" href="https://github.science.uva.nl/">github.science.uva.nl</a> account.
                 The subsection below this uses this deployment script to streamline actual <a class="internal" href="#exist-coding">code development</a>.</p>
              <p class="nb">The installation was created for the mashup server machines.
                 It requires the availability of <code>wdfs</code> to mount webdav and copy code.
                 This is an unfortunate legacy requirement.</p>
              <p><code>
<pre>
# Get and setup the deployment script.
git clone git@github.science.uva.nl:politicalmashup/parliament-deploy.git
# [[ Enter git pw.
# Rename the deployment to some relevant
# name if wanted.
mv parliament-deploy/ some_name
cd some_name/
# Configure the installation
./configure
# Typically, for frontend development,
# all default settings are fine, but pay
# attention to max. memory, and the local
# port used.
# JAVA max_mem (2000):
# EXIST port (8080):

# Now, start the installation.
make install
# [[ Enter new admin pw.
# [[ Enter new default usernamed.
# [[ Enter new default user pw.
# [[ Enter git pw.

# Done!
</pre>
                 </code></p>
            
              <h4>Download and add data</h4>
              <p>After installation, data can be copied from the main database to the local folder, and then added to the local database.
                 To aid collection downloading, a <a class="external" href="http://www.debian-administration.org/articles/316">bash_completion</a> script can be loaded, to <code>TAB</code> through the possible options.
                 Below an example of downloading the (transformed and validated) Dutch parties.</p>
              <p><code>
<pre>
# Load bash_completion
source bash_completion.sh
# Load available collections
make update_available_collections
# Initialise the collection.
make collection_init collection=permanent/p/nl
# Retrieve the parties.
make get_local_copy collection=permanent/p/nl
# Put/copy the files to the local database
make put_local_copy collection=permanent/p/nl
# Clean up downloaded files
rm -rf tmp-data/
</pre>
                 </code></p>
              
              <h4>Data update from main frontend</h4>
              <p>After a database has been installed, and initial data added, new/updated data can be retrieved from the main servers with a basic <a class="internal" href="#access-backend-update-available">update</a> script.
                 This will update any collections <span class="nb">that have been initialised</span> during the data-copying step above.</p>
              <p>On the installed database, run: <code>http://[host]:[port]/backend/update-available.xq?since=2013-[MM]-[DD]T00:00:00</code>.</p>
              <p>The update process can take some time if files (e.g. nl-members) need updating.
                 Adding files is relatively fast.</p>
            </div>
            <div>
              <h3 id="exist-coding">Code development</h3>
              <p>The process of developing code and applications is by programming in a separate development eXist.
                 If the result is satisfactory, commit and push the changes to git, and then pull and copy on the live eXist machines.</p>
              <p>One exception is the <code>/db/www/private/</code> collection.
                 Any code therein is ingored by the git repository.
                 So long as the database is not overloaded, it is possible to experiment with all data/code etc.
                 To reach the code, browse to the root of the database, i.e. not to resolver.politicalmashup.nl, but to <code>mashup[*].science.uva.nl:[port]/private/filename.ext</code>.</p>
              <p>Another possibility is to write a query, and run it (using oXygen) against a database as datasource.</p>
              
              <h4>oxygen</h4>
              <p>For all development concerning xquery, xml or xslt, the editor <a class="external" href="http://www.oxygenxml.com/">oXygen</a> is extremely useful.
                 Apart from code highlighting and interpretation, it allows eXist databases to be added as datasource.
                 See the twiki <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/EXistDB#eXist_with_oXygen">EXistDB#eXist_with_oXygen</a> for more information on loading eXist data, and licenses.</p>
                 
              <h4>git push</h4>
              <p>Often, and for example this documentation, code is written through oXygen.
                 This code is than copied into the local git version, located in the same folder as the eXist instance.</p>
              <p>To update git, copy the changes out of the eXist and commit+push to git.
                 Note that pushing to git is only possible if you know the git user password as given during the installation of the eXist database.
                 This is also the reason read-only live databases from <code>ilps_bg</code> can not push.</p>
              <p><code>
<pre>
make update_git
# Enter admin pw
cd installation/parliament-*
# * == {{backend,frontend}}-clone
git status
git commit [files you want to commit]
git push
# Enter git pw
</pre>
                 </code></p>
              
              <h4>git pull</h4>
              <p>Development on live databases, e.g. the <a class="internal" href="#access-resolver">resolver</a>, should not be done.
                 Rather, after pushing development changes to git, pull them into the live dabases afterwards.
                 One reason for this is that main databases are run by the group user <code>ilps_bg</code>, who can not push changes into the git repository.</p>
              <p>To update a database to the latest version available in git, go to the main deployment folder (as given on the twiki) and run (this requires the database password in <code>local-pw</code>) the pull+update code.</p>
              <p><code>
<pre>
make pull
make update_exist
# Enter admin pw
</pre>
                 </code></p>
              
              <h4>eXist uptime</h4>
              <p>A downside of eXist, at least for version 1.4.*, is that it is not always very stable.
                 Reliable checking if a system is running is not really possible.
                 A system might simply be temporary non-responsive, hung completely, or not running at all.
                 Checking for running processes is therefore not sufficient.
                 Also, when a database crashes, it might have remaining logs and locks that prevent it from starting up properly.
                 The best way is to manually check and restart a database if there is a question about its functioning.
                 See the <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupRunningServices">running services</a> overview for guidance to (re)starting specific databases.</p>
               <p class="nb">In case of emergency requirement of a working eXist, a shadow copy of the live resolver is running (and updated daily) on <code>mashup0</code>.
               See the twiki <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupExistDatabases">database list</a> for its exact location (current backup is <em>R</em>, and edit the <a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupRunningServices#Apache_80_MMApacheServer">apache configuration on mashup0</a> to point any required subdomain url's to the backup database.</p>
            </div>
            <div>
              <h3 id="exist-modules">Modules</h3>
              <p>Collections in the database serve specific purposes, as listed below.</p>
              <dl>
                <dt><code>backend</code></dt>
                <dd>Code for the <a class="internal" href="#access-backend">backend utitlities</a>.</dd>
                <dt><code>backup</code></dt>
                <dd>Code to run backups, largely old and unused since automated backups are run by the systems.</dd>
                <dt><code>data</code></dt>
                <dd>Contains all data, permanent data for <a class="internal" href="#access">frontends</a>, and additionally upload data for the <a class="internal" href="#transformation-monitor">monitor</a>.</dd>
                <dt><code>local</code></dt>
                <dd>Some configuration created at installation time.</dd>
                <dt><code>logs</code></dt>
                <dd>Relevant for the <a class="internal" href="#transformation-monitor">monitor</a> only, contains logs of the transformations.</dd>
                <dt><code>modules</code></dt>
                <dd>Contains code used by many scripts, notably the <code>export.xqm</code> and <code>functx</code> definitions.</dd>
                <dt><code>oai</code></dt>
                <dd>Code for <a class="internal" href="#access-oai">OAI</a>.</dd>
                <dt><code>resolver</code></dt>
                <dd>Code for the <a class="internal" href="#access-resolver">resolver</a>.</dd>
                <dt><code>system</code></dt>
                <dd>Contains, nested within, the data- and lucene-index configuration files.</dd>
                <dt><code>www</code></dt>
                <dd>Collection accessible from outside.</dd>
                <dt><code>www/documentation</code></dt>
                <dd>Contains this documentation.</dd>
                <dt><code>www/pop</code></dt>
                <dd>Old search script for Populisme project. Kept for code reference.</dd>
                <dt><code>www/proc</code></dt>
                <dd>Only exists in the <a class="internal" href="#transformation-monitor">monitor</a>.
                    Contains logs and previous document scripts, see <a class="internal" href="#access-backend-other">other backend utilities</a>.</dd>
                <dt><code>www/private</code></dt>
                <dd>Collection created for development, will not be ignored when updating git through the <code>parliament-deploy</code> script.</dd>
                <dt><code>www/search</code></dt>
                <dd>Contains the code for the Dutch proceedings <a class="internal" href="#access-search">search</a>.</dd>
                <dt><code>www/xqueries</code></dt>
                <dd class="todo">Old collection for xqueries, used in xml.politicalmashup.nl etc?</dd>
              </dl>
            </div>
            <div>
              <h3 id="exist-collections">Data collections</h3>
              <p>Data in eXist are stored in collections.
                 Below is an overview of the crawlers, collection paths and number of documents.
                 Detailed <a class="politicalmashup" href="http://backend.politicalmashup.nl/stats.xq">statistics</a> overviews, e.g. number of speeches and percentage of identified members, of the proceedings can be calculated online.</p>

              <table>
                <tr>
                  <th>crawler</th>
                  <th>collection</th>
                  <th>#documents</th>
                </tr>
                <tr>
                  <td>[<code>nl-ob</code>]</td>
                  <td><code>//permanent/d/nl/proc/ob</code></td>
                  <td>28173+</td>
                </tr>
                <tr>
                  <td>[<code>nl-ob</code>]</td>
                  <td><code>//permanent/d/nl/parldoc</code></td>
                  <td>14645+</td>
                </tr>
                <tr>    
                  <td>[<code>nl-sgd</code>]</td>
                  <td><code>//permanent/d/nl/proc/sgd</code></td>
                  <td>24002</td>
                </tr>
                <tr>
                  <td>[<code>nl-members</code>]</td>
                  <td><code>//permanent/m/nl</code></td>
                  <td>3657+</td>
                </tr>
                <tr>
                  <td>[<code>nl-party</code>]</td>
                  <td><code>//permanent/p/nl</code></td>
                  <td>151+</td>
                </tr>
                <tr>
                  <td>[<code>nl-draft</code>]</td>
                  <td><code>//permanent/d/nl/draft</code></td>
                  <td>201+</td>
                </tr>
                <tr>
                  <td>[<code>uk</code>]</td>
                  <td><code>//permanent/d/uk</code></td>
                  <td>11965+</td>
                </tr>
                <tr>
                  <td>[<code>uk-members</code>]</td>
                  <td><code>//permanent/m/uk</code></td>
                  <td>13131+</td>
                </tr>
                <tr>
                  <td>[<code>be-proc-vln</code>]</td>
                  <td><code>//permanent/d/be/proc/vln</code></td>
                  <td>897+</td>
                </tr>
                <tr>
                  <td>[<code>no</code>]</td>
                  <td><code>//permanent/d/no/proc</code></td>
                  <td>12339+</td>
                </tr>
                <tr>
                  <td>[<code>dk</code>]</td>
                  <td><code>//permanent/d/dk/proc</code></td>
                  <td>7698+</td>
                </tr>
                <tr>
                  <td>[<code>se</code>]</td>
                  <td><code>//permanent/d/se/proc</code></td>
                  <td>2966+</td>
                </tr>
              </table>
            </div>
            <div>
              <h3 id="exist-bugs">Bugs</h3>
              <p class="nb">The eXist database, although very flexible and useful for our needs, has the occational hiccups.
                 When under heavy load the responsiveness can become very low (if eXists starts to swap RAM, it is usually better to just shut it down and restart).</p>
              <p class="nb">The most important bug is with the <code>xs:date</code> index on our <code>dc:date</code> fields.
                 Although <code>xs:dateTime</code> indices work perfectly, the <code>xs:date</code> index sometimes returns erroneous results.
                 It is therefore very important to always check if your results seem to conform to your idea.
                 This holds mostly for the search engine (todo link), but also for the export script (todo link) for instance.
                 Script like list-updates (todo link) that work on <code>xs:dateTime</code> do not suffer from this bug and can be assumed safe.
                 Switching from <code>xs:date</code> to <code>xs:string</code> indices on the <code>dc:date</code> field were considered and tested, but proved far too slow for the amount of data collected.</p>
            </div>
            <div>
              <h3 id="exist-2">eXist 2.0</h3>
              <p>A new stable version 2.0 of eXist has been available for a short while, but it came too late for us to incorporate.
                 The existing systems therefore run on the currently most up-to-date previous version 1.4.3.</p>
              <p>The <a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/parliament-deploy">parliament-deploy</a> scripts contain the branch <code>exist2</code> that implemented a working, but not fully automated, installation of eXist 2.0.
                 Althought the database works, and existing code can be get to work, it requires quite a lot of redesigning due to a change in structure.
                 It does look promising, for use as current <a class="internal" href="#access">access</a> system, for other uses in e.g. education, and hopefully reduces the number of bugs.</p>
              <p class="todo">Fully revise the code to work with eXist 2.0 and update the frontend.</p>
            </div>
          </div>
          <aside>
            <h3>Links</h3>
            <section class="external">
              <h4>external</h4>
              <dl>
                <dt><a class="external" href="http://exist-db.org/">http://exist-db.org/</a></dt>
                <dd>Homepage of the eXist database system.
                    Note that the website presents the 2.0 version, while we use the legace 1.4 version.</dd>
                <dt><a class="external" href="http://www.oxygenxml.com/">http://www.oxygenxml.com/</a></dt>
                <dd>Homepage of the oXygen editor.</dd>
              </dl>
            </section>
            <section class="twiki">
              <h4>twiki</h4>
              <dl>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupExistDatabases">PoliticalMashupExistDatabases</a></dt>
                <dd>Up to date (on 2013-06-19) overview of all running eXist installations, including their purpose.</dd>
                <dd class="nb">Also contains the physical locations on disk, of the databases and backups.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupRunningServices">PoliticalMashupRunningServices</a></dt>
                <dd>Up to date (on 2013-06-19) overview of <em>running processes and how to (re)start</em> them.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/MashupMachines">MashupMachines</a></dt>
                <dd class="old">Description (old) of the server hardware the eXist databases are running on.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/PoliticalMashupStructure">PoliticalMashupStructure</a></dt>
                <dd>More recent overview of server hardware.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/EXistDB">EXistDB</a></dt>
                <dd class="old">Initial description of and research into the eXist database system.</dd>
                <dt><a class="politicalmashup" href="http://ilps.science.uva.nl/twiki/bin/view/Main/MigratingExist">MigratingExist</a></dt>
                <dd class="old">Contains list of projects running on the early eXist machines.</dd>
              </dl>
            </section>
            <section class="git">
              <h4>git</h4>
              <dl>
                <dt><a class="politicalmashup" href="https://github.science.uva.nl/politicalmashup/parliament-deploy">politicalmashup/parliament-deploy</a></dt>
                <dd>Deployment/installation script to automate large parts of the eXist installation procedure.</dd>
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