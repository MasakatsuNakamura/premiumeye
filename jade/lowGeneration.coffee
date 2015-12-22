$(document).ready ->
    args = getUrlVars()
    if Object.keys(args).length == 3
        date = new Date args.year, args.month - 1, args.day
    else
        date = new Date
        date.setDate date.getDate() - 1
    yesterday = new Date date.getFullYear(), date.getMonth(), date.getDate()
    yesterday.setDate yesterday.getDate() - 1
    $('#yesterday').attr "href", "?year=" + yesterday.getFullYear() + "&month=" + (yesterday.getMonth() + 1) + "&day=" + yesterday.getDate()
    $('#yesterday').text "前日"

    tommorow = new Date date.getFullYear(), date.getMonth(), date.getDate()
    tommorow.setDate tommorow.getDate() + 1
    $('#tommorow').attr "href", "?year=" + tommorow.getFullYear() + "&month=" + (tommorow.getMonth() + 1) + "&day=" + tommorow.getDate()
    $('#tommorow').text "翌日"

    strDate = date.getFullYear() + "/" + (date.getMonth() + 1) + "/" + date.getDate()
    $('#mydate').html '&nbsp;' + strDate + '&nbsp;'

    lowgen = ''
    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/detectLowGeneration/" +
        strDate + ".json", (lowgen) =>
            @lowgen = lowgen
        $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (pvsensors) =>
            header = ['シリアル番号', '発電所名', '営業所', 'メーカー', '機種', 'プラン', '発電力量', '定格出力', '偏差値', '周辺順位', '周辺発電所数']
            for item in header
                $('#myheader').append "<th>" + item + "</th>"

            gendata = []
            for key, value of @lowgen
                value.id = key
                gendata.push value

            gendata.sort (a, b) ->
                a.偏差値 - b.偏差値

            res = ''
            for list in gendata
                id = list.id
                if !(pvsensors[id])?
                    continue
                pvsensor = pvsensors[id]
                list.偏差値 = Math.round(list.偏差値 * 10)/ 10;
                list.発電力量 = Math.round(list.発電力量 * 100)/ 100;
                list.定格出力 = Math.round(list.定格出力 * 10)/ 10;
                if list.偏差値 < 42 || list.電力量低下
                    style = '';
                    if (list.電力量低下)? && list.偏差値 < 42.5
                        style = 'danger'
                    else if (list.電力量低下)?
                        style = 'success'
                    res += '<tr class=' + style + '>' +
                        '<td><a href=' + pvsensor.URL + ' target="_blank">' + id + '</a></td>' +
                        '<td>' + pvsensor.発電所名 + '発電所</td>' +
                        '<td>' + pvsensor.営業所+ '</td>' +
                        '<td>' + pvsensor.メーカー + '</td>' +
                        '<td>' + pvsensor.機種名 + '</td>' +
                        '<td>' + pvsensor.プラン + '</td>'
                    for h in header[6..]
                        res += '<td>' + list[h] + '</td>'
                    res += '</tr>\n'
            $('#list').html res
