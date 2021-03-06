# isFacebookCertification = false
# isDisplayStart = false

# checkLoginState = ->
#   FB.getLoginStatus (response) ->
#     statusChangeCallback response
#
# # This function is called when someone finishes with the Login
# # Button.  See the onlogin handler attached to it in the sample
# # code below.
# statusChangeCallback = (response) ->
#   console.log 'statusChangeCallback'
#   console.log response
#   # The response object is returned with a status field that lets the
#   # app know the current login status of the person.
#   # Full docs on the response object can be found in the documentation
#   # for FB.getLoginStatus().
#   if response.status == 'connected'
#     # Logged into your app and Facebook.
#     testAPI()
#     AWS.config.region = 'ap-northeast-1'
#     AWS.config.credentials = new (AWS.CognitoIdentityCredentials)(
#       AccountId: '882219098944'
#       IdentityPoolId: 'ap-northeast-1:663975fc-ae6c-4ca4-9575-57e59d4e6f4e'
#       RoleArn: 'arn:aws:iam::882219098944:role/Cognito_test_restraint_data_uploadAuth_Role'
#       Logins:
#         'graph.facebook.com': response.authResponse.accessToken)
#
#     console.log 'FB ID: ' + response.authResponse.userID
#
#     AWS.config.credentials.get (err) ->
#       if !err
#         console.log 'Cognito Identity id:' + AWS.config.credentials.identityId
#         isFacebookCertification = true
#       else
#         console.log err
#       $('#facebook-login-confirmation').trigger("click")
#   else if response.status == 'not_authorized'
#     # The person is logged into Facebook, but not your app.
#     # document.getElementById('status').innerHTML = 'Please log ' + 'into this app.'
#     $('#facebook-login-confirmation').trigger("click")
#   else
#     # The person is not logged into Facebook, so we're not sure if
#     # they are logged into this app or not.
#     # document.getElementById('status').innerHTML = 'Please log ' + 'into Facebook.'
#     $('#facebook-login-confirmation').trigger("click")
#
# # Here we run a very simple test of the Graph API after login is
# # successful.  See statusChangeCallback() for when this call is made.
# testAPI = ->
#   console.log 'Welcome!  Fetching your information.... '
#   FB.api '/me', (response) ->
#     console.log 'Successful login for: ' + response.name
#     document.getElementById('status').innerHTML = 'Thanks for logging in, ' + response.name + '!'
#
# window.fbAsyncInit = ->
#   FB.init
#     appId: '1741978699356923'
#     cookie: true
#     xfbml: true
#     version: 'v2.2'
#   # Now that we've initialized the JavaScript SDK, we call
#   # FB.getLoginStatus().  This function gets the state of the
#   # person visiting this page and can return one of three states to
#   # the callback you provide.  They can be:
#   # 1. Logged into your app ('connected')
#   # 2. Logged into Facebook, but not your app ('not_authorized')
#   # 3. Not logged into Facebook and can't tell if they are logged into
#   #    your app or not.
#   #
#   # These three cases are handled in the callback function.
#   checkLoginState()
#
# # Load the SDK asynchronously
# ((d, s, id) ->
#   js = undefined
#   fjs = d.getElementsByTagName(s)[0]
#   if d.getElementById(id)
#     return
#   js = d.createElement(s)
#   js.id = id
#   js.src = '//connect.facebook.net/ja_jp/sdk.js'
#   fjs.parentNode.insertBefore js, fjs
# ) document, 'script', 'facebook-jssdk'

