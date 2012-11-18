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
		// Models management
		// *************
				
		//Refresh models list
		function sigar_model_refresh() {
			//callRuby('sigar_model_refresh', "");
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