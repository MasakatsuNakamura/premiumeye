getUrlVars = ->
  url = window.location.href
  hashes = url.slice(url.indexOf('?') + 1).split('&')
  vars = []
  for hash in hashes
    hash = hash.split('=')
    vars[hash[0]] = hash[1]
  vars

$(document).ready ->
  args = getUrlVars()
  if 'search' of args
    $('#search').val decodeURI(args['search'])
  if 'sortby' of args
    $('#sortby').val decodeURI(args['sortby'])
  else
    $('#sortby').val 'シリアル番号'
  header = [ "シリアル番号", "発電所名", "顧客名", "プラン", "営業所", "パワコン台数", "ステータス", "メーカー", "機種名", "プログラムバージョン", "センサー向き", "パワコン情報" ]
  size = 20
  col = []
  num = 0
  pages = 0
  i = 0
  search_fn()
  search_fn = ->
    $.getJSON 'https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json', (json) ->
      search = $('#search').val()
      searches = search.split(/ or /)
      if searches.length == 0
        searches[0] = search
      mysearch = []
      for item in searches
        mysearch.push("^(?=.*" + item.split(/\s+/).join(')(?=.*') + ")")
      re = new RegExp(mysearch.join('|'), 'i')
      console.log re

      data = []
      num = 0
      for id of json
        line = []
        for item of header
          val = json[id][header[item]]
          json[id][header[item]] = if val then val else ''
          line.push (json[id][header[item]] + '').replace('\n', ' ')
        if !json[id]['テスト'] and (search == '' or line.join(',').match(re))
          data.push json[id]
          num++

      if $('#sortby').val() != ''
        data.sort (val1, val2) ->
          val1 = val1[$('#sortby').val()]
          val2 = val2[$('#sortby').val()]
          if val1 < val2
            -1
          else if val1 > val2
            1
          else
            0

      pages = parseInt(num / size) + 1
      page = ''
      i = 0
      while i < pages
        page += '<option value="' + i + '"">' + i + 1 + ' / ' + pages + '</option>'
        i++
      $('#page').html page
      draw()
      $('#page').change ->
        draw()

# draw function
      draw = ->
        p = parseInt($('#page').val())
        tbl = '</tr>'
        for i in [0..size]
          ii = p * size + i;
          if ii >= num
            break
          line = data[ii]
          tbl += '<tr><td>' + ii + 1 + '</td>'
          for cell in header
            value = line[cell]
            if cell == '発電所名'
              value = '<a href="https://maps.google.co.jp/maps?ll=' + line['緯度'] + ',' + line['経度'] +
                '&z=11&q=' + line['緯度'] + ',' + line['経度'] +
                '+(' + encodeURI(line['発電所名'] + '発電所') + ')&hl=ja&iwloc=A" target="_blank">' + line['発電所名'] + '発電所</a>'
            else if cell == 'シリアル番号'
              value = '<a href="' + line['URL'] + '" target="_blank">' + line['シリアル番号'] + '</a>'
            tbl += '<td>' + value.toString().replace(/\n/g, '<br />') + '</td>'
          tbl += '</tr>'
        $('#mytable').html tbl
        date = new Date
        $('#numbers').text num + ' 箇所 (' + date.getFullYear() + '年' + date.getMonth() + 1 + '月' + date.getDate() + '日 時点)'


