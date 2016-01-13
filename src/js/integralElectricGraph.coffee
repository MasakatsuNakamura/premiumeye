    getDateyyyymmdd = (date) ->
      return (date.getFullYear() + "-" + ('0' + (date.getMonth() + 1)).slice(-2) + "-" + ('0' + date.getDate()).slice(-2))

    $(document).ready ->
      'use strict'
      args = getUrlVars()

      $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (pvsensors) ->
        draw = (file_path, option) ->
          #console.log(file_path)
          #console.log(typeof option)
          $.ajax
              url: file_path,
              success: (data) ->
                csvArray = createArray(data)
                #console.log(csvArray[0].length)
                chart_data =
                  bindto: '#chart',
                  data:
                      x:'x',
                      xFormat: '%H:%M',
                      columns: [
                        #['x', '08:21', '08:22', '08:23', '08:24', '08:25', '08:26'],
                        #['data1', 30, 200, 100, 400, 150, 250],
                        #['data2', 130, 340, 200, 500, 250, 350]
                      ]
                      #type: 'bar'

                  axis:
                      x:
                          type: 'timeseries',
                          tick:
                              format: '%H:%M'


                #console.log(csvArray.length)
                #console.log(csvArray[0].length)

                chart_data.data.columns = new Array()
                graph_count = 0

                #グラフ先頭データ設定
                for i in [0..(csvArray[0].length-1)] by 1
                  chart_data.data.columns[i] = new Array()
                  if i == 0
                    chart_data.data.columns[i][graph_count] = 'x'
                  else
                    chart_data.data.columns[i][graph_count] = 'pcs' + String(i-1)
                graph_count++

                #初回の点は発電量0の点を打つべし
                startDate = new Date(csvArray[1][0])
                #console.log(startDate)
                startDate.setMinutes(startDate.getMinutes()-1)
                #console.log(start_time)
                start_time = getDatehhmm(startDate)

                chart_data.data.columns[0][graph_count] = start_time

                for i in [1...csvArray[0].length] by 1
                    chart_data.data.columns[i][graph_count] = String(parseFloat('0'))

                graph_count++

                #初期化
                genkw_total = new Array()
                for i in [0...csvArray[0].length] by 1
                  genkw_total[i] = parseFloat('0')

                if option == 1
                  #console.log(csvArray.length);
                  for i in [1...csvArray.length] by 1
                    chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                    #console.log(i);
                    #console.log(chart_data.data.columns[0][graph_count]);
                    for j in [1...csvArray[0].length] by 1
                        chart_data.data.columns[j][graph_count] = csvArray[i][j]
                    graph_count++
                else if option == 2
                  for i in [1...csvArray.length] by 1
                    minute_1digit = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+5, (csvArray[i][0].length-3)))
                    if minute_1digit == 0
                      chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                      for j in [1...csvArray[0].length] by 1
                          chart_data.data.columns[j][graph_count] = String(genkw_total[j])
                      for j in [0...csvArray[0].length] by 1
                        genkw_total[j] = parseFloat('0')
                      graph_count++

                    for j in [0...csvArray[0].length] by 1
                        genkw_total[j] += parseFloat(csvArray[i][j])
                else
                  for i in [1...csvArray.length] by 1
                    minute_2digit = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+4, (csvArray[i][0].length-3)))
                    if minute_2digit == 0
                      chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                      for j in[1...csvArray[0].length] by 1
                          chart_data.data.columns[j][graph_count] = String(genkw_total[j])
                      for j in [0...csvArray[0].length] by 1
                        genkw_total[j] = parseFloat('0')
                      graph_count++

                    for j in [1...csvArray[0].length] by 1
                      genkw_total[j] += parseFloat(csvArray[i][j])

                endDate = new Date(csvArray[csvArray.length-1][0])
                #console.log(startDate)
                endDate.setMinutes(endDate.getMinutes()+1)
                end_time = getDatehhmm(endDate)
                #console.log(endDate)

                chart_data.data.columns[0][graph_count] = end_time

                for j in[1...csvArray[0].length] by 1
                  chart_data.data.columns[j][graph_count] = String(parseFloat('0'))

                graph_count++

                #console.log(chart_data.data.columns)
                #console.log(chart_data.data)
                c3.generate(chart_data)
              error: (error) ->
                alert('データが無いようです。')

        drawDisplay = (id, date, option) ->
          #console.log(option)
          #console.log(id)
          if pvsensors[id] is undefined
            alert('存在しないidのようです。')
            return
          draw(getFilePath(id, date), parseInt(option))

        $("#search-btn").click ->
          drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

        $("#mydate").on "dp.change", (e) ->
          date = new Date(e.date)
          drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

        $('#mode input[type=radio]').change ->
          drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

        createArray = (csvData) ->
            tempArray = csvData.split("\n")
            csvArray = new Array()
            #最後に何故か常にごみデータ（ブランクデータ）が入るらしい
            for i in [0...(tempArray.length-1)] by 1
              csvArray[i] = tempArray[i].split(",")
              #console.log(i)
            　#console.log(csvArray[0])
            　#console.log(csvArray[0].length)
            return (csvArray)

        getTargetFileName = (id, date) ->
          return (id + "-" + getDateyyyymmdd(date) + ".csv")

        getFilePath = (id, date) ->
          return ("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs/" + id + "/" + getTargetFileName(id, date))

        getDatehhmm = (date) ->
          return (('0' + date.getHours()).slice(-2) + ":" + ('0' + date.getMinutes()).slice(-2))

        if Object.keys(args).length > 0
          #console.log(args)
          #console.log(args.csv)
          serialid = args.csv.substring(0, args.csv.indexOf("-"))
          date_temp = args.csv.substring(args.csv.indexOf("-")+1, args.csv.length)
          date_temp = date_temp.replace(/.csv/g,"")
          #console.log(serialid)
          #console.log(date_temp)
          $("#mydate").val(date_temp)
          date = new Date(date_temp)
          $('#search').val(serialid)
          $("#mydate").datetimepicker(locale: 'ja', format : 'YYYY-MM-DD').val(getDateyyyymmdd(date))
          drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())
        else
          date = new Date()
          #一日前の日付に設定する
          date.setDate(date.getDate() - 1)
          $("#mydate").datetimepicker(locale: 'ja', format : 'YYYY-MM-DD').val(getDateyyyymmdd(date))
