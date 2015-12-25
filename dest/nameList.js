$(document).ready(function() {
  return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/5XMRr22UxMU5dlivLoPnpJAvRpJ8wF53/namelist.json", function(data) {
    var HEADER, header, i, key, len, namelist, number, obj, person, results, row;
    HEADER = {
      "no": "社員番号",
      "name": "氏名",
      "email": "メールアドレス",
      "shozoku": "所属",
      "kintai": "勤怠管理所属",
      "bumon": "部門",
      "shokushu": "職種",
      "shokui": "職位",
      "indate": "入社日"
    };
    for (key in HEADER) {
      header = HEADER[key];
      $("#myheader").append("<th>" + header + "</th>");
    }
    namelist = [];
    for (number in data) {
      person = data[number];
      namelist.push(person);
    }
    namelist.sort(function(a, b) {
      if ((a.kintai + a.shokushu) > (b.kintai + b.shokushu)) {
        return 1;
      } else if ((a.kintai + a.shokushu) < (b.kintai + b.shokushu)) {
        return -1;
      }
      return 0;
    });
    results = [];
    for (i = 0, len = namelist.length; i < len; i++) {
      person = namelist[i];
      row = "<tr>";
      for (header in HEADER) {
        obj = person[header];
        obj = obj != null ? obj : '&nbsp';
        row += "<td>" + obj + "</td>";
      }
      row += "</tr>";
      results.push($("#mytable").append(row));
    }
    return results;
  });
});
