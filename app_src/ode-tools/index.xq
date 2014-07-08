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
    <h1>Tools for the ODE-II data sets.</h1>
    <p>Below is an overview of all available analysis and search tools.</p>
    
    <h2>Evaluation (M3)</h2>
    <p>An <a href="evaluation/">evaluation</a> of the summary, based on distinctive terms and entities, of Amsterdam municipality documents.</p>
    
    <h2>Timeline (M3)</h2>
    <p>A linechart approach to display a chronological <a href="timeline/">timeline</a> of terms and entities.</p>
    
    <h2>Search (M3)</h2>
    <p>todo: overview of all presentation-ready search interfaces (including those listed below)</p>
    
    <h2>News (M3)</h2>
    <p>todo: news messages were queried for dutch proc, based on speaker+date and lemma terms</p>
    
    <h2>Initial assorted search interfaces (M2)</h2>
    <ul>
      <li><a href="municipality-search.xq">municipality-search.xq (M2)</a> "google"-style search interface for the Amsterdam data, enriched with term summary.</li>
      <li><a href="list-entities.xq">list-entities.xq (M1)</a> listing of all entities in a data collection.</li>
      <li><a href="entity-search.xq">entity-search.xq (M2)</a> search for documents that have a specific entity mentioned.</li>
    </ul>
    
    <h2>Early analysis tools (M1)</h2>
    <p></p>
    <ul>
      <li><a href="demo-ode-folia-counts.xq">demo-ode-folia-counts.xq (M1)</a> count number of word per POS, documents per month etc.</li>
      <li><a href="demo-ode-folia-search.xq">demo-ode-folia-search.xq (M1)</a> search specifically in single terms (in Amsterdam municipality)</li>
      <li><a href="vergunning-analyse.xq">vergunning-analyse.xq (M2)</a></li>
    </ul>
    
  </body>
</html>