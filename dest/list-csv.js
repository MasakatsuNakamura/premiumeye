$(document).ready(function() {
  var args, lambda;
  args = getUrlVars();
  $('#myheader').html(args.id);
  AWS.config.update({
    accessKeyId: 'AKIAIXDMG63TWB5ODRMQ',
    secretAccessKey: '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'
  });
  AWS.config.region = 'ap-northeast-1';
  lambda = new AWS.Lambda();
  return lambda.invoke({
    FunctionName: 'list-csv',
    Payload: JSON.stringify({
      "id": args.id
    })
  }, function(err, data) {
    var i, json, key, len, ref, results;
    if (err) {
      return console.log(err, err.stack);
    } else {
      json = JSON.parse(data.Payload);
      ref = ((function() {
        var results1;
        results1 = [];
        for (key in json) {
          results1.push(key);
        }
        return results1;
      })()).sort();
      results = [];
      for (i = 0, len = ref.length; i < len; i++) {
        key = ref[i];
        results.push($('#mylist').append('<li><a href="' + json[key] + '">' + key + '</a></li>'));
      }
      return results;
    }
  });
});