$(document).ready ->
  $('.myhide').hide()

  args = getUrlVars()
  date = new Date()
  isGraphDataGetFirst = false
  isCertification = false

  $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (pvsensors) ->
    console.log('getJSON')

    getDateyyyymmdd = (date) ->
      return (date.getFullYear() + "-" + ('0' + (date.getMonth() + 1)).slice(-2) + "-" + ('0' + date.getDate()).slice(-2))

    getRestraintTargetFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + "_errorflag.csv")

    onClick = (e) ->
      $('#outputRestriantcsvdownload').html("")
      console.log(e.data.value)
      pageindx = e.data.pageindx
      if e.data.value == 0
        console.log('<<押下')
        if e.data.pageindx != 0
          pageindx -= 1
      else if e.data.value == e.data.pageNum+1
        console.log('>>押下')
        if e.data.pageindx+1 != e.data.pageNum
          pageindx += 1
      else
        pageindx = e.data.value-1

      console.log('pageindx:' + pageindx)

      dispOutputRestriantTable(e.data.id, e.data.date, e.data.pcs_num, e.data.pageNum, pageindx, e.data.restriant_data, e.data.color_tbl, e.data.restriant_disp_pcsnum, e.data.Restriant_pcs_totaltime)

    dispOutputRestriantTable = (id, date, pcs_num, pageNum, pageindx, restriant_data, color_tbl, restriant_disp_pcsnum, Restriant_pcs_totaltime) ->
      colums = Math.floor(12/restriant_disp_pcsnum)
      OutputRestriantTbl = ''
      start_pcsid = (pageindx*restriant_disp_pcsnum)
      if pageindx+1 == pageNum
        end_pcsnum = pcs_num
      else
        end_pcsnum = (restriant_disp_pcsnum*pageindx) + restriant_disp_pcsnum

      # console.log('start_pcsid:' + start_pcsid)
      # console.log('end_pcsnum:' + end_pcsnum)

      for i in [start_pcsid...end_pcsnum]
        OutputRestriantTbl += """
              <div class="col-xs-#{colums}" style="background-color:#{color_tbl[i]}">
                pcs#{i}&nbsp;&nbsp;&nbsp;&nbsp;抑制時間合計:&nbsp;&nbsp;&nbsp;&nbsp;#{Restriant_pcs_totaltime[i]}
                #{restriant_data[i]}
              </div>
        """
      res = """
        <div class="container-fluid">
          <div class="row">
            #{OutputRestriantTbl}
          </div>
        </div>
      """
      $('#outputRestriant').html(res)
      $('#outputRestriantPager').html('<p class="control-label">[抑制履歴情報]</p>')
      if pageNum != 1
        pagingdispdata = ''
        pagingTbl = ''

        # 先頭ページ表示の場合
        tbl = "<button class='btn btn-default'>&laquo</button>"
        pagingTbl += tbl
        pagingTbl += '\n'

        for i in [1..pageNum]
          if i == pageindx+1
              tbl = "<button class='btn btn-primary'>#{i}</button>"
          else
              tbl = "<button class='btn btn-default'>#{i}</button>"
          pagingTbl += tbl
          pagingTbl += '\n'

        tbl = "<button class='btn btn-default'>&raquo</button>"
        pagingTbl += tbl
        pagingTbl += '\n'

        $('#outputRestriantPager').append(pagingTbl)

        i = 0
        while i < (pageNum+2)
          param = {
            value: i,
            id: id,
            date: date,
            pcs_num: pcs_num,
            pageNum: pageNum,
            pageindx: pageindx,
            restriant_data: restriant_data,
            color_tbl: color_tbl,
            restriant_disp_pcsnum: restriant_disp_pcsnum,
            Restriant_pcs_totaltime: Restriant_pcs_totaltime
          }
          # console.log(param.value)
          $('#outputRestriantPager button').eq(i).on 'click', param, onClick
          i++

      $('#outputRestriantPager').append("<a href='https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs_restraint/#{id}/#{getRestraintTargetFileName(id, date)}' class='btn btn-primary'>抑制履歴csvダウンロード</a>")

    makeOutputRestriantTable = (id, date, pcs_num, outRestraint) ->
      color_tbl = ['aqua', 'orange', 'red', 'lime', 'mediumSlateBlue', 'brown', 'pink', 'gray', 'orangeRed', 'cyan', 'green', 'yellowGreen', 'yellow', 'blue', 'purple', 'brown', 'pink', 'gray', 'bitter orange', 'light blue']
      restriant_disp_pcsnum = 4
      # colums = Math.floor(12/pcs_num)
      pageNum = Math.floor(pcs_num/restriant_disp_pcsnum)
      if (pcs_num%restriant_disp_pcsnum) != 0
        pageNum += 1

      # console.log('pageNum:'+pageNum)
      csvOutputRestriantArray = createArray(outRestraint)
      Restriant_data = new Array()
      for i in [0...pcs_num]
        Restriant_data[i] = ""

      pcs_count = 0
      Restriant_pcs_totaltime = new Array()
      for i in [(csvOutputRestriantArray.length-pcs_num)...csvOutputRestriantArray.length]
        Restriant_pcs_totaltime[pcs_count] = csvOutputRestriantArray[i][2]
        pcs_count++

      console.log(csvOutputRestriantArray.length)
      for i in [1...(csvOutputRestriantArray.length-pcs_num)]
        pcs_id = parseInt(csvOutputRestriantArray[i][0])
        # console.log(String(pcs_id%pcs_num))
        Restriant_data[pcs_id] += """
              <div class="row">
                <div class="col-xs-4" style="background-color:#{color_tbl[pcs_id]}">#{csvOutputRestriantArray[i][1]}</div>
                <div class="col-xs-4" style="background-color:#{color_tbl[pcs_id]}">#{csvOutputRestriantArray[i][2]}</div>
                <div class="col-xs-4" style="background-color:#{color_tbl[pcs_id]}">#{csvOutputRestriantArray[i][3]}</div>
              </div>
        """
      dispOutputRestriantTable(id, date, pcs_num, pageNum, 0, Restriant_data, color_tbl, restriant_disp_pcsnum, Restriant_pcs_totaltime)

      # #ページ番号のボタンをli要素に入れ込む
      # spans = $('.pagination').find('.pageNum')
      # i = 0
      # while i < spans.length
      #   $(spans[i]).wrap '<li></li>'
      #   i++
      # #現在のページ番号を青く塗りつぶす
      # $('.current').parent('li').addClass 'active'
      # #CakePHPで「disabled」クラスがついていたら、Bootstrapのliにも付ける
      # $('.disabled').parent('li').addClass 'disabled'

