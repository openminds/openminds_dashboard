class Dashing.Meter extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".meter").val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()

  onData: (data) ->
    if data.status
      node = $(@get('node'))
      meter = node.find('.meter')
      node.attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      node.addClass "status-#{data.status}"
      if data.status == 'danger'
        color = "#b30000"
      else if data.status == 'warning'
        color = "#b37300"
      else
        color = "#33692e"
      console.log meter
      console.log data.status
      meter.trigger('configure', bgColor: color)

