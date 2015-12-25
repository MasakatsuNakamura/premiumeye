$(document).ready(function() {
  var args, date, strDate, tommorow, yesterday;
  args = getUrlVars();
  if (Object.keys(args).length === 3) {
    date = new Date(args.year, args.month - 1, args.day);
  } else {
    date = new Date;
    date.setDate(date.getDate() - 1);
  }
  yesterday = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  yesterday.setDate(yesterday.getDate() - 1);
  $('#yesterday').attr("href", "?year=" + yesterday.getFullYear() + "&month=" + (yesterday.getMonth() + 1) + "&day=" + yesterday.getDate());
  tommorow = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  tommorow.setDate(tommorow.getDate() + 1);
  $('#tommorow').attr("href", "?year=" + tommorow.getFullYear() + "&month=" + (tommorow.getMonth() + 1) + "&day=" + tommorow.getDate());
  strDate = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate();
  $('#mydate').html('&nbsp;' + strDate + '&nbsp;');
  return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/" + "fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/detectLowGeneration/" + strDate + ".json", (function(_this) {
    return function(lowgen) {
      var gendata, key, value;
      if (!(lowgen != null)) {
        return false;
      }
      gendata = [];
      for (key in lowgen) {
        value = lowgen[key];
        value.id = key;
        gendata.push(value);
      }
      gendata.sort(function(a, b) {
        return a.偏差値 - b.偏差値;
      });
      return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/" + "fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", function(pvsensors) {
        var h, header, i, id, j, len, len1, list, pvsensor, ref, row, style;
        header = ['シリアル番号', '発電所名', '営業所', 'メーカー', '機種', 'プラン', '発電力量', '定格出力', '偏差値', '周辺順位', '周辺発電所数'];
        if (!(pvsensors != null)) {
          return false;
        }
        $('#myheader').append("<th>" + header.join('</th><th>') + "</th>");
        for (i = 0, len = gendata.length; i < len; i++) {
          list = gendata[i];
          row = [];
          id = list.id;
          if (pvsensors[id] == null) {
            continue;
          }
          pvsensor = pvsensors[id];
          list.偏差値 = Math.round(list.偏差値 * 10) / 10;
          list.発電力量 = Math.round(list.発電力量 * 100) / 100;
          list.定格出力 = Math.round(list.定格出力 * 10) / 10;
          if (list.偏差値 < 42 || list.電力量低下) {
            row.push('<a href=' + pvsensor.URL + ' target="_blank">' + id + '</a>');
            row.push(pvsensor.発電所名);
            row.push(pvsensor.営業所);
            row.push(pvsensor.メーカー);
            row.push(pvsensor.機種名);
            row.push(pvsensor.プラン);
            ref = header.slice(6);
            for (j = 0, len1 = ref.length; j < len1; j++) {
              h = ref[j];
              row.push(list[h]);
            }
            style = '';
            if ((list.電力量低下 != null) && list.偏差値 < 42.5) {
              style = 'danger';
            } else if (list.電力量低下 != null) {
              style = 'success';
            }
            $('#list').append('<tr class=' + style + '><td>' + row.join('</td><td>') + '</td></tr>');
          }
        }
        return true;
      });
    };
  })(this));
});
