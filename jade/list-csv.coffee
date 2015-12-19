$(document).ready(->
    args = getUrlVars()
    $('#myheader').html(args.id)

    AWS.config.update({
        accessKeyId: 'AKIAIXDMG63TWB5ODRMQ',
        secretAccessKey: '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'
    })
    AWS.config.region = 'ap-northeast-1'
    lambda = new AWS.Lambda()

    lambda.invoke({
        FunctionName: 'list-csv',
        Payload: JSON.stringify({"id": args.id})
    }, (err, data) ->
        if err
            console.log(err, err.stack);
        else
            json =JSON.parse(data.Payload)
            for key in (key for key of json).sort()
                $('#mylist').append('<li><a href="' + json[key] + '">' + key + '</a></li>')
    )
)
