jQuery ()->
  tocLinkTextRegexp = new RegExp('^(POST|GET|PUT|DELETE) +(/.*)$')
  tocToConsole = ()->
    $('.section.toc a, .section.document h2').each ()->
      el = $(this)
      if matches = el.text().match(tocLinkTextRegexp)
        addConsoleLink(el, matches[1], matches[2])

  addConsoleLink = (el, method, location)->
    params = $.param({method: method, location: location})
    href = "./console?#{params}"
    link = $("<small><a href='#{href}' style='padding-left:0.5em; font-size:0.7em;'>(console)</a></small>")
    if el.is('h2')
      el.append(link)
    else
      el.parent().append(link)

  tocToConsole()
