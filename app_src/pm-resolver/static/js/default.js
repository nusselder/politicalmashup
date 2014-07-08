// TODO: use yui, make text highlighter
var highlight_hash = function() {
  try {
    var hash = window.location.hash;
    var highlightable_p = document.getElementById(hash.substr(1));
    highlightable_p.className = highlightable_p.className + ' selected';
  }
  catch (e) {}
};
