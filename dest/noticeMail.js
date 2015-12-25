$(document).ready(function() {
  var args, date, header, i, len, month, mydate, name, strDate, tommorow, year, yesterday;
  header = ['日時', '所属', '氏名', 'メッセージ'];
  for (i = 0, len = header.length; i < len; i++) {
    name = header[i];
    $('#myheader').append('<th>' + name + '</th>');
  }
  args = getUrlVars();
  if (Object.keys(args).length === 3) {
    date = new Date(args['year'], args['month'] - 1, args['day']);
  } else {
    date = new Date;
  }
  year = date.getFullYear();
  month = date.getMonth() + 1;
  month = ("0" + month).slice(-2);
  mydate = date.getDate();
  mydate = ("0" + mydate).slice(-2);
  strDate = year + "/" + month + "/" + mydate;
  $('#mydate').text(' ' + strDate + ' ');
  yesterday = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  yesterday.setDate(yesterday.getDate() - 1);
  $('#yesterday').attr("href", "?year=" + yesterday.getFullYear() + "&month=" + (yesterday.getMonth() + 1) + "&day=" + yesterday.getDate());
  tommorow = new Date(date.getFullYear(), date.getMonth(), date.getDate());
  tommorow.setDate(tommorow.getDate() + 1);
  $('#tommorow').attr("href", "?year=" + tommorow.getFullYear() + "&month=" + (tommorow.getMonth() + 1) + "&day=" + tommorow.getDate());
  return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/administrators.json", (function(_this) {
    return function(admin) {
      var admins, j, len1, person;
      admins = {};
      for (j = 0, len1 = admin.length; j < len1; j++) {
        person = admin[j];
        admins[person['メールアドレス']] = person;
      }
      return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/noticeMail/" + strDate + ".json", function(json) {
        var k, len2, line, mail, myadmin, results;
        json.sort(function(a, b) {
          return a.date - b.date;
        });
        results = [];
        for (k = 0, len2 = json.length; k < len2; k++) {
          mail = json[k];
          if (mail.recipient == null) {
            continue;
          }
          myadmin = admins[mail.recipient];
          if (myadmin == null) {
            continue;
          }
          line = '<tr>';
          line += '<td>' + mail.date + '</td>';
          line += '<td style="text-align:left">' + myadmin.所属 + '</td>';
          line += '<td style="text-align:left"><a href="mailto:' + mail.recipient + '" target="_blank">' + myadmin.name + '</td>';
          line += '<td style="text-align:left"><a href="' + mail.url + '" target="_blank">' + mail.subject + '</a></td>';
          results.push($('#list').append(line));
        }
        return results;
      });
    };
  })(this));
});
