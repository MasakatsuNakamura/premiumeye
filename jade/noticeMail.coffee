$(document).ready ->
    header = ['日時', '所属', '氏名', 'メッセージ']
    for name in header
        $('#myheader').append '<th>' + name + '</th>'

    args = getUrlVars()
    if Object.keys(args).length == 3
        date = new Date args['year'], args['month'] - 1, args['day']
    else
        date = new Date

    year = date.getFullYear()
    month = date.getMonth() + 1
    month = ("0" + month)[-2...]
    mydate = date.getDate()
    mydate = ("0" + mydate)[-2...]
    strDate = year + "/" + month + "/" + mydate
    $('#mydate').text ' ' + strDate + ' '

    yesterday = new Date
    yesterday.setTime date.getTime() - 86400000
    $('#yesterday').attr "href", "?year=" + yesterday.getFullYear() + "&month=" + (yesterday.getMonth() + 1) + "&day=" + yesterday.getDate()

    tommorow = new Date
    tommorow.setTime date.getTime() + 86400000
    $('#tommorow').attr "href", "?year=" + tommorow.getFullYear() + "&month=" + (tommorow.getMonth() + 1) + "&day=" + tommorow.getDate()

    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/administrators.json", (admin) =>
        admins = {}
        for person in admin
            admins[person['メールアドレス']] = person
        $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/noticeMail/" + strDate + ".json", (json) =>
            json.sort (a, b) ->
                a.date - b.date

            for mail in json
                if !(mail.recipient)?
                    continue
                myadmin = admins[mail.recipient]
                if !(myadmin)?
                    continue
                line = '<tr>'
                line += '<td>' + mail.date + '</td>'
                line += '<td style="text-align:left">' + myadmin.所属 + '</td>'
                line += '<td style="text-align:left"><a href="mailto:' + mail.recipient + '" target="_blank">' + myadmin.name + '</td>'
                line += '<td style="text-align:left"><a href="' + mail.url + '" target="_blank">' + mail.subject + '</a></td>'
                $('#list').append line
