$(document).ready(function() {
  return $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/" + "fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/detectLowGeneration2/list.json", (function(_this) {
    return function(data) {
      var i, item, len, line, ref;
      $("#myheader").html("<tr><th>" + data[0].join("</th><th>") + "</th></td>");
      ref = data.slice(1);
      for (i = 0, len = ref.length; i < len; i++) {
        line = ref[i];
        $("#mytable").append('<tr><td>' + ((function() {
          var j, len1, results;
          results = [];
          for (j = 0, len1 = line.length; j < len1; j++) {
            item = line[j];
            results.push(item != null ? item : '&nbsp');
          }
          return results;
        })()).join('</td><td>') + '</td></tr>');
      }
      return $("tr").each(function() {
        var first;
        first = $(this).children("td:first-child").text();
        if (first === '警告') {
          return $(this).addClass("danger");
        } else if (first === '通知') {
          return $(this).addClass("success");
        }
      });
    };
  })(this));
});
