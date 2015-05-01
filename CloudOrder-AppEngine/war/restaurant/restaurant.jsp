<!DOCTYPE html>

<html lang="en">
<head>
<title>Restaurant Management</title>
<!-- Bootstrap -->
<link href="css/bootstrap.min.css" rel="stylesheet" media="screen">
<!-- Styles, taken from Bootstrap Sign-in Form Example.-->
<style type="text/css">
body {
	padding-top: 40px;
	padding-bottom: 40px;
	background-color: #f5f5f5;
}

.regDevicesSection {
	margin-top: 30px;
}

.devicenameCol {
	max-width: 150px;
}

.deviceIdCol {
	max-width: 500px;
	word-wrap: break-word;
}

.form-insertrestaurant {
	max-width: 300px;
	padding: 29px 29px 29px;
	margin: 50px auto 20px;
	background-color: #fff;
	border: 1px solid #e5e5e5;
	-webkit-border-radius: 5px;
	-moz-border-radius: 5px;
	border-radius: 5px;
	-webkit-box-shadow: 0 1px 2px rgba(0, 0, 0, .05);
	-moz-box-shadow: 0 1px 2px rgba(0, 0, 0, .05);
	box-shadow: 0 1px 2px rgba(0, 0, 0, .05);
}

.form-insertrestaurant input[type="text"] {
	font-size: 16px;
	height: auto;
	margin-bottom: 15px;
	padding: 7px 9px;
}

.alertStyle {
	max-width: 300px;
	margin: 5px auto 20px;
}
</style>

<script type="text/javascript">

API_URL = 'https://' + window.location.host + '/_ah/api';

if (window.location.hostname == 'localhost'
    || window.location.hostname == '127.0.0.1'
    || ((window.location.port != "") && (window.location.port > 999))) {
    // We're probably running against the DevAppServer
    API_URL = 'http://' + window.location.host + '/_ah/api';
}

  function showSuccess() { 
    $("#alertArea").hide();
    $("#successArea").show();
    $("#successArea").fadeOut(1000);
  }
  
  function showError(errorHtml) {
    $("#alertArea").removeClass('alert-error alert-info alert-success').addClass('alert-error');
    $("#alertContentArea").html(errorHtml);
    $("#alertArea").show();
  }
    
  function showInfo(infoHtml) {
    $("#alertArea").removeClass('alert-error alert-info alert-success').addClass('alert-info');
    $("#alertContentArea").html(infoHtml);
    $("#alertArea").show();
  }
  
  // This method loads the restaurantendpoint and messageEndpoint libraries
  function loadGapi() {
    gapi.client.load('restaurantendpoint', 'v1', function() {
      updateRegisteredRestaurantTable();
    });
  }

  // Function for checking error responses; it correctly sanitizes error messages
  // so that they are safe to display in the UI
  function checkErrorResponse(result) {      
    if (result && result.error) {
      var safeErrorHtml = $('<div/>').text(result.error.message).html();
      return {isError: true, errorMessage: safeErrorHtml};
    }
    
    return {isError: false};
  }
  
  function generateRegRestaurantTable(restaurants) {
    items = restaurants.items;
  
    if (!items || items.length == 0) {
      var htmlString = "<thead>"
          + "<tr>"
          + "<th>There are no registered restaurant</th>"
          + "</tr>" + "</thead>"
          + "<tbody></tbody>";
      $("#regRestaurantsTable").html(htmlString);
    } else {
      var htmlString = "<thead>" + "<tr>"
          + "<th style='min-width:150px'>Restaurant Name</th>"
          + "<th>Restaurant Id</th>"
          + "<th>Timestamp</th>" 
          + "</tr>" + "</thead>"          
          + "<tbody>";
          
      for (var i = 0; i < items.length; i++) {
        item = items[i];
        htmlString += "<tr>";
        if (item.name) {
          htmlString += "<td class='devicenameCol'>" + item.name
              + "</td>";
        } else {
          htmlString += "<td class='devicenameCol'>" + "(unknown)"
              + "</td>";
        }

        if (item.restaurantId) {
          htmlString += "<td class='deviceIdCol'>" + item.restaurantId + "</td>";
        } else {
          htmlString += "<td class='deviceIdCol'>" + "(unknown)"
          + "</td>";        
        }
        
        
        if (item.createTimestamp) {
          var timestampNumberic = new Number(item.createTimestamp);
          var date = new Date(timestampNumberic);
          
            htmlString += "<td>" + date.toString() + "</td>";
          } else {
            htmlString += "<td>" + "(unknown)"
            + "</td>";        
          }
        
        htmlString += "</tr>";
      }

      htmlString += "</tbody>";
      $("#regRestaurantsTable").html(htmlString);
    }
  }
  
  function updateRegisteredRestaurantTable() {
    gapi.client.restaurantendpoint
        .listRestaurant()
        .execute(
            function(restaurantItems, restaurantItemsRaw) {
              errorResult = checkErrorResponse(restaurantItems, restaurantItemsRaw);
              if (errorResult.isError) {
                showError("There was a problem contacting the server when attempting to list the registered restaurants. " 
                    + "Please refresh the page and try again in a short while. Here's the error information:<br/> "
                    + errorResult.errorMessage);
              } else {
                generateRegRestaurantTable(restaurantItems);              
              }
            });
  }
  
  function handleInserResponse(data, dataRaw) {
    errorResult = checkErrorResponse(data, dataRaw);    
    if (!errorResult.isError) { 
        showSuccess();
        updateRegisteredRestaurantTable();
    } else {
    showError("There was a problem when attempting to inserRestaurant using the server at " 
        + API_URL + ". " + " Is your API Key in MessageEndpoint.java "  
        + "(in your App Engine project) set correctly? Here's the error information:<br/>"
            + errorResult.errorMessage);
    }
  }
  
  function insertRestaurant() {
    var restaurantName = $("#restaurantName").val();
    var brand = $("#brand").val();

    if (restaurantName == "") {
      showInfo("RestaurantName must not be empty!");
      } else {
        gapi.client.restaurantendpoint
        .insertRestaurant({ "name" : restaurantName, "brand" : brand })
        .execute(handleInserResponse);
      }
  }
