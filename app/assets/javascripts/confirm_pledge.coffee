submitPledge = ->
  $.ajax
    type: "POST"
    url: $("#new_pledge").attr('action')
    data: $('#new_pledge').serialize()
    dataType: "json"
    success: (data) ->
      window.location = data.url
    error: (data) ->
      $('.topbar-wrapper').after('<div class="centered alert-message">'+data.responseText+'</div>')

$(document).ready ->
  setTimeout submitPledge, 2000