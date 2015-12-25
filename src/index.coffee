$(document).ready ->
    args = getUrlVars()
    if args.search?
        console.log(args)
        $('#search').val(args.search)
    if 'sortby' in args
        $('#sortby').val(args.sortby)
    else
        $('#sortby').val('serialid')

    header = [
        "serialid", "発電所名", "顧客名", "プラン", "営業所", "パワコン台数", "ステータス",
        "メーカー", "機種名", "プログラムバージョン", "センサー向き", "パワコン情報"
    ]

    $('#myheader').append "<th>" + header.join('</th><th>') + "</th>"
    size = 20

    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (json) =>

        search = $("#search").val()
        searches = search.split(/ or /)
        if searches.length == 0
            searches[0] = search
        for mysearch of searches
            searches[mysearch] = '^(?=.*' + searches[mysearch].split(/\s+/).join(')(?=.*') + ')'
        re = new RegExp(searches.join('|'), "i")

        num = 0
        data = []
        for id, items of json
            myitems = {}
            for key in header
                myitems[key] = if items[key]? then items[key] else '&nbsp'
            line = []
            for key, value of myitems
                line.push (value + '').replace("\n", " ")
            if !items.テスト && (search == '' || line.join(',').match(re))
                data.push myitems
                num++

        if $('#sortby').val() != ''
            data.sort (a, b) ->
                a = a[$('#sortby').val()]
                b = b[$('#sortby').val()]
                if a < b
                    return -1
                else if a > b
                    return 1
                return 0

        pages = parseInt(num / size) + 1
        page = ''
        for i in [0..pages - 1]
            page += '<option value="' + i + '"">' + (i + 1) + ' / ' + pages + '</option>'
        $("#page").html(page)
        $("#page").val(0)

        draw = (size) ->
            p = parseInt $('#page').val()
            tbl = ""
            values = {}
            for cell in header
                values[cell] = {}
            for i in [p * size..(p + 1) * size - 1]
                if i >= num
                    break
                line = data[i]
                tbl += "<tr><td>" + (i + 1) + "</td><td>"
                if line.機種名 == 'SA099T01' && line.ステータス == '稼働中'
                    tbl += "<a href='list-csv.html?id=" + line.serialid + "' class='btn btn-primary'>CSV</a>"
                else
                    tbl += "&nbsp"
                tbl += "</td>"
                for cell in header
                    value = line[cell]
                    if cell == "発電所名"
                        value = '<a href="https://maps.google.co.jp/maps?ll=' +
                            line.緯度 + ',' + line.経度 + '&z=11&q=' + line.緯度 + ',' + line.経度 +
                            '+(' + encodeURI(line.発電所名 + '発電所') + ')&hl=ja&iwloc=A" target="_blank">' +
                            line.発電所名 + '発電所</a>'
                    else if cell == "serialid"
                        value = '<a href="' + line.URL + '" target="_blank">' + line.serialid + '</a>'
                    tbl += "<td>" + (value + '').replace(/\n/g, '<br />') + "</td>"
                    values[cell][line[cell]] = true
                tbl += "</tr>"
            tbl += "</table>"
            $("#list").html tbl

        draw size

        date = new Date
        $("#numbers").text num + " 箇所 (" + date.getFullYear() + "年" + (date.getMonth() + 1) + "月" + date.getDate() + "日 時点)"

        $("#page").change ->
            draw(size)

        $("#search-btn").attr "tabindex", "0"
        $("#search-btn").click ->
            location.href = '?search=' + $('#search').val()
        $("#all-btn").click ->
            location.href = '?search='
        $("#sanix").click ->
            location.href = '?search=' + "SA099T01 V[0-6][0-9A-F]"
        $("#tabuchi").click ->
            location.href = '?search=' + "田淵電機 1\\.0[0-8] or 安川電機 1\\.0[0-5] or SA099T01 1\\.0[0-8] or P73H103RJ 1\\.(0[0-9]|1[01])"
        $("#pana").click ->
            location.href = '?search=' + "SP(SS|SM|US) ,([6-9]|1[0-9]), パワコン 初期化待ち|アクティベート待ち"
        $("#wide").click ->
            location.href = '?search=' + "電力量センサー ,逆,"
        $("input").keydown (e) ->
            if e.keyCode == 13
                location.href = '?search=' + $('#search').val()