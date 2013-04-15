$(document).ready ->
  $(".stretchtoggle").on "click", ->
    $(this).parents("div:first").find(".settings-stretcher:first").toggle()
    false

  SmartLinks.initialize
    open_selector: ".open-area"
    close_selector: ".close-area"

  $(".focus").on
    mouseenter: ->
      $(this).css "background-color", "rgb(255,255,153)"

    mouseleave: ->
      $(this).css "background-color", "transparent"
