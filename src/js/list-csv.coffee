$(document).ready ->
    args = getUrlVars()
    $('#myheader').html args.id

    AWS.config.update {
        accessKeyId: 'AKIAIXDMG63TWB5ODRMQ',
        secretAccessKey: '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'
    }
    AWS.config.region = 'ap-northeast-1'
    lambda = new AWS.Lambda()

    lambda.invoke {
        FunctionName: 'list-csv',
        Payload: JSON.stringify({"id": args.id})
    }, (err, data) ->
        if err
            console.log(err, err.stack);
        else
            json =JSON.parse(data.Payload)
            $('#myheader').html '<a href="' + json.info.URL + '" target="_blank">' + args.id +
                '</a> (' + json.info.営業所 + ' / ' + json.info.発電所名 + '発電所)'
            keys = (key for key of json.data).sort (a, b) ->
                if a > b
                    return -1
                else if a < b
                    return 1
                return 0
            console.log keys
            for key in keys
                $('#mylist').append '<li><a href="' + json.data[key] + '">' + key + '</a></li>'
