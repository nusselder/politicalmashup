xquery version "3.0";
declare namespace expath="http://expath.org/ns/pkg";
declare option exist:serialize "method=html5 media-type=text/html";
import module namespace export="http://politicalmashup.nl/modules/export";
<html>
  <head>
    <meta charset="utf-8"/>
    <title>ODE-II / Tools / Summary evaluation</title>
    {export:html-css-github()}
  </head>
  <body>
    <h1>Evaluation of the ODE-II Amsterdam Municipality data set summaries.</h1>
    <p>Below is a list of tools to do an evaluation of the summaries.
       The premise of the evaluation is that terms+entities serve as a good summary for documents.
       Such a summary is useful in a search listing, e.g. <a href="../municipality-search.xq?query=innovatie">"innovatie"</a> and to get a quick impression when viewing a <a href="../../resolver/ode.d.220lammeren?view=entities">document</a>.</p>
    <p>For the setup, we pose that a human reader should be able to have an understanding, i.e. create a description, of a document based only on the terms+entities.
       Someone else should then be able to match the original document, based only on this description.<br/>
       Each evaluation consists of ten documents, that need to both be described and matched.</p>
       
    <p>For the <strong>description</strong>, the top ten most distinctive terms are shown with font sizes decreasing with importance (relative to the top ten position, i.e. not related to the original probabilities).
       Alongside the terms, all found entity references are listed, ordered by the number of occurences.
       An example of step one (in Dutch) shows the <a href="describe-document.xq?evaluation-id=5&amp;document-number=3">description</a> given for a document summary.</p>
       
    <p>For the <strong>matching</strong>, the list of described documents is shown, in randomised order for the evaluation but equal between all each descriptions.
       Each document should be read quickly, possible either via a simple document viewer (<a href="view-document.xq?evaluation-id=5&amp;from-document=3&amp;view-document=7">example</a>) or the original source PDF (if available).
       An example of step two (in Dutch) shows the <a href="match-document.xq?evaluation-id=5&amp;document-number=3">description</a> with a document selected.</p>
    
    <p>Two evaluation runs were performed. Each achieved a perfect score with all documents matched correctly.
       This could mean the setup is a bit too simple; the first step was perceived subjectively as hard, but the second step was considered easy.
       It does show that the summaries are effective in distinguishing between documents with different topics but in the same domain.
       Details of both evaluations can be viewed <a href="details.xq?evaluation-id=4&amp;submit=yes">here</a> and <a href="details.xq?evaluation-id=5&amp;submit=yes">here</a>.</p>

    <h2>List of evaluation tools</h2>
    <p>N.B. rights to edit/create evaluations has been disabled on this server.</p>
    <ul>
      <li><a href="list.xq">list.xq</a> List available done, and todo, evaluations, with relevant links to the tools below.</li>
      <li><a href="describe-document.xq">describe-document.xq</a> Step one, describe documents based on their summary information (distinctive terms and entities).</li>
      <li><a href="match-document.xq">match-document.xq</a> Step two, match documents to descriptions.</li>
      <li><a href="view-document.xq">view-document.xq</a> Simple document viewer used in the match-document step.</li>
      <li><a href="details.xq">details.xq</a> Show all details of a specific evaluation, including the matching results.</li>
      <li><a href="create.xq">create.xq</a> create a new evaluation set.</li>
    </ul>
  </body>
</html>