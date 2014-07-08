let $title := "Zoeken in de Handelingen: help"
let $lucene-base := "http://lucene.apache.org/core/old_versioned_docs/versions/2_9_1"

return
  <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="nl" lang="nl">
    <head>
      <title>{$title}</title>
      <link rel="stylesheet" href="search.css" type="text/css" />
    </head>
    <body>
      <h1>{$title}</h1>

      <p>
        Met de pagina <a href="/search/">Zoeken in de Handelingen</a>
        kunnen de <strong>Handelingen van Eerste en Tweede Kamer</strong>
        doorzocht worden op trefwoorden.
      </p>
      
      <a name="update"/>
      <h2>Up to date</h2>
      <p>
        Nieuwe Handelingen worden elke nacht van overheid.nl opgehaald.
        Handelingen worden daar geplaatst met een vertraging van zo'n drie weken.
        Verslagen van meer recente vergaderingen zijn te vinden op de sites van de <a href="http://www.tweedekamer.nl/kamerstukken/verslagen/">Tweede Kamer</a> en <a href="http://www.eerstekamer.nl/begrip/stenogram">Eerste Kamer</a>.  
      </p>

      <a name="queries"/>
      <h2>Zoekopdrachten</h2>
      <p>
        In het vak "zoekopdracht" kunnen trefwoorden opgegeven worden.
        De meest basale zoekopdracht bestaat uit één woord.
      </p>

      <p>
        Er zijn diverse mogelijkheden om op meerdere woorden te zoeken.
        Een simpele spatie tussen twee woorden geeft een "OR"-zoekopdracht,
        bijv. <tt>belasting premiedruk</tt> zoekt op beide trefwoorden
        en geeft alle documenten terug waarin minstens een van beide voorkomt
        (<a href="./?q=belasting+premiedruk">voorbeeld</a>).
        Moeten beide woorden voorkomen in elk resultaat, gebruik dan het woord
        <tt>AND</tt>, dus <tt>belasting AND premiedruk</tt>
        (<a href="./?q=belasting+AND+premiedruk">voorbeeld</a>).
        Het aantal treffers van de tweede zoekopdracht zal veel lager zijn
        dan die van de eerste.
      </p>

      <p>
        Gebruik aanhalingstekens om op een frase van meerdere woorden te zoeken:
        <tt>"gewone mensen"</tt> (<a href='./?q="gewone+mensen"'>voorbeeld</a>)
        vindt alle voorkomens van <em>gewone</em>, direct gevolgd door <em>mensen</em>.
      </p>

      <p>
        Zoeken op varianten gebeurt met een sterretje:
        <tt>fascis*</tt> (<a href="./?q=fascis*">voorbeeld</a>)
        vindt <em>fascisme</em>, <em>fascistisch</em>, enz.
      </p>

      <p>
        De volledige toegestane syntaxis voor uitgebreide zoekopdrachten
        staat beschreven in de documentatie van het zoekmachinepakket
        <a href="{$lucene-base}/queryparsersyntax.html">Lucene</a>.
      </p>

      <a name="persons-parties"/>
      <h2>Sprekers en partijen</h2>
      <p>
        In het vak Spreker kan de naam van een persoon worden
        om een lijstje personen tevoorschijn te toveren;
        klik op één van de namen om de identifier van die persoon
        in het rechtervak te krijgen.
        Met de identifier wordt dan gezocht
        op uitspraken in het parlement van de betreffende persoon.
      </p>

      <p>
        Met Rol kan verder gefilterd worden op de rol die een spreker
        in de Staten-Generaal vervult.
        Een spreker kan natuurlijk in de loop der tijd verschillende rollen
        vervuld hebben, bijv. eerst Kamerlid en daarna kabinetslid.
        Let op dat een Rol anders dan "alle" in combinatie met <em>topic</em>
        (zie hieronder) geen zin heeft.
      </p>

      <p>
        Met Partij kan bovendien op partij/fractie gefilterd worden.
        Let op dat zoeken met een restrictie op personen én één op partijen
        géén resultaten oplevert als geen van de betreffende personen
        lid zijn geweest van de betreffende partij.
      </p>

      <a name="date"/>
      <h2>Datums</h2>
      <p>
        Met de optie Datums kunnen een begin- en einddatum opgegeven worden
        (zie ook chronologisch sorteren, <a href="#sorting">hieronder</a>).
        Zo zal "gewoon" zoeken op
        <a href="./?q=boeing&amp;order=chrono"><tt>boeing</tt></a>
        een hoop hits over de KLM opleveren,
        maar levert zoeken op hetzelfde trefwoord in de periode
        <a href="./?q=boeing&amp;order=chrono&amp;startdate=1992&amp;enddate=1993">1992-93</a>
        informatie op over de Bijlmerramp.
      </p>

      <p>
        Datums worden opgegeven als <tt>JJJJ-MM-DD</tt>,
        dus bijv. <tt>1931-03-10</tt>, of als <tt>JJJJ-MM</tt>,
        of als <tt>JJJJ</tt>.
        Altijd wordt het hele jaar of de hele maand bedoeld,
        dus zoeken op <tt>1961</tt> tot <tt>1975-02</tt> betekent:
        van 1 januari 1961 tot 28 februari 1975.
      </p>

      <a name="granularity"/>
      <h2>Fijnmazigheid</h2>
      <p>
        De dataset is (in principe) opgebouwd uit <em>topics</em>,
        die bestaan uit scènes, die weer bestaan uit <em>speeches</em>.
        Met de optie Fijnmazigheid kan het niveau van zoeken langs deze as
        bepaald worden.
        Ook kan alleen in de titels van topics gezocht worden,
        bijv. op de <a href="./?q=BES&amp;granularity=title">BES</a>.
      </p>

      <p>
        (Niet alle topics bevatten scènes;
        daarom wordt bij een fijnmazigheid van <em>topic</em>
        ook gezocht binnen scènes die geen deel uitmaken van een topic.)
      </p>

      <a name="sorting"/>
      <h2>Volgorde</h2>
      <p>
        Resultaten kunnen op vier manieren geordend worden.
        <ul>
          <li>
            "Chronologisch" en "omgekeerd chronologisch" werken op basis van de
            datuminformatie in de documenten.
          </li>
          <li>
            Relevantie wordt bepaald met de
            <a href="{$lucene-base}/scoring.html">scoreformule van Lucene</a>.
          </li>
          <li>
            Lengte van een debat wordt bepaald aan de hand van het aantal
            "speeches" in de "scène" waarin een hit gevonden wordt.
          </li>
        </ul>
      </p>
    </body>
  </html>
