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
  args = getUrlVars()
  date = new Date()
  isGraphDataGetFirst = false
  isCertification = false

  $.getJSON "https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/pv_sensors.json", (pvsensors) ->
    console.log('getJSON')
    getDateyyyymmdd = (date) ->
      return (date.getFullYear() + "-" + ('0' + (date.getMonth() + 1)).slice(-2) + "-" + ('0' + date.getDate()).slice(-2))

    makeOutputRestriantTable = (id, date, pcs_num, outRestraint) ->
      color_tbl = ['bg-primary', 'bg-success', 'bg-info', 'bg-warning', 'bg-danger']
      colums = Math.floor(12/pcs_num)
      csvOutputRestriantArray = createArray(outRestraint)
      Restriant_data = new Array()
      for i in [0...pcs_num] by 1
        Restriant_data[i] = ""
      for i in [1...csvOutputRestriantArray.length] by 1
        pcs_id = parseInt(csvOutputRestriantArray[i][0])
        Restriant_data[pcs_id] += """
              <div class="row">
                <div class="col-xs-4 #{color_tbl[pcs_id%pcs_num]}">#{csvOutputRestriantArray[i][1]}</div>
                <div class="col-xs-4 #{color_tbl[pcs_id%pcs_num]}">#{csvOutputRestriantArray[i][2]}</div>
                <div class="col-xs-4 #{color_tbl[pcs_id%pcs_num]}">#{csvOutputRestriantArray[i][3]}</div>
              </div>
        """
      OutputRestriantTbl = ''
      for i in [0...pcs_num] by 1
        OutputRestriantTbl += """
              <div class="col-xs-#{colums} #{color_tbl[i%pcs_num]}">
                pcs#{i}
                #{Restriant_data[i]}
              </div>
        """
      res = """
        <div class="container-fluid">
          <div class="row">
            #{OutputRestriantTbl}
          </div>
        </div>
      """
      $('#outputRestriant').html('<p class="control-label">[抑制履歴情報]</p>')
      $('#outputRestriant').append(res)
      $('#outputRestriantcsvdownload').append("<a href='https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs_restraint/#{id}/#{getRestraintTargetFileName(id, date)}' class='btn btn-primary'>抑制履歴csvダウンロード</a>")

    # showCertificationButton = ->
    #   $('#GoogleBtn').show()
    #   $('#AnonymityBtn').show()
    #   $('#FacebookBtn').show()
    #   console.log '認証ボタン表示'

    hideCertificationButton = ->
      $('#GoogleBtn').hide()
      $('#AnonymityBtn').hide()
      $('#FacebookBtn').hide()

    draw = (id, date, option) ->
      $.ajax
          url: getFilePath(id, date),
          success: (data) ->
            csvArray = createArray(data)
            pcs_num = csvArray[0].length-1

            if csvArray.length < 2
              $('#chart').html("<p>csvファイル内にデータがありません</p>")
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

            chart_data.data.columns = new Array()
            graph_count = 0

            # グラフ先頭データ設定
            for i in [0..pcs_num] by 1
              chart_data.data.columns[i] = new Array()
              if i == 0
                chart_data.data.columns[i][graph_count] = 'x'
              else
                chart_data.data.columns[i][graph_count] = 'pcs' + String(i-1)
            graph_count++

            # 初回の点は発電量0の点を打つべし
            startDate = new Date(csvArray[1][0])
            startDate.setMinutes(startDate.getMinutes()-1)
            start_time = getDatehhmm(startDate)

            chart_data.data.columns[0][graph_count] = start_time

            for i in [1..pcs_num] by 1
                chart_data.data.columns[i][graph_count] = String(parseFloat('0'))

            graph_count++

            #初期化
            genkw_total = new Array()
            for i in [0...pcs_num] by 1
              genkw_total[i] = parseFloat('0')

            if option == 1
              for i in [1...csvArray.length] by 1
                chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                for j in [1..pcs_num] by 1
                    chart_data.data.columns[j][graph_count] = csvArray[i][j]
                graph_count++
            else if option == 2
              for i in [1...csvArray.length] by 1
                minute_1digit = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+5, (csvArray[i][0].length-3)))
                if minute_1digit == 0
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in [1..pcs_num] by 1
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num] by 1
                    genkw_total[j] = parseFloat('0')
                  graph_count++

                for j in [1..pcs_num] by 1
                  genkw_total[j-1] += parseFloat(csvArray[i][j])
            else
              for i in [1...csvArray.length] by 1
                minute_2digit = parseInt(csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+4, (csvArray[i][0].length-3)))
                if minute_2digit == 0
                  chart_data.data.columns[0][graph_count] = csvArray[i][0].substring(csvArray[i][0].indexOf(" ")+1, (csvArray[i][0].length-3))
                  for j in[1..pcs_num] by 1
                      chart_data.data.columns[j][graph_count] = String(genkw_total[j-1])
                  for j in [0...pcs_num] by 1
                    genkw_total[j] = parseFloat('0')
                  graph_count++

                for j in [1..pcs_num] by 1
                  genkw_total[j-1] += parseFloat(csvArray[i][j])

            endDate = new Date(csvArray[csvArray.length-1][0])
            endDate.setMinutes(endDate.getMinutes()+1)
            end_time = getDatehhmm(endDate)

            chart_data.data.columns[0][graph_count] = end_time

            for j in[1..pcs_num] by 1
              chart_data.data.columns[j][graph_count] = String(parseFloat('0'))

            graph_count++

            c3.generate(chart_data)
            $('#csvdownload').append("<a href='https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs/#{id}/#{getTargetFileName(id, date)}' class='btn btn-primary'>#{getTargetFileName(id, date)}ダウンロード</a>")

          error: (error) ->
            # if isCertification == false
            #   showCertificationButton()
            # else
              if isGraphDataGetFirst == false
                $('#createChart').trigger("click");
                isGraphDataGetFirst = true
              else
                $('#chart').html("<p>グラフデータを作成できませんでした。</p>")

    clearDisplay = ->
      $('#chart').html("")
      $('#csvdownload').html("")
      $('#outputRestriantcsvdownload').html("")
      $('#outputRestriant').html("")
      $('#createChart').hide()
      $('#createRestriant').hide()
      hideCertificationButton()

    drawDisplay = (id, date, option) ->
      clearDisplay()
      # if isDisplayStart == false
      #   console.log("isDisplayStart == false")
      #   $('#status').html("")
      #   return
      if pvsensors[id] is undefined
        $('#chart').html("<p>存在しないシリアル番号(id)です</p>")
        return
      draw(id, date, parseInt(option))

    $('#search').change　->
      console.log("#search change")
      drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#facebook-login-confirmation').click ->
      console.log "$('#facebook-login-confirmation').click"
      $('#status').html("")
      if isFacebookCertification != false
        hideCertificationButton()
        isCertification = true
      # isDisplayStart = true
      drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

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

    $('#tommorow').click ->
      date.setDate date.getDate() + 1
      $('#mydate').val(getDateyyyymmdd(date))
      isGraphDataGetFirst = false
      $('#mydate').data("DateTimePicker").date(date)

    $('#createChart').click ->
      lambda = new AWS.Lambda()
      $('#createRestriant').hide()
      $('#myChartModal').show()
      lambda.invoke {
          FunctionName: 'get-csv'
          Payload: JSON.stringify({"id": $('#search').val(), "date": getDateyyyymmdd(date).replace(/-/g, '/')})
      }, (err, data) ->
          console.log('Lambda invoke end')
          $('#myChartModal').modal('hide')
          if err
            console.log(err, err.stack)
            $('#chart').html("<p>グラフデータを作成できませんでした。</p>")
          else
            console.log(data)
            drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $("#createRestriant").click ->
      lambda = new AWS.Lambda()
      console.log(getDateyyyymmdd(date).replace(/-/g, '/'))
      $('#createRestriant').hide()
      $('#myModal').show()
      lambda.invoke {
          FunctionName: 'create_cvs_restraint_history'
          Payload: JSON.stringify({"id": $('#search').val(), "date": getDateyyyymmdd(date).replace(/-/g, '/')})
      }, (err, data) ->
          if err
            console.log(err, err.stack)
          else
            $('#myModal').modal('hide')
            drawDisplay($('#search').val(), date, $('#mode input[name="gender"]:checked').val())

    $('#GoogleBtn').click ->
      console.log('google 押下')
      $('#chart').html("<p>実は。。google認証はまだサポートできてません。。</p>")

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

    progress = (count) ->
      setTimeout (->
        $('#pgss2').css 'width': count + '%'
        count++
        if count == 90
          return
        progress count
        return
      ), 300

    createArray = (csvData) ->
        tempArray = csvData.split("\n")
        csvArray = new Array()
        #最後に何故か常にごみデータ（ブランクデータ）が入るらしい
        for i in [0...(tempArray.length-1)] by 1
          csvArray[i] = tempArray[i].split(",")
        return (csvArray)

    getTargetFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + ".csv")

    getRestraintTargetFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + "_errorflag.csv")

    getFilePath = (id, date) ->
      return ("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs/" + id + "/" + getTargetFileName(id, date))

    getDatehhmm = (date) ->
      return (('0' + date.getHours()).slice(-2) + ":" + ('0' + date.getMinutes()).slice(-2))

    getOutputRestriantFilePath = (id, date) ->
      return ("https://s3-ap-northeast-1.amazonaws.com/sanix-data-analysis/fhRK0XGVb3cR1r1S3x9j3j3DRFGUyRYC/gendata_bypcs_restraint/" + id + "/" + getOutputRestriantFileName(id, date))

    getOutputRestriantFileName = (id, date) ->
      return (id + "-" + getDateyyyymmdd(date) + "_errorflag.csv")

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
    $('#AnonymityBtn').trigger("click");
    if Object.keys(args).length > 0
      serialid = args.id
      $('#search').val(serialid)
    date = new Date()
    date.setDate(date.getDate() - 1)
    $("#mydate").val(getDateyyyymmdd(date))
    $("#mydate").datetimepicker(locale: 'ja', format : 'YYYY-MM-DD').val(getDateyyyymmdd(date))
    $("#mydate").data("DateTimePicker").date(date)
