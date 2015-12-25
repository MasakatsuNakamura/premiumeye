$(document).ready(function() {
  return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/administrators.json", function(data) {
    var HEADER, cls, header, i, j, len, len1, obj, person, results, row;
    HEADER = ["社員番号", "姓", "名", "メールアドレス", "ユーザータイプ", "職種", "所属", "最終ログイン日時"];
    $("#myheader").append("<th>" + HEADER.join('</th><th>') + "</th>");
    data.sort(function(a, b) {
      a = a.所属 != null ? a.所属 : '[0]' + a.ユーザータイプ;
      b = b.所属 != null ? b.所属 : '[0]' + b.ユーザータイプ;
      if (a < b) {
        return -1;
      } else if (a > b) {
        return 1;
      }
      return 0;
    });
    results = [];
    for (i = 0, len = data.length; i < len; i++) {
      person = data[i];
      row = [];
      for (j = 0, len1 = HEADER.length; j < len1; j++) {
        header = HEADER[j];
        obj = person[header];
        row.push(obj != null ? obj : '&nbsp');
      }
      cls = person.ミスマッチ != null ? ' class="danger"' : '';
      results.push($("#mytable").append('<tr' + cls + '><td>' + row.join('</td><td>') + '</td></tr>'));
    }
    return results;
  });
});
