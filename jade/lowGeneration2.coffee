$(document).ready ->
    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/detectLowGeneration2/list.json", (data) =>
        $("#myheader").html "<tr><th>" + data[0].join("</th><th>") + "</th></td>"
        for line in data[1...]
            $("#mytable").append '<tr><td>' +
                ((if item? then item else '&nbsp') for item in line).join('</td><td>') +
                '</td></tr>'
        $("tr").each ->
            first = $(this).children("td:first-child").text()
            if first == '警告'
                $(this).addClass("danger")
            else if first == '通知'
                $(this).addClass("success")
