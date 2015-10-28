function getUrlVars() {
  var vars = [], hash;
  var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
  for(var i = 0; i < hashes.length; i++)
  {
    hash = hashes[i].split('=');
    vars.push(hash[0]);
    vars[hash[0]] = hash[1];
  }
  return vars;
};

$(document).ready(function() {
  var args = getUrlVars();
  if ('search' in args) {
    $('#search').val(decodeURI(args['search']));
  }
  if ('sortby' in args) {
    $('#sortby').val(decodeURI(args['sortby']));
  } else {
    $('#sortby').val('シリアル番号');
  }
  var header = !{JSON.stringify(header)};
  var size = 20;
  var col = [];
  var num = 0;
  var pages = 0;
  var i = 0;
  search_fn();

  function search_fn() {
    $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", function (json) {
      var data = [];
      var find = [];
      var search = $("#search").val();
      var searches = search.split(/ or /);
      if (searches.length === 0) {
        searches[0] = search;
      }
      for (var mysearch in searches) {
        searches[mysearch] = '^(?=.*' + searches[mysearch].split(/\s+/).join(')(?=.*') + ')';
      }
      var re = new RegExp(searches.join('|'), "i");
      console.log(searches.join('|'));
      num = 0;
      for (var id in json) {
        var line = [];
        for (var item in header) {
          var val = json[id][header[item]];
          json[id][header[item]] = val ? val : '';
          line.push((json[id][header[item]] + '').replace("\n", " "));
        }
        if (!json[id]['テスト'] && (search === '' || line.join(',').match(re))) {
//        json[id]['プログラムバージョン'] = json[id]['プログラムバージョン'].replace(/\./g, '').replace(/:/, '.');
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
      var page = '';
      for (var i = 0; i < pages; i++) {
        page += '<option value="' + i + '"">' + (i + 1) + ' / ' + pages + '</option>';
      }
      $("#page").html(page);
      draw();

      $("#page").change(function(){
        draw();
      });

      function draw() {
        var p = parseInt($('#page').val());
        var tbl = "</tr>";
        for (i = p * size; i < p * size + size; i++) {
          if (i >= num) break;
          var line = data[i];
          tbl += "<tr><td>" + (i + 1) + "</td>";
          for (var j = 0; j < header.length; j++) {
            var cell = header[j];
            var value = line[cell];
            if (cell === "発電所名") {
              var value = '<a href="https://maps.google.co.jp/maps?ll=' + line['緯度'] + ',' + line['経度'] + '&z=11&q=' + line['緯度'] + ',' + line['経度'] + '+(' + encodeURI(line['発電所名'] + '発電所') + ')&hl=ja&iwloc=A" target="_blank">' + line['発電所名'] + '発電所</a>';
            } else if (cell === "シリアル番号") {
              var value = '<a href="' + line['URL'] + '" target="_blank">' + line['シリアル番号'] + '</a>';
            }
            tbl += "<td>" + value.toString().replace(/\n/g, '<br />') + "</td>";
          }
          tbl += "</tr>";
        }
        $("#mytable").html(tbl);
        var date = new Date();
        $("#numbers").text(num + " 箇所 (" + date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate() + "日 時点)");

      }
    });
  }
  return false;
});