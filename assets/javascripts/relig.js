function reorder() {
  // currently unused; need UI interface
  var gridster = $('.gridster ul:first').data('gridster')
  var items = $('.gridster ul li')
  items.sort(function(a,b) {
      var valueA = parseInt($(a).find(".raw-value").text())
      var valueB = parseInt($(b).find(".raw-value").text())
      return valueB - valueA
  })
  items.detach()
  gridster.remove_all_widgets()
  
  $.each(items, function (i, e) {
    var item = $(this);
    var columns = parseInt(item.attr("data-sizex"));
    var rows = parseInt(item.attr("data-sizey"));
    gridster.add_widget(item, columns, rows);
  });
}
