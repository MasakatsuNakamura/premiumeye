$(document).ready ->
    args = getUrlVars()
    $('#myheader').html args.id

    AWS.config.update {
        accessKeyId: 'AKIAJHJ63VLJOLLLWKDA',
        secretAccessKey: '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'
    }
    AWS.config.region = 'ap-northeast-1'
    s3 = new AWS.S3()

    s3.listObjects { Bucket: 'pvdata-storage-production', Prefix: 'data/' }, (err, data) ->
        if err
            console.log err, err.stack
        else
            console.log data
            for object in data.Contents
                $('#mylist').append "<li>#{object.Key}</li>"
