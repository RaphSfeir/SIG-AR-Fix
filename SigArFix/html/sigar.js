		// *************
		// Ajax driver
		// *************
		function getXMLHttpRequest() {
			var xhr = null;
			if (window.XMLHttpRequest || window.ActiveXObject) {
				if (window.ActiveXObject) {
					try {
						xhr = new ActiveXObject("Msxml2.XMLHTTP");
					} catch(e) {
						xhr = new ActiveXObject("Microsoft.XMLHTTP");
					}
				} else {
					xhr = new XMLHttpRequest(); 
				}
			} else {
				alert("Votre navigateur ne peut pas rafraîchir les données...");
				return null;
			}
			
			return xhr;
		}
		
		// *************
		// General - GMap API
		// *************		
		var initialLocation = new google.maps.LatLng(48.87079, 2.31689); // Initial location : Paris
		var myMarker; // Var for the Google Maps Marker
		var map; // Var for the Google Map
		var elSvc; // Var for the Elevation Service
		
		// Function to put the window on the center of the screen
		function move_to_center() {
   			window.location = "skp:move@" + screen.width + "," + screen.height + ":" + document.body.offsetWidth + "," + document.body.offsetHeight;
      	};
		
		// Function to initialize the Google Map part
		function initialize(divId) {
		  var myOptions = {
		    zoom: 6, // Default zoom level
		    mapTypeId: google.maps.MapTypeId.ROADMAP //
		  };
		  // Initialize the map
		  map = new google.maps.Map(document.getElementById(divId), myOptions);
		  // Center the map on the initial location
		  map.setCenter(initialLocation);
		  
		  // Defining the principal marker
		  myMarker = new google.maps.Marker({
			position: initialLocation,
			map: map,
			title: "Location",
			draggable: true
		  });
		  
		  // Initializing the Google Maps Elevation Service
		  elSvc = new google.maps.ElevationService();
		  
		  // Function to get elevation from event
		  function getElevation(event) {
		  	var locations = [];
			locations.push(event.latLng);
			var positionalRequest = {'locations': locations};
			elSvc.getElevationForLocations(positionalRequest, function(results, status) 
				{
					if (status == google.maps.ElevationStatus.OK) 
						{
							// Retrieve the first result
							if (results[0]) 
								{
									document.getElementById('altitude').value= results[0].elevation.toFixed(9);
								} 
							else 
								{
									document.getElementById('altitude').value="No results found";
								}
						}
				});
		  }
		  
		  // Adding the right callbacks to the principal marker
		  google.maps.event.addListener(myMarker, 'dragend', function(evt) {
			// Get longitude
			document.getElementById('longitude').value = evt.latLng.lng().toFixed(9);
			// Get latitude
			document.getElementById('latitude').value = evt.latLng.lat().toFixed(9);
			//Get altitude
			getElevation(evt);
			sigar_export_console("Marker released with coordinates ("+evt.latLng.lat().toFixed(9)+", "+evt.latLng.lng().toFixed(9)+")");
		  });
		};
		
		// Generic function to use a ruby callback from Javascript
		function callRuby(callbackName, params) {
			fake_url = 'skp:'+callbackName+'@'+params;
			window.location.href = fake_url;
		}
		
		// Generic function to get messages sent from Ruby, and use them with Javascript
		function rubyReturner(message) {
			alert(message);
		}

		
		// *************
		// Export dialog
		// *************
		
		// Export to the DB
		function sigar_export_sendToDb() {
			sigar_export_console("Exporting to the DB...");
			sigar_export_console("-- Connecting to the DB...");
			// Connecting to the DB
			
			sigar_export_console("-- Connection succeed!");
			sigar_export_console("-- Sending datas...");
			// Sending datas to the DB
			
			sigar_export_console("-- Error: not implemented yet!");
			return false;
		}

		
		// Add the ability to refresh coordinatesin both ways
		function sigar_export_refresh() {
    		var latlng = new google.maps.LatLng(document.getElementById('latitude').value, document.getElementById('longitude').value);
    		myMarker.setPosition(latlng);
    		sigar_export_console("Coordinates set to ("+document.getElementById('latitude').value+", "+document.getElementById('longitude').value+")");
    		return false;
		}
		
		// Add some text to the console
		function sigar_export_console(message) {
			var outputDiv = document.getElementById('export_console');
			var sigar_export_console_text = outputDiv.innerHTML;
			outputDiv.innerHTML = sigar_export_console_text + '<br/>' + message;
			outputDiv.scrollTop = outputDiv.scrollHeight;
			return false;
		}
		
		// Close the dialog
		function sigar_export_close() {
			callRuby('sigar_export_close','');
		}
		
		
		// *************
		// Manage models
		// *************		

				
		//Vars initialization
		var selected_sources = []; /* Depends on how are sources loaded?? */
		selected_sources[1] = false; selected_sources[2] = false; selected_sources[3] = false;

		
		//Switch a source to activated or not
		function toggle_source(source_id)
		{
			selected_sources[source_id] = !selected_sources[source_id];
		}
		
		//Clears the model's list by emptying the <ul>
		function sigar_model_clear() {
			var list_models = document.getElementById("list_models");
			list_models.innerHTML = "";
		}
		
		//Refresh button activated
		function sigar_model_refresh_boot() {
			sigar_model_clear();

			for (var j = 0 ; j < selected_sources.length ; j++)
			{
				if (selected_sources[j] == true && document.getElementsByTagName("input")[j].getAttribute("source_type"))
				{
					var source_type = document.getElementsByTagName("input")[j - 1].getAttribute("source_type");
					if (source_type == "remote")
					{
						var source_href = document.getElementsByTagName("input")[j - 1].getAttribute("source_href");
						if (source_href) {
							call_get_page(source_href, sigar_model_refresh);
						}
					}
				}
			}
		}
		
		//Calls page using ajax (xmlhttprequest)
		function call_get_page(page_href, callback)
		{
			var xhr = getXMLHttpRequest(); 
			xhr.onreadystatechange = function() {
					if (xhr.readyState == 4 && (xhr.status == 200 || xhr.status == 0)) {
						callback(xhr.responseText);
					}
				};
				
			xhr.open("GET", page_href, true);
			xhr.send(null);
		}
		
		//Do the refresh using incoming data
		function sigar_model_refresh(ajData) {
			var new_models = eval(ajData);
			var list_models = document.getElementById("list_models");
			for (var i = 0 ; i < new_models.length ; i++)
			{
				list_models.innerHTML += "<li><input type='checkbox' name='model" + i +"' value = 'model" + i + "'/>" + new_models[i]['nom_objet'] +"</li>"
			}
			console.log(new_models[0]['nom_objet']);
			console.log(new_models);
		}