$("#user_search_field").bind "railsAutocomplete.select", (event, data) ->
  $.ajax
    url: "search/"+data.item.id
    type: "GET"
    dataType: "HTML"
    complete: (data) ->
      $('#user_search_result').html(data.responseText)