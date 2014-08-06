xquery version "3.0";
declare namespace expath="http://expath.org/ns/pkg";
declare option exist:serialize "method=html5 media-type=text/html";
import module namespace export="http://politicalmashup.nl/modules/export";
<html>
  <head>
    <meta charset="utf-8"/>
    <title>ODE-II / Tools / Timelines</title>
    {export:html-css-github()}
  </head>
  <body>
    <h1>Chronological overview of entities and distinctive terms</h1>
    <p>A quick visual overview of the importance of terms is often presented as a timeline, e.g. the <a href="https://books.google.com/ngrams">Google books ngram viewer</a> or a similar viewer on a Dutch corpus of <a href="http://kbkranten.politicalmashup.nl/#q/minister%20van%20oorlog|minister%20van%20defensie">newspaper archives</a>.</p>
    <p>Using the summary annotations, entities and distinctive terms, similar charts can be created.<br/>
       This gives additional possibilities to search with respect to different time periods.</p>
    <p>These charts use a pre-computed vocabulary (en entities and terms) and currently have no free-text search enabled.
       <em>TODO: describe entity list or way to get at terms, but that is only a question of interface.</em>
    </p>
       
    <h2>Examples</h2>
    <p>Some examples that show possible events, and highlight the importance of proper interpretation.</p>

    <h3>Innovatie</h3>
    <p>todo: check links etc</p>
    <p>Since several years, a new (or newly named) department exists with "Innovatie" in its name: <a href="http://localhost:8080/exist/apps/resolver/nl.proc.ob.d.h-tk-20112012-91-16?view=entities#nl.proc.ob.d.h-tk-20112012-91-16.1.3.3">minister van Economische Zaken, Landbouw en Innovatie</a>, which probably explains the rise in entity Innovatie.
       Comparing it to the lemma graphs: <a href="http://localhost:8080/exist/apps/ode-tools/lemma-graph.xq?view=table&amp;lemma=innovatie&amp;pos=all&amp;collection=d%2Fnl%2Fproc%2Fob">innovatie: all</a>,
        <a href="http://localhost:8080/exist/apps/ode-tools/lemma-graph.xq?view=table&amp;lemma=innovatie&amp;pos=N&amp;collection=d%2Fnl%2Fproc%2Fob">innovatie: noun</a>,
         <a href="http://localhost:8080/exist/apps/ode-tools/lemma-graph.xq?view=table&amp;lemma=innoveren&amp;pos=WW&amp;collection=d%2Fnl%2Fproc%2Fob">innoveren: verb</a></p>
    
    <h3>Libië</h3>
    <p>During the early months of 2011, a rebellion arose in Libya. This can clearly be seen in the entity Libië (Libya in Dutch).
    <a href="http://localhost:8080/exist/apps/ode-tools/entity-graph.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Libi%C3%AB">Libya per month</a>,
    <a href="http://localhost:8080/exist/apps/ode-tools/entity-graph2.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Libi%C3%AB">Libya per day</a>
    </p>
    
    <h3>Zuidas</h3>
    <p>Observe that the terms include nouns, verbs and adjectives. That is, they do not include names which named entities typically are.
       This means that searching for entities, e.g. <a href="http://localhost:8080/exist/apps/ode-tools/entity-graph.xq?view=table&amp;entity=http%3A%2F%2Fnl.wikipedia.org%2Fwiki%2FZuidas&amp;collection=d%2Fode">Zuidas</a> are fully complementary to the terms e.g. <a href="http://localhost:8080/exist/apps/ode-tools/lemma-graph.xq?view=table&amp;lemma=zuidas&amp;pos=all&amp;collection=d%2Fode">zuidas</a>.
       Compare for instance to full-text search <a href="http://localhost:8080/exist/apps/ode-tools/municipality-search.xq?search=document&amp;start-date=&amp;end-date=&amp;limit=20&amp;terms=10&amp;query=zuidas">zuidas</a> which returns capitalised matches (i.e. names). 
    </p>
    
    <h2>List of timeline tools</h2>
    <p></p>
    <ul>
      <li><a href="entity-graph.xq">entity-graph.xq</a> todo.</li>
      <li><a href="....xq">....xq</a> ...</li>
    </ul>
  </body>
</html>