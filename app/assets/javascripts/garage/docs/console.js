jQuery(function(){
  $(".get-oauth-token").colorbox({
    transition: "none",
    href: "#oauth-dialog",
    inline: true
  });

  $(".modal-close").click(function(ev) {
    $.colorbox.close();
    ev.preventDefault();
  });

  var addNewParamField = function(container) {
    const nextId = "parameter-" + $('.parameter', container).length;
    const copy = $('.template .parameter').clone().attr('id', nextId);
    $('.close-field', copy).click(ev => $('#' + nextId).detach());
    $('.add-field', copy).click(ev => addNewParamField(container));
    copy.show().appendTo(container);
  };

  const buildData = function(container) {
    const data = {};
    $('.parameter', container).each(function(index) {
      const name = $('.name', this).val();
      const value = $('.value', this).val();
      return data[name] = value;
    });
    return data;
  };

  $('.console #method').change(function(ev) {
    if (($(this).val() === 'POST') || ($(this).val() === 'PUT')) {
      if ($('.parameters .parameter').length === 0) {
        addNewParamField($('.parameters'));
      }
    } else {
      $('.parameters').empty();
    }
  });

  const buildHyperlinks = function(json) {
    const html = $('<div/>').text(json).html().replace(/"href": "(\/.*?)"/g, "\"href\": \"<a>$1</a>\"");
    const dom = $(`<div>${html}</div>`);
    $('a', dom).each(function(i) {
      return $(this).attr('href', `${location.pathname}?location=${encodeURIComponent($(this).text())}&method=GET`);
    });
    return dom.html();
  };

  $('.console .send-request').click(function(ev) {
    $('#api-headers').text('');
    $('#api-response').text('');

    console.log(buildData($('.parameters')));
    $.ajax({
      type: $('#method').val(),
      url: $('#base').val() + $('#location').val(),
      headers: {'Authorization': 'Bearer ' + $('#access_token').val()},
      cache: false,
      data: buildData($('.parameters')),
      dataType: 'json',
      complete() {
        const queryString = $.param({'location': $('#location').val(), 'method': $('#method').val()});
        const newFullpath = `${location.pathname}?${queryString}`;
        history.pushState('', '', newFullpath);
        $("#oauth-dialog #return_to").val(newFullpath);
      },
      success(data, textStatus, xhr) {
        $('#api-headers').text(`${xhr.status} ${xhr.statusText}\n` + xhr.getAllResponseHeaders());
        $('#api-response').html(buildHyperlinks(JSON.stringify(data, undefined, 2)));
      },
      error(xhr, textStatus, error) {
        $('#api-headers').text(`${xhr.status} ${xhr.statusText}\n` + xhr.getAllResponseHeaders());
        $('#api-response').text(xhr.responseText);
      }
    });
    ev.preventDefault();
  });

  if (($('.console #token').val() !== '') && ($('.console #location').val() !== '') && ($('.console #method').val() === 'GET')) {
    $('.send-request').click();
  }

  if ($('.oauth-callback-redirect').size() > 0) {
    const token = window.location.hash.match(/\#access_token=(\w+)/)[1];
    if (token) {
      $('#access_token').val(token);
      $('form.oauth-callback-redirect').submit();
    }
  }

  $('#oauth-dialog .token-scope-check-all').click(function(ev) {
    $('.token-scope-checkbox').prop('checked', this.checked);
  });

  return $('#oauth-dialog .token-scope-checkbox').click(function(ev) {
    if ($('.token-scope-checkbox:not(:checked)').length === 0) {
      $('.token-scope-check-all').prop('checked', true);
    } else if (!this.checked) {
      $('.token-scope-check-all').prop('checked', false);
    }
  });
});
