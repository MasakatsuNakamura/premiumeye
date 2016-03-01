$(document).ready ->
    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/" +
            "fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/detectLowGeneration2/list.json", (data) =>
        $("#myheader").html "<tr><th>番号</th><th>" + data[0][...-1].join("</th><th>") + "</th></td>"
        for i, line of data[1...]
            line.unshift("<a href='integralElectricGraph.html?id=#{line[8]}' class='btn btn-default'>#{parseInt(i) + 1}</a>")
            line[9] = "<a href='#{line[14]}' target='_blank'>#{line[9]}"
            line = line[...-1]
            $("#mytable").append '<tr><td>' +
                ((if item? then item else '&nbsp') for i, item of line).join('</td><td>') +
                '</td></tr>'
        $("tr").each ->
            first = $(this).children("td:first-child").text()
            if first.match(/警告/)
                $(this).addClass("danger")
            else if first.match(/通知/)
                $(this).addClass("success")
            if first.match(/^\*/)
                $(this).css({"font-weight":"bold"})
                $(this).children("td:first-child").text(first[1...])
