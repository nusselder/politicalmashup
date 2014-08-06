xquery version "3.0";
declare namespace expath="http://expath.org/ns/pkg";
declare option exist:serialize "method=html5 media-type=text/html";
import module namespace export="http://politicalmashup.nl/modules/export";
<html>
  <head>
    <meta charset="utf-8"/>
    <title>{doc("expath-pkg.xml")/expath:package/expath:title/text()}</title>
    {export:html-css-github()}
  </head>
  <body>
    <h1>Political Mashup / Backend</h1>
    <p>Below is an overview of most utility scripts. See also <a href="http://documentation.politicalmashup.nl/#access-backend">documentation.politicalmashup.nl</a></p>
    
    <dl>
      <dt><a href="export.xq">export.xq</a></dt>
      <dd>Facilitates listing all available data, with multiple input source and output format options.
          Useful for listings fed to <code>curl</code> etc.</dd>

      <dt><a href="id-members.xq?view=table">id-members.xq</a></dt>
      <dd>Identify political members based on their name and additional context. Explicitit member documents are available for Dutch an UK politicians.
          Possibly the most important script.</dd>

      <dt><a href="demo-search.xq">demo-search.xq</a></dt>
      <dd>Search interface for the proceedings data.
          Has fewer options than <a href="http://search.politicalmashup.nl/">search.politicalmashup.nl</a> but is generally faster, and allows searching in all different language proceedings.</dd>
      
      <dt><a href="id-parldoc.xq?view=table">id-parldoc.xq</a></dt>
      <dd>Identify parliamentary documents based on a dossier number and dossier subnumber. Script is able to correctly detect reprints.</dd>
      
      <dt><a href="id-parties.xq?view=table">id-parties.xq</a></dt>
      <dd>Identify parties based on a string and a date.</dd>

      <dt><a href="list-updates.xq">list-updates.xq</a></dt>
      <dd>List all documents added or updated since a given <code>xs:dateTime</code>.</dd>
      
      <dt><a href="list-votes.xq">list-votes.xq</a></dt>
      <dd>List all <em>votes</em> per legislative period. Useful for the analyses requested by newspapers etc.</dd>

      <dt>---------</dt>
      

      <dt><a href="analyse-members.xq">analyse-members.xq</a></dt>
      <dd>Allow analysis of members and their interactions, per legislative period: list all active members, list all text paragraphs from a member, list all scenes for inspection, and list all <em>interruptions</em>.</dd>

      <dt><a href="check-party-seats.xq">check-party-seats.xq</a></dt>
      <dd>Old script used to analyse the seats distribution, to check if it is corectly extracted from the member data.
          Currently not very useful, but could be updated.</dd>

      <dt><a href="complete.xq">complete.xq</a></dt>
      <dd>Analyses if the data is <em>complete</em>, by determining the sessions and items that should at least be availble, and checking for them.
          Note that this can be a computation-intensive script to run.</dd>
      
      <dt><a href="list-handle.xq?view=table">list-handle.xq</a></dt>
      <dd>List a data collection as a <a class="internal" href="handle">Handle</a> batch-script.</dd>
      
      <dt><a href="list-members.xq?col=nl">list-members.xq</a></dt>
      <dd>List all members given filters (date, house, member-id etc.). More or less id-members.xq without a query.
          Used in the past to supply people with a lists of politicians in xml.</dd>
      
      <dt><a href="list-parldoc.xq">list-parldoc.xq</a></dt>
      <dd>List all available parliamentary documents (currently only amendments) and their number of votes.</dd>
      
      <dt><a href="list-parties.xq">list-parties.xq</a></dt>
      <dd>List all parties, given some filters.</dd>
      
      <dt><a href="list-party-seats.xq">list-party-seats.xq</a></dt>
      <dd>List the seats of a party given some date and house. The seats are calculated dynamically during transformation, based on the people being a member for that party of that house.</dd>
      
      <dt><a href="get-votes.xq">get-votes.xq</a></dt>
      <dd>Old, flaky, but important script that searches for votes in the proceedings based on a dossier- and sub-number.
          Throws an error when called without arguments, as an example see <a href="get-votes.xq?dossiernummer=32469&amp;ondernummer=18">kst-32469-18</a>.</dd>
          
      <dt><a href="stats.xq">stats.xq</a></dt>
      <dd>Calculate <em>statistics</em> on the size of the data and <em>percentage of members identified</em>.</dd>
    </dl>
    
  </body>
</html>