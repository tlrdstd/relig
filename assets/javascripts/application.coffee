# dashing.js is located in the dashing framework
# It includes jquery & batman for you.
#= require dashing.js

#= require_directory .
#= require_tree ../../widgets

# override of Dashing Batman filter
# Show an extra significant digit
Batman.Filters.shortenedNumber = (num) ->
  return num if isNaN(num)
  if num >= 1000000000
    (num / 1000000000).toFixed(2) + 'B'
  else if num >= 1000000
    (num / 1000000).toFixed(2) + 'M'
  else if num >= 1000
    (num / 1000).toFixed(2) + 'K'
  else
    num

Dashing.on 'ready', ->
  Dashing.widget_margins ||= [5, 5]
  Dashing.widget_base_dimensions ||= [280, 280]
  Dashing.numColumns ||= 4

  contentWidth = (Dashing.widget_base_dimensions[0] + Dashing.widget_margins[0] * 2) * Dashing.numColumns

  Batman.setImmediate ->
    $('.gridster').width(contentWidth)
    $('.gridster ul:first').gridster
      widget_margins: Dashing.widget_margins
      widget_base_dimensions: Dashing.widget_base_dimensions
      avoid_overlapped_widgets: !Dashing.customGridsterLayout
      draggable:
        stop: Dashing.showGridsterInstructions
        start: -> Dashing.currentWidgetPositions = Dashing.getWidgetPositions()

  $('.clickable').click ->
    window.location = $(this).data 'url'
