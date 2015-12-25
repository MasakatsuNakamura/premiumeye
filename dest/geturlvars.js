this.getUrlVars = function() {
  var hash, i, item, len, myurl, ref, vars;
  vars = {};
  myurl = window.location.href;
  if (myurl.indexOf('?') > 0) {
    ref = myurl.slice(myurl.indexOf('?') + 1).split('&');
    for (i = 0, len = ref.length; i < len; i++) {
      item = ref[i];
      hash = item.split('=');
      vars[hash[0]] = decodeURIComponent(hash[1]);
    }
    return vars;
  } else {
    return {};
  }
};
