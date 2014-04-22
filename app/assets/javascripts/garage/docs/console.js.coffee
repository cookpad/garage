jQuery ()->
  $(".get-oauth-token").colorbox(
    transition: "none"
    href: "#oauth-dialog"
    inline: true
  )

  $(".modal-close").click (ev) ->
    $.colorbox.close()
    ev.preventDefault()

  $("#oauth-dialog .authenticate").click (ev) ->
    $("form#oauth-authenticate").submit()
    ev.preventDefault()

  $(".console .validate-token").click (ev) ->
    $("#method").val('GET')
    $("#location").val("/oauth/token/info")
    $('.send-request').click()

  buildAuthorizedUrl = (base, location, token) ->
    url = base + location
    if url.indexOf('?') > 0
      url += '&'
    else
      url += '?'
    url + 'access_token=' + token

  addNewParamField = (container) ->
    nextId = "parameter-" + $('.parameter', container).length
    copy = $('.template .parameter').clone().attr('id', nextId)
    $('.close-field', copy).click (ev) ->
      $('#' + nextId).detach()
    $('.add-field', copy).click (ev) ->
      addNewParamField(container)
    copy.show().appendTo(container)

  buildData = (container) ->
    data = {}
    $('.parameter', container).each (index) ->
      name = $('.name', this).val()
      value = $('.value', this).val()
      data[name] = value
    data

  $('.console #method').change (ev) ->
    if $(this).val() == 'POST' or $(this).val() == 'PUT'
      if $('.parameters .parameter').length == 0
        addNewParamField($('.parameters'))
    else
      $('.parameters').empty()

  buildHyperlinks = (json) ->
    html = $('<div/>').text(json).html().replace /"href": "(\/.*?)"/g, "\"href\": \"<a>$1</a>\""
    dom = $("<div>#{html}</div>")
    $('a', dom).each (i) ->
      $(this).attr('href', "#{location.pathname}?location=#{encodeURIComponent($(this).text())}&method=GET")
    dom.html()

  $('.console .send-request').click (ev) ->
    $('#api-headers').text ''
    $('#api-response').text ''

    url = buildAuthorizedUrl $('#base').val(), $('#location').val(), $('#access_token').val()
    console.log buildData($('.parameters'))
    $.ajax
      type: $('#method').val(),
      url: url,
      cache: false,
      data: buildData($('.parameters')),
      dataType: 'json',
      complete: ->
        queryString = $.param({'location': $('#location').val(), 'method': $('#method').val()})
        history.pushState('', '', "#{location.pathname}?#{queryString}")
      success: (data, textStatus, xhr) ->
        $('#api-headers').text("#{xhr.status} #{xhr.statusText}\n" + xhr.getAllResponseHeaders())
        $('#api-response').html buildHyperlinks(JSON.stringify(data, undefined, 2))
      error: (xhr, textStatus, error) ->
        $('#api-headers').text("#{xhr.status} #{xhr.statusText}\n" + xhr.getAllResponseHeaders())
        $('#api-response').text xhr.responseText
    ev.preventDefault()

  if $('.console #token').val() != '' && $('.console #location').val() != '' && $('.console #method').val() == 'GET'
    $('.send-request').click()

  if $('.oauth-callback-redirect').size() > 0
    token = window.location.hash.match(/\#access_token=(\w+)/)[1]
    if token
      $('#access_token').val(token)
      $('form.oauth-callback-redirect').submit()
