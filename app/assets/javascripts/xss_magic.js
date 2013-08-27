MyXssMagic = new function() {
  var ROOT = 'lovetax_widget';
  var BASE_URL = document.getElementById(ROOT).getAttribute('data-host');
  //var BASE_URL = 'http://tax.local';
  var STYLESHEET = BASE_URL + "/assets/xss_magic.css"
  var CONTENT_URL = BASE_URL + '/widget/';

  function requestStylesheet(stylesheet_url) {
    stylesheet = document.createElement("link");
    stylesheet.rel = "stylesheet";
    stylesheet.type = "text/css";
    stylesheet.href = stylesheet_url;
    stylesheet.media = "all";
    //document.lastChild.firstChild.appendChild(stylesheet);
    document.getElementsByTagName("head")[0].appendChild(stylesheet);
  }

  function requestContent(local) {
    var script = document.createElement('script');
    // How you'd pass the current URL into the request
    // script.src = CONTENT_URL + '&url=' + escape(local || location.href);
    var id = document.getElementById(ROOT).getAttribute('data-id');
    script.src = CONTENT_URL + id + '.js';
    // IE7 doesn't like this: document.body.appendChild(script);
    // Instead use:
    document.getElementsByTagName('head')[0].appendChild(script);
  }

  this.serverResponse = function(data) {
    if (!data) return;
    var div = document.getElementById(ROOT);
    if(!div) return;
    var txt = '';
    for (var i = 0; i < data.length; i++) {
      if (txt.length > 0) { txt += ", "; }
      txt += data[i];
    }
    div.innerHTML = "<h4><a class='lovetax_title' href='" + BASE_URL + "/taxes/" + data.id + "'>" + data.name + "</a></h4>" +
      "<p>" + data.description + "</p>" +
      "<div class='bar_container'><div class='bar_mortice'><div class='progress pink' style='width: " + data.percent + "%;'></div></div></div>" +
      "<p>Raising " + data.monthly + " monthly from " + data.supporters +
      (data.goal ? " ($" + data.goal + " needed)" : "") +
      "</p>";
    div.style.display = 'block';
  };

  requestStylesheet(STYLESHEET);
  requestContent();
};