$(document).ready(function() {
  $("input#speaker_name").autocomplete({
    source: "autocomplete/query.xq",
    select: function(event, ui) {
      $("input#speaker_id").val(ui.item.id);
    }
  });
});
