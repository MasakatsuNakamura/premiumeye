$(document).ready ->
    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/administrators.json", (data)->
        HEADER = [
            "社員番号", "姓", "名", "メールアドレス", "ユーザータイプ",
            "職種", "所属", "最終ログイン日時"
        ]

        $("#myheader").append "<th>" + HEADER.join('</th><th>') + "</th>"

        data.sort (a, b) ->
            a = if (a.所属)? then a.所属 else '[0]' + a.ユーザータイプ
            b = if (b.所属)? then b.所属 else '[0]' + b.ユーザータイプ
            if a < b
                return -1
            else if a > b
                return 1
            return 0

        for person in data
            row = []
            for header in HEADER
                obj = person[header]
                row.push if obj? then obj else '&nbsp'

            cls = if (person.ミスマッチ)? then ' class="danger"' else ''
            $("#mytable").append '<tr' + cls + '><td>' + row.join('</td><td>') + '</td></tr>'
