$(document).ready ->
    args = getUrlVars()
    if Object.keys(args).length == 3
        date = new Date args.year, args.month - 1, args.day
    else
        date = new Date
        date.setDate date.getDate() - 1

    yesterday = new Date date.getFullYear(), date.getMonth(), date.getDate()
    yesterday.setDate yesterday.getDate() - 1
    $('#yesterday').attr "href", "?year=#{yesterday.getFullYear()}&month=#{yesterday.getMonth() + 1}&day=#{yesterday.getDate()}"

    tommorow = new Date date.getFullYear(), date.getMonth(), date.getDate()
    tommorow.setDate tommorow.getDate() + 1
    $('#tommorow').attr "href", "?year=#{tommorow.getFullYear()}&month=#{tommorow.getMonth() + 1}&day=#{tommorow.getDate()}"

    strDate = "#{date.getFullYear()}/#{date.getMonth() + 1}/#{date.getDate()}"
    $('#mydate').html "&nbsp#{strDate}&nbsp"

    $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/abnormalGeneration/" + strDate + ".json", (json) ->
        $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (pvsensors) =>
            header = ['パワコン番号', '積算電力', '前回積算電力', '差分', '日時', '前回日時', '変化係数']
            res = ''
            keys = (key for key of json).sort (a, b) ->
                if a > b then 1 else if a < b then -1 else 0
            for id, num in keys
                list = json[id].Series
                res += """
                    <div class="panel panel-default">
                        <div class="panel-heading">
                            <h4 class="panel-title">
                                <a data-toggle="collapse" data-parent="#accordion" href="#collapse#{num}">
                                    #{id}(#{list.length}件):#{json[id].発電所名}発電所(#{json[id].営業所})
                                    #{json[id].メーカー}:#{json[id].機種名}(ファームバージョン:#{json[id].プログラムバージョン})</a></p>
                                </a>
                            </h4>
                        </div>
                    <div id="collapse#{num}" class="panel-collapse collapse">
                    <div class="panel-body">
                    <table class="table"><thead><th>&nbsp</th>
                """
                for item in header
                    res += "<th style='padding:8px 15px'>#{item}</th>"
                res += "</tr></thead><tbody>"
                for line in list
                    res += """
                        <tr>
                            <td>
                                <a style='padding:0' href='#{pvsensors[id].URL.replace(/\/pv_sensor/, "/rawdata")}' target='_blank'>開く</a>
                            </td>
                    """
                    for item in header
                        res += "<td>#{line[item]}</td>"
                    res += "</tr>"
                res += "</tbody></table></div></div></div>"
            $('#accordion').html res
