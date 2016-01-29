$(document).ready ->
    draw = ->
        $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/5XMRr22UxMU5dlivLoPnpJAvRpJ8wF53/namelist.json", (data) ->
            args = getUrlVars()
            $("#search").val(args.search)
            HEADER = {
                "no":"社員番号",
                "name":"氏名",
                "shokui":"職位",
                "email":"メールアドレス"
                "shozoku":"所属",
                "kintai":"勤怠管理所属",
                "bumon":"部門",
                "shokushu":"職種",
                "indate":"入社日"
            }
            header = (title for key, title of HEADER)
            $("#myheader").append "<th>" + header.join("</th><th>") + "</th>"
            namelist = (person for number, person of data)
            namelist.sort (a, b) ->
                SHOKUI = {
                    "社長": 1,
                    "副社長": 2,
                    "常務": 3,
                    "取締役": 4,
                    "執行役": 5,
                    "監査役": 6,
                    "幹部候": 7,
                    "部長": 8,
                    "所長": 9,
                    "工場長": 10,
                    "室長": 11,
                    "顧問": 12,
                    "次長" :13,
                    "支店長": 14,
                    "課長": 15,
                    "係長": 16,
                    "班長": 17,
                    "主任": 18,
                    "主事": 19,
                    "副主任": 20,
                    "一般": 21,
                    "パート": 22
                }
                if (a.kintai + a.bumon) > (b.kintai + b.bumon)
                    return 1
                else if (a.kintai + a.bumon) < (b.kintai + b.bumon)
                    return -1
                return SHOKUI[a.shokui] * 100000 + parseInt(a.no) - SHOKUI[b.shokui] * 100000 - parseInt(b.no)

            for person in namelist
                line = (value for key, value of person).join(".")
                if args.search == '' or line.match(args.search)
                    row = "<tr>"
                    for header of HEADER
                        obj = person[header]
                        obj = if obj? then obj else '&nbsp'
                        row += "<td>" +  obj + "</td>"
                    row += "</tr>"
                    $("#mytable").append row

    draw()
    $("#search-btn").attr "tabindex", "0"
    $("#search-btn").click ->
        location.href = '?search=' + $('#search').val()
    $("input").keydown (e) ->
        if e.keyCode == 13
            location.href = '?search=' + $('#search').val()
