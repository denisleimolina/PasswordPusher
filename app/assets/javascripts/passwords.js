// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

function saveExpirations()
{
  days_value  = document.getElementById("password_expire_after_days").value
  views_value = document.getElementById("password_expire_after_views").value
  dbv         = document.getElementById("password_deletable_by_viewer")

  $.cookie('pwpush_days',  days_value, { expires: 365 });
  $.cookie('pwpush_views', views_value, { expires: 365 });
  $.cookie('pwpush_dbv', dbv.checked.toString(), { expires: 365 });

  e = document.getElementById("cookie-save")
  e.innerHTML = "Salvo!"
  return true;
}

$(document).ready(function() {
  var secret_url_clipboard = new ClipboardJS('.copy-secret-url');
  secret_url_clipboard.on('success', function(e) {
    var clipboardButton = document.getElementById("clipboard-secret-url");
    var copyIcon = clipboardButton.innerHTML;
    clipboardButton.innerText = "Copiado!"
    setTimeout(function() {
          clipboardButton.innerHTML = copyIcon;
    }, 1000);
    e.clearSelection();
  });

  var pw_clipboard = new ClipboardJS('.copy-to-clipboard');
  pw_clipboard.on('success', function(e) {
    var clipboardButton = document.getElementById("clipboard-button");
    clipboardButton.innerText = "Copiado!"
    setTimeout(function() {
          clipboardButton.innerText = "Copiar para área de transferência";
    }, 2000);
    e.clearSelection();
  });

  days = $.cookie('pwpush_days');
  views = $.cookie('pwpush_views');

  de = document.getElementById("password_expire_after_days")
  dr = document.getElementById("daysrange")
  if (de) {
    if (days) {
      de.value = days
      dr.innerHTML = days + " Dias"
    } else {
      showDaysValue(de.value)
    }
  }

  ve = document.getElementById("password_expire_after_views")
  vr = document.getElementById("viewsrange")
  if (ve) {
    if (views) {
      ve.value = views
      vr.innerHTML = views + " Visualizações"
    } else {
      showViewsValue(ve.value)
    }
  }

  dbv_checkbox = document.getElementById('password_deletable_by_viewer')
  dbv_check_state = $.cookie('pwpush_dbv')
  if (dbv_checkbox) {
    if (dbv_check_state) {
      if (dbv_check_state == "false") {
        dbv = false
      } else {
        dbv = true
      }
      if (dbv_checkbox.checked != dbv) {
        dbv_checkbox.click()
      }
    }
  }
});

$('#password_payload').keypress(function() {
  if ($('#password_payload').val().length > 250) {
    noty({text: 'As senhas podem ter no máximo 250 caracteres.', type: 'warning'});
    $.noty.clearQueue()
    return false;
  }
});
