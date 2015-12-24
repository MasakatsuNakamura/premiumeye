@getUrlVars = ->
    vars = {}
    myurl = window.location.href
    if myurl.indexOf('?') > 0
        for item in myurl[myurl.indexOf('?') + 1..].split('&')
            hash = item.split('=');
            vars[hash[0]] = hash[1];
        return vars
    else
        return {}

