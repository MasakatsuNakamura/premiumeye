$(document).ready ->
    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/5XMRr22UxMU5dlivLoPnpJAvRpJ8wF53/namelist.json", (data) ->
        HEADER = {
            "no":"社員番号",
            "name":"氏名",
            "email":"メールアドレス"
            "shozoku":"所属",
            "kintai":"勤怠管理所属",
            "bumon":"部門",
            "shokushu":"職種",
            "shokui":"職位",
            "indate":"入社日"
        }
        header = title for key, title of HEADER
        $("#myheader").append "<th>" + header.join("</th><th>") + "</th>"
        namelist = (person for number, person of data)
        namelist.sort (a, b) ->
            if (a.kintai + a.shokushu) > (b.kintai + b.shokushu)
                return 1
            else if (a.kintai + a.shokushu) < (b.kintai + b.shokushu)
                return -1
            return 0

        for person in namelist
            row = "<tr>"
            for header of HEADER
                obj = person[header]
                obj = if obj? then obj else '&nbsp'
                row += "<td>" +  obj + "</td>"
            row += "</tr>"
            $("#mytable").append row
