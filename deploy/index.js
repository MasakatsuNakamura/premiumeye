(function() {
  var getUrlVars;

  getUrlVars = function() {
    var hash, hashes, j, len, url, vars;
    url = window.location.href;
    hashes = url.slice(url.indexOf('?') + 1).split('&');
    vars = [];
    for (j = 0, len = hashes.length; j < len; j++) {
      hash = hashes[j];
      hash = hash.split('=');
      vars[hash[0]] = hash[1];
    }
    return vars;
  };

  $(document).ready(function() {
    var args, col, header, i, num, pages, search_fn, size;
    args = getUrlVars();
    if ('search' in args) {
      $('#search').val(decodeURI(args['search']));
    }
    if ('sortby' in args) {
      $('#sortby').val(decodeURI(args['sortby']));
    } else {
      $('#sortby').val('シリアル番号');
    }
    header = ["シリアル番号", "発電所名", "顧客名", "プラン", "営業所", "パワコン台数", "ステータス", "メーカー", "機種名", "プログラムバージョン", "センサー向き", "パワコン情報"];
    size = 20;
    col = [];
    num = 0;
    pages = 0;
    i = 0;
    search_fn();
    return search_fn = function() {
      return $.getJSON('https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json', function(json) {
        var data, draw, id, item, j, len, line, mysearch, page, re, search, searches, val;
        search = $('#search').val();
        searches = search.split(/ or /);
        if (searches.length === 0) {
          searches[0] = search;
        }
        mysearch = [];
        for (j = 0, len = searches.length; j < len; j++) {
          item = searches[j];
          mysearch.push("^(?=.*" + item.split(/\s+/).join(')(?=.*') + ")");
        }
        re = new RegExp(mysearch.join('|'), 'i');
        console.log(re);
        data = [];
        num = 0;
        for (id in json) {
          line = [];
          for (item in header) {
            val = json[id][header[item]];
            json[id][header[item]] = val ? val : '';
            line.push((json[id][header[item]] + '').replace('\n', ' '));
          }
          if (!json[id]['テスト'] && (search === '' || line.join(',').match(re))) {
            data.push(json[id]);
            num++;
          }
        }
        if ($('#sortby').val() !== '') {
          data.sort(function(val1, val2) {
            val1 = val1[$('#sortby').val()];
            val2 = val2[$('#sortby').val()];
            if (val1 < val2) {
              return -1;
            } else if (val1 > val2) {
              return 1;
            } else {
              return 0;
            }
          });
        }
        pages = parseInt(num / size) + 1;
        page = '';
        i = 0;
        while (i < pages) {
          page += '<option value="' + i + '"">' + i + 1 + ' / ' + pages + '</option>';
          i++;
        }
        $('#page').html(page);
        draw();
        $('#page').change(function() {
          return draw();
        });
        return draw = function() {
          var cell, date, ii, k, l, len1, p, ref, tbl, value;
          p = parseInt($('#page').val());
          tbl = '</tr>';
          for (i = k = 0, ref = size; 0 <= ref ? k <= ref : k >= ref; i = 0 <= ref ? ++k : --k) {
            ii = p * size + i;
            if (ii >= num) {
              break;
            }
            line = data[ii];
            tbl += '<tr><td>' + ii + 1 + '</td>';
            for (l = 0, len1 = header.length; l < len1; l++) {
              cell = header[l];
              value = line[cell];
              if (cell === '発電所名') {
                value = '<a href="https://maps.google.co.jp/maps?ll=' + line['緯度'] + ',' + line['経度'] + '&z=11&q=' + line['緯度'] + ',' + line['経度'] + '+(' + encodeURI(line['発電所名'] + '発電所') + ')&hl=ja&iwloc=A" target="_blank">' + line['発電所名'] + '発電所</a>';
              } else if (cell === 'シリアル番号') {
                value = '<a href="' + line['URL'] + '" target="_blank">' + line['シリアル番号'] + '</a>';
              }
              tbl += '<td>' + value.toString().replace(/\n/g, '<br />') + '</td>';
            }
            tbl += '</tr>';
          }
          $('#mytable').html(tbl);
          date = new Date;
          return $('#numbers').text(num + ' 箇所 (' + date.getFullYear() + '年' + date.getMonth() + 1 + '月' + date.getDate() + '日 時点)');
        };
      });
    };
  });

}).call(this);