</script>
</head>

<body>
 <div class="container">
  <h1>Cloud Endpoints Restaurant Management</h1>
  <p style="">This sample lists all of your registered Restaurants
   by accessing the Cloud Endpoint exposed by your App Engine
   App.</p>
  <p>Use the form below to add a restaurant (via Cloud Endpoints) to
   your App Engine Server.</p>
  <p>
   Check out the <a
    href="http://developers.google.com/eclipse/docs/cloud_endpoints"
    target="_blank">docs</a> for more information.
  </p>

  <div class="regRestaurantsSection">
   <h3>Registered Restaurants</h3>
   <table class="table table-striped" id="regRestaurantsTable">
    <thead>
     <tr>
      <th>Searching for registered Restaurants...</th>
     </tr>
    </thead>
   </table>
  </div>

  <div class="form-insertrestaurant">
   <input class="input-block-level" type="text" id="restaurantName"
    placeholder="name">
    <br />
   <input class="input-block-level" type="text" id="brand"
    placeholder="brand">
   <button id="sendButton" class="btn btn-large btn-primary btn-block">Send</button>
  </div>

  <div id="alertArea" class="alert alertStyle">
   <button type="button" class="close">&times;</button>
   <div id="alertContentArea"></div>
  </div>

  <div id="successArea" class="alert alertStyle alert-success fade in">
   Restaurant added!</div>
 </div>
 <div class='container navbar navbar-fixed-bottom'>
  <p class='text-error'>
   <small>NOTE: This page is not protected by authentication! If
    you decide to deploy this application, anyone will be able to access
    it! Information on configuring auth can be found <a
    href="https://developers.google.com/appengine/articles/auth"
    target="_blank">here.</a>
   </small>
  </p>
 </div>

 <!-- JavaScript -->
 <script src="https://apis.google.com/js/client.js?onload=loadGapi">
  {
    "client": {},
      "googleapis.config": {
        root: API_URL
      }
  }
  </script>
 <script src="js/jquery-1.9.0.min.js"></script>
 <script src="js/bootstrap.min.js"></script>

 <script type="text/javascript">
    $("#sendButton").click(insertRestaurant);
    $("#alertArea").hide();
    $("#successArea").hide();
    $('.alert .close').on('click', function() {
      $(this).parent().hide();
    })
  </script>
</body>
</html>