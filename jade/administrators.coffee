$(document).ready(->
    $.getJSON("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/administrators.json", (data)->
        HEADER = ["社員番号", "姓", "名", "メールアドレス", "ユーザータイプ",
            "職種", "所属", "最終ログイン日時"]
        for header in HEADER
            $("#myheader").append("<th>" + header + "</th>")
        data.sort((val1, val2)->
            val1 = if val1['所属']? then val1['所属'] else '[0]' + val1['ユーザータイプ']
            val2 = if val2['所属']? then val2['所属'] else '[0]' + val2['ユーザータイプ']
            if val1 < val2
                return -1
            else if val1 > val2
                return 1
            else
                return 0
        )
        for person in data
            cls = if (person['ミスマッチ'])? then ' class="danger"' else ''
            row = "<tr" + cls + ">";
            for header in HEADER
                obj = person[header]
                obj = if obj? then obj else '&nbsp'
                row += "<td>" +  obj + "</td>";
            row += "</tr>";
            $("#mytable").append(row);
    )
)