# ---
# generated by js2coffee 2.1.0
    # showCertificationButton = ->
    #   $('#GoogleBtn').show()
    #   $('#AnonymityBtn').show()
    #   $('#FacebookBtn').show()
    #   console.log '認証ボタン表示'

    # hideCertificationButton = ->
    #   $('#GoogleBtn').hide()
    #   $('#AnonymityBtn').hide()
    #   $('#FacebookBtn').hide()

    draw = (id, date, option) ->
      $.ajax
          url: getFilePath(id, date),
          success: (data) ->
            csvArray = createArray(data)
            pcs_num = csvArray[0].length-1

            if csvArray.length < 2
              $('#graph_area').html("<p>csvファイル内にデータがありません</p>")
              return

            $.ajax
              url: getOutputRestriantFilePath(id, date)
              beforeSend : (xhr) ->
                  xhr.overrideMimeType("text/plain; charset=shift_jis")
              success: (outRestraint) ->
                makeOutputRestriantTable(id, date, pcs_num, outRestraint)
                console.log("出力抑制ファイル取得成功")
              error: (error) ->
                $('#createRestriant').show()

            chart_data =
              bindto: '#graph_area',
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
              color:
                  pattern: ['Aqua', 'Orange', 'Red', 'Lime', 'MediumSlateBlue', 'Brown', 'Pink', 'Gray', 'OrangeRed', 'Cyan', 'Green', 'YellowGreen', 'Yellow', 'Blue', 'Purple', 'Brown', 'Pink', 'Gray', 'Bitter orange', 'Light blue']

            chart_data.data.columns = new Array()
            graph_count = 0

            # グラフ先頭データ設定
            for i in [0..pcs_num]
              chart_data.data.columns[i] = new Array()
              if i == 0
                chart_data.data.columns[i][graph_count] = 'x'
              else
                chart_data.data.columns[i][graph_count] = 'pcs' + String(i-1)
            graph_count++

            # 初回の点は発電量0の点を打つべし
            startDate = new Date(csvArray[1][0])
            console.log(startDate)
            startDate.setMinutes(startDate.getMinutes()-1)
            start_time = getDatehhmmss(startDate)

            chart_data.data.columns[0][graph_count] = getDatehhmm(startDate)

            for i in [1..pcs_num]
                chart_data.data.columns[i][graph_count] = String(parseFloat('0'))

            graph_count++

            #初期化
            genkw_total = new Array()
            for i in [0...pcs_num]
              genkw_total[i] = parseFloat('0')

            if option == 1
              for i in [1...csvArray.length]
                chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                for j in [1..pcs_num]
                    chart_data.data.columns[j][graph_count] = csvArray[i][j]
                graph_count++

            else if option == 2
              before_time = start_time.substring(0, (start_time.length-4)) + "0:00"
              for i in [1...csvArray.length]
                current_time = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-4)) + "0:00"
                if current_time != before_time
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in [1..pcs_num]
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num]
                    genkw_total[j] = parseFloat('0')
                  graph_count++
                  before_time = current_time

                for j in [1..pcs_num]
                  genkw_total[j-1] += parseFloat(csvArray[i][j])
            else if option == 3
              before_time = start_time.substring(0, (start_time.length-4)) + "0:00"
              before_min = parseInt(start_time.substring(3, (start_time.length-4)))

              for i in [1...csvArray.length]
                current_time = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-4)) + "0:00"
                current_min = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+4, (csvArray[i][0].length-4)))

                diff = current_min - before_min
                if before_min > current_min
                  diff = 6 + current_min - before_min

                if diff > 1
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in [1..pcs_num]
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num]
                    genkw_total[j] = parseFloat('0')
                  graph_count++
                  before_time = current_time
                  before_min = parseInt(before_time.substring(3, (start_time.length-4)))

                for j in [1..pcs_num]
                  genkw_total[j-1] += parseFloat(csvArray[i][j])

            else if option == 4
              before_time = start_time.substring(0, (start_time.length-4)) + "0:00"
              before_min = parseInt(start_time.substring(3, (start_time.length-4)))

              for i in [1...csvArray.length]
                current_time = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-4)) + "0:00"
                current_min = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+4, (csvArray[i][0].length-4)))

                diff = current_min - before_min
                if before_min > current_min
                  diff = 6 + current_min - before_min

                if diff > 2
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in [1..pcs_num]
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num]
                    genkw_total[j] = parseFloat('0')
                  graph_count++
                  before_time = current_time
                  before_min = parseInt(before_time.substring(3, (start_time.length-4)))

                for j in [1..pcs_num]
                  genkw_total[j-1] += parseFloat(csvArray[i][j])
            else
              before_time = start_time.substring(start_time.indexOf(" ")+1, (start_time.length-5)) + "00:00"
              for i in [1...csvArray.length]
                current_time = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-5)))
                if current_time != before_time
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in[1..pcs_num]
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num]
                    genkw_total[j] = parseFloat('0')
                  graph_count++
                  before_time = current_time

                for j in [1..pcs_num]
                  genkw_total[j-1] += parseFloat(csvArray[i][j])

            endDate = new Date(csvArray[csvArray.length-1][0])
            endDate.setMinutes(endDate.getMinutes()+1)

            chart_data.data.columns[0][graph_count] = getDatehhmm(endDate)

            for j in[1..pcs_num]
              chart_data.data.columns[j][graph_count] = String(parseFloat('0'))

            graph_count++

            c3.generate(chart_data)
            $("#csvdownload").attr("href", "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs/#{id}/#{getTargetFileName(id, date)}")
            $('#csvdownload').show()

          error: (error) ->
            # if isCertification == false
            #   showCertificationButton()
            # else
              if isGraphDataGetFirst == false
                $('#createChart').trigger("click");
                isGraphDataGetFirst = true
              else
                $('#graph_area').html("<p>グラフデータを作成できませんでした。</p>")

    clearDisplay = ->
      $('#graph_area').html("")
      $('#csvdownload').hide()
      $('#outputRestriantcsvdownload').html("")
      $('#outputRestriant').html("")
      $('#outputRestriantPager').html("")
      $('#createChart').hide()
      $('#createRestriant').hide()
      # hideCertificationButton()

    drawDisplay = (id, date, option) ->
      clearDisplay()
      # if isDisplayStart == false
      #   console.log("isDisplayStart == false")
      #   $('#status').html("")
      #   return
      draw(id, date, parseInt(option))

    $('#search').change　->
      console.log("#search change")
      id = $('#search').val()
      if pvsensors[id] is undefined
        $('#graph_area').html("<p>存在しないシリアル番号(id)です</p>")
        $("#userheader").html("")
        $("#userdata").html("")
        return
      makeUserInfo(id)
      drawDisplay(id, date, $('#mode input[name="gender"]:checked').val())

    # $('#facebook-login-confirmation').click ->
    #   console.log "$('#facebook-login-confirmation').click"
    #   $('#status').html("")
    #   if isFacebookCertification != false
    #     hideCertificationButton()
    #     isCertification = true
    #   # isDisplayStart = true
    #   drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#mydate').on "dp.change", (e) ->
      date = new Date(e.date)
      isGraphDataGetFirst = false
      drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#mode input[type=radio]').change ->
      isGraphDataGetFirst = false
      drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#yesterday').click ->
      date.setDate date.getDate() - 1
      $('#mydate').val(getDateyyyymmdd(date))
      isGraphDataGetFirst = false
      $('#mydate').data("DateTimePicker").date(date)
      # $.cookie( "sample" , "テスト" , { expires: 7 , path: "/", domain: "sanix-data-analysis.s3-website-ap-northeast-1.amazonaws.com" , secure: false });

    $('#tommorow').click ->
      date.setDate date.getDate() + 1
      $('#mydate').val(getDateyyyymmdd(date))
      isGraphDataGetFirst = false
      $('#mydate').data("DateTimePicker").date(date)
      # $.cookie( "sample" , "テスト" , { expires: 7 , path: "/", domain: "sanix-data-analysis.s3-website-ap-northeast-1.amazonaws.com" , secure: false });

    $('#createChart').click ->
      today = new Date()
      today.setHours(0,0,0,0)
      if today.getTime() <= date.getTime()
        console.log('future day selected')
        $('#graph_area').html("<p>まだグラフデータがサーバー上にありません（未来のデータ）。</p>")
        return

      lambda = new AWS.Lambda()
      $('#graph_area').html("<img src='./gif-load.gif'>")
      # $('#myChartModal').show()
      console.log("$('#myChartModal').show()")
      lambda.invoke {
          FunctionName: 'get-csv'
          Payload: JSON.stringify({"id": $('#search').val(), "date": getDateyyyymmdd(date).replace(/-/g, '/')})
      }, (err, data) ->
          console.log('Lambda invoke end')
          # $('#myChartModal').modal('hide')  #モーダルの場合はこちら
          $('#myChartModal').hide()
          if err
            console.log(err, err.stack)
            $('#graph_area').html("<p>グラフデータを作成できませんでした。</p>")
          else
            console.log(data)
            drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $("#createRestriant").click ->
      lambda = new AWS.Lambda()
      console.log(getDateyyyymmdd(date).replace(/-/g, '/'))
      $('#createRestriant').hide()
      # $('#myModal').show()
      $('#outputRestriant').html("<img src='./gif-load.gif'>")
      lambda.invoke {
          FunctionName: 'create_cvs_restraint_history'
          Payload: JSON.stringify({"id": $('#search').val(), "date": getDateyyyymmdd(date).replace(/-/g, '/')})
      }, (err, data) ->
          if err
            console.log(err, err.stack)
          else
            # $('#myModal').modal('hide')   #モーダルの場合はこちら
            $('#myModal').hide()
            drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#GoogleBtn').click ->
      console.log('google 押下')
      $('#graph_area').html("<p>実は。。google認証はまだサポートできてません。。</p>")

    $('#AnonymityBtn').click ->
      AWS.config.region = 'ap-northeast-1'
      AWS.config.credentials = new (AWS.CognitoIdentityCredentials)(
        AccountId: '882219098944'
        IdentityPoolId: 'ap-northeast-1:663975fc-ae6c-4ca4-9575-57e59d4e6f4e'
        RoleArn: 'arn:aws:iam::882219098944:role/Cognito_test_restraint_data_uploadUnauth_Role')

      AWS.config.credentials.get (err) ->
        if !err
          console.log 'Cognito Identity id:' + AWS.config.credentials.identityId
          isCertification = true
          # hideCertificationButton()
          # drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())
        else
          console.log err

    # progress = (count) ->
    #   setTimeout (->
    #     $('#pgss2').css 'width': count + '%'
    #     count++
    #     if count == 90
    #       return
    #     progress count
    #     return
    #   ), 300

    createArray = (csvData) ->
      csvArray = csvData.split("\n")[..-2].map (l) -> l.split(",")

      # console.log(tempArray)
      console.log(csvArray)
      return (csvArray)

    getTargetFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + ".csv")

    getFilePath = (id, date) ->
      return ("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs/" + id + "/" + getTargetFileName(id, date))

    getDatehhmm = (date) ->
      return (('0' + date.getHours()).slice(-2) + ":" + ('0' + date.getMinutes()).slice(-2))

    getDatehhmmss = (date) ->
      return (getDatehhmm(date) + ":" + ('0' + date.getSeconds()).slice(-2))

    getOutputRestriantFilePath = (id, date) ->
      return ("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs_restraint/" + id + "/" + getOutputRestriantFileName(id, date))

    getOutputRestriantFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + "_errorflag.csv")

    makeUserInfo = (id) ->
      $("#userheader").html("")
      $("#userdata").html("")
      header = [
          "serialid", "発電所名", "顧客名", "プラン", "営業所", "パワコン台数", "ステータス",
          "メーカー", "機種名", "パワコン情報"
      ]

      tbl = '<tr>'
      for cell in header
        tbl += '<th>' + cell + '</th>'
      tbl += '</tr>'
      $("#userheader").append tbl

      tbl =''
      for cell in header
        if cell == "serialid"
          value = "<a href='#{pvsensors[id]["URL"]}' target='_blank'>#{id}</a>"
        else
          value = if pvsensors[id][cell]? then pvsensors[id][cell] else '&nbsp;'

        if cell == "発電所名"
          value = "<a href='https://maps.google.co.jp/maps?ll=#{pvsensors[id]['緯度']},#{pvsensors[id]['経度']}&z=11&q=#{pvsensors[id]['緯度']},#{pvsensors[id]['経度']}" +
                "(#{encodeURI(pvsensors[id][cell] + '発電所')})&hl=ja&iwloc=A' target='_blank'>#{pvsensors[id][cell]}発電所</a>"
        tbl += "<td>#{(value + '').replace(/\n/g, '<br />')}</td>"
      tbl += "</tr>"
      $("#userdata").append tbl

    # authorize = (event) ->
    #   console.log('authorize呼び出し')
    #   # Handles the authorization flow.
    #   # `immediate` should be false when invoked from the button click.
    #   useImmdiate = if event then false else true
    #   authData =
    #     client_id: CLIENT_ID
    #     scope: SCOPES
    #     immediate: useImmdiate
    #   gapi.auth.authorize authData, (response) ->
    #     console.log(response)
    #     # authButton = document.getElementById('GoogleBtn')
    #     # if response.error
    #     #   authButton.hidden = false
    #     # else
    #     #   authButton.hidden = true
    #     if response.error
    #       console.log(response.error)
    #     else
    #       AWS.config.region = 'ap-northeast-1'
    #       cognitoidentity = new (AWS.CognitoIdentity)(apiVersion: '2014-06-30')
    #       params =
    #         IdentityPoolId: 'ap-northeast-1:663975fc-ae6c-4ca4-9575-57e59d4e6f4e'
    #         AccountId: '882219098944'
    #         Logins: 'accounts.google.com': response.access_token
    #       cognitoidentity.getId params, (err, data) ->
    #         if err
    #           console.log err, err.stack
    #         else
    #           console.log data
    #
    #       # queryAccounts()
    #       # AWS.config.region = 'ap-northeast-1'
    #       # AWS.config.credentials = new (AWS.CognitoIdentityCredentials)(
    #       #   AccountId: '882219098944'
    #       #   IdentityPoolId: 'ap-northeast-1:663975fc-ae6c-4ca4-9575-57e59d4e6f4e'
    #       #   RoleArn: 'arn:aws:iam::882219098944:role/Cognito_test_restraint_data_uploadAuth_Role'
    #       #   Logins:
    #       #     'accounts.google.com': response.access_token)
    #       #
    #       # console.log 'GOOGLE ID: ' + response.access_token
    #       #
    #       # AWS.config.credentials.get (err) ->
    #       #   if !err
    #       #     console.log 'Cognito Identity id:' + AWS.config.credentials.identityId
    #       #     isCertification = true
    #       #     $("#GoogleBtn").hide()
    #       #     $('#AnonymityBtn').hide()
    #       #     drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())
    #       #   else
    #       #     console.log err
    #
    # queryAccounts = ->
    #   # Load the Google Analytics client library.
    #   gapi.client.load('analytics', 'v3').then ->
    #     # Get a list of all Google Analytics accounts for this user
    #     gapi.client.analytics.management.accounts.list().then handleAccounts
    #
    # handleAccounts = (response) ->
    #   console.log('handleAccounts')
    #   console.log(response)
    #   # Handles the response from the accounts list method.
    #   if response.result.items and response.result.items.length
    #     # Get the first Google Analytics account.
    #     firstAccountId = response.result.items[0].id
    #     # Query for properties.
    #     queryProperties firstAccountId
    #   else
    #     console.log 'No accounts found for this user.'
    #
    # queryProperties = (accountId) ->
    #   # Get a list of all the properties for the account.
    #   gapi.client.analytics.management.webproperties.list('accountId': accountId).then(handleProperties).then null, (err) ->
    #     # Log any errors.
    #     console.log err
    #
    # handleProperties = (response) ->
    #   # Handles the response from the webproperties list method.
    #   if response.result.items and response.result.items.length
    #     # Get the first Google Analytics account
    #     firstAccountId = response.result.items[0].accountId
    #     # Get the first property ID
    #     firstPropertyId = response.result.items[0].id
    #     # Query for Views (Profiles).
    #     queryProfiles firstAccountId, firstPropertyId
    #   else
    #     console.log 'No properties found for this user.'
    #
    # queryProfiles = (accountId, propertyId) ->
    #   # Get a list of all Views (Profiles) for the first property
    #   # of the first Account.
    #   gapi.client.analytics.management.profiles.list(
    #     'accountId': accountId
    #     'webPropertyId': propertyId).then(handleProfiles).then null, (err) ->
    #     # Log any errors.
    #     console.log err
    #
    # handleProfiles = (response) ->
    #   # Handles the response from the profiles list method.
    #   if response.result.items and response.result.items.length
    #     # Get the first View (Profile) ID.
    #     firstProfileId = response.result.items[0].id
    #     # Query the Core Reporting API.
    #     queryCoreReportingApi firstProfileId
    #   else
    #     console.log 'No views (profiles) found for this user.'
    #
    # queryCoreReportingApi = (profileId) ->
    #   # Query the Core Reporting API for the number sessions for
    #   # the past seven days.
    #   gapi.client.analytics.data.ga.get(
    #     'ids': 'ga:' + profileId
    #     'start-date': '7daysAgo'
    #     'end-date': 'today'
    #     'metrics': 'ga:sessions').then((response) ->
    #     formattedJson = JSON.stringify(response.result, null, 2)
    #     document.getElementById('name').value = formattedJson
    #   ).then null, (err) ->
    #     # Log any errors.
    #     console.log err

    # # Replace with your client ID from the developer console.
    # CLIENT_ID = '484628944735-fl01nng92lhjpqto03t6qkki4s0psinq.apps.googleusercontent.com'
    # # Set authorized scope.
    # SCOPES = [ 'https://www.googleapis.com/auth/analytics.readonly' ]
    # # Add an event listener to the 'auth-button'.
    # $('#GoogleBtn').on('click', authorize)

    clearDisplay()
    # console.log('cookie')
    # console.log($.cookie("sample"))
    $('#AnonymityBtn').trigger("click");
    if Object.keys(args).length > 0
      $('#search').val(args.id)
      makeUserInfo(args.id)

    date = new Date()
    date.setDate(date.getDate() - 1)
    $("#mydate").val(getDateyyyymmdd(date))
    $("#mydate").datetimepicker(locale: 'ja', format : 'YYYY-MM-DD').val(getDateyyyymmdd(date))
    $("#mydate").data("DateTimePicker").date(date)
