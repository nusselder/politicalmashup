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
    <p>Using the summary annotations, i.e. entities and distinctive terms, similar charts can be created.<br/>
       This gives additional possibilities to search with respect to different time periods.</p>
    <p>These charts use a pre-computed vocabulary (entities and terms) and currently have no free-text search enabled.<br/>
    To find entities, use <a href="../list-entities.xq">list-entities.xq</a>; for lemmas enter the lowercase lemmatised (base) form of a word.</p>
    <p>
    For the lemmas, only verbs, (common) nouns and adjectives are made available.
    Because the entities typically pertain to proper nouns, the lemma chart and entity chart often do not overlap. 
    </p>
    
    <p><strong>Charts of entities</strong> are relatively straightforward. Two counts are always shown per period (month or day): the number of documents that contained the entity, and the number of times that entity occurred.</p>
    
    <p><strong>Charts of lemmas</strong> are presented per day. If a document does not contain a word/lemma at all, the value is zero. The importance of a lemma for several documents (of one day) can be defined in different ways. Because we are, in general, searching for periods where a term <strong>is</strong> important, the value of a term/day is computer as the <strong>maximum</strong> over documents on that day.</p>
    
    
    <h2>List of timeline tools</h2>
    <ul>
      <li><a href="entity-graph-monthly.xq">entity-graph-monthly.xq</a> chart of entity occurences collected per month, with the chart linking to a list of actual documents per month.</li>
      <li><a href="entity-graph-daily.xq">entity-graph-daily.xq</a> similar chart but plotted per day.</li>
      <li><a href="../entity-search.xq">../entity-search.xq</a> list all occurences of an entity.</li>
      <li><a href="../list-entities.xq">../list-entities.xq</a> list all found entities in a collection.</li>
      <li><a href="lemma-graph.xq">lemma-graph.xq</a> chart of lemma importance estimates per day.</li>
    </ul>
    
    
    <h2>Examples</h2>
    <p>Some examples that show possible events and interpretations.</p>

    <h3>Innovatie</h3>
    <p>Looking at the entity <em>Innovatie</em> it appears there is an significant rise in innovation in the Netherlands.
       The <a href="entity-graph-monthly.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Innovatie">chart</a> (<a href="entity-graph-daily.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Innovatie">slower daily chart</a>) shows a sudden rise in September 2010, the start of the new legislative year.</p>
    <p>Since several years however, a new (or rather renamed) department exists in the Dutch government with "Innovatie" in its name.
    If we click on the first spike on the montly chart, a <a href="../entity-search.xq?entity=http://nl.wikipedia.org/wiki/Innovatie&amp;collection=d/nl/proc/ob&amp;month=2010-11">list of entity occurences</a> allows to find the documents which mostly contain <em><a href="http://ode.politicalmashup.nl/resolver/nl.proc.ob.d.h-tk-20102011-20-25?view=entities#nl.proc.ob.d.h-tk-20102011-20-25.1.4.1.2">minister van Economische Zaken, Landbouw en Innovatie</a></em>.
    This rename by itself probably explains the rise in entity "Innovatie".</p>
    <p>If we compare these entity graphs to the lemma graphs, it appears innovation by itself is not necessarily more important than before.
       Looking at the verb "to innovate" <a href="lemma-graph.xq?lemma=innoveren&amp;pos=WW&amp;collection=d%2Fnl%2Fproc%2Fob">innoveren</a> shows no specific increase around 2011.</p>
       
    
    <h3>Libië</h3>
    <p>During the early months of 2011, a rebellion arose in Libya. This can clearly be seen in the entity <a href="entity-graph-monthly.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Libi%C3%AB">"Libië"</a> (<a href="entity-graph-daily.xq?collection=d/nl/proc/ob&amp;entity=http://nl.wikipedia.org/wiki/Libi%C3%AB">daily</a>).
    For comparison, the <a href="lemma-graph.xq?view=table&amp;lemma=libië&amp;pos=all&amp;collection=d%2Fnl%2Fproc%2Fob">lemma chart</a> is mostly empty, as expected.
    Searching the <a href="../proceedings-search.xq?search=scene&amp;start-date=2011-03-01&amp;end-date=2011-12-01&amp;limit=20&amp;terms=10&amp;query=Libië">proceedings</a> for Libya around that period (2011) shows documents and lemma terms important therein.
    For example <a href="lemma-graph.xq?view=table&amp;lemma=soevereiniteit&amp;pos=N&amp;collection=d%2Fnl%2Fproc%2Fob">sovereignty</a> shows a similar increase around March 2011.
    </p>
    
    
    <!--
    <h3>Zuidas</h3>
    <p>This means that searching for entities, e.g. <a href="../entity-graph.xq?view=table&amp;entity=http%3A%2F%2Fnl.wikipedia.org%2Fwiki%2FZuidas&amp;collection=d%2Fode">Zuidas</a> are fully complementary to the terms e.g. <a href="../lemma-graph.xq?view=table&amp;lemma=zuidas&amp;pos=all&amp;collection=d%2Fode">zuidas</a>.
       Compare for instance to full-text search <a href="../municipality-search.xq?search=document&amp;start-date=&amp;end-date=&amp;limit=20&amp;terms=10&amp;query=zuidas">zuidas</a> which returns capitalised matches (i.e. names). 
    </p>
    -->
    
    
  </body>
</html>