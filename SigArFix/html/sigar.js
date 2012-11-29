var serverUrl = "http://54.246.97.87/SIG-AR/";

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

		// Add the ability to refresh coordinates in both ways
		function sigar_export_refresh() {
    		var latlng = new google.maps.LatLng(document.getElementById('latitude').value, document.getElementById('longitude').value);
    		myMarker.setPosition(latlng);
    		sigar_export_console("Coordinates set to ("+document.getElementById('latitude').value+", "+document.getElementById('longitude').value+")");
    		return false;
		}

		// Add some text to the console
		function sigar_export_console(message) {
			var outputDiv = document.getElementById('export_console');
			if (outputDiv) {
				var sigar_export_console_text = outputDiv.innerHTML;
				outputDiv.innerHTML = sigar_export_console_text + '<br/>' + message;
				outputDiv.scrollTop = outputDiv.scrollHeight;
				return false;
			}
		}

		// Set the filename in the right textbox
		function export_setFileNameDir(filename) {
			sigar_export_console("Looking for active model path...");
			document.getElementById('filename').value = filename;
		}

		// Close the dialog
		function sigar_export_close() {
			callRuby('sigar_export_close','');
		}

		// Function to get categories
		function sigar_export_getCategories() {
			sigar_export_console("Fetching categories...");
			call_get_page(serverUrl + "categories.php",function(data) {
  				var categoriesFetched = eval(data);
  				var chaineCategories = "<SELECT>";
  				for (var i = 0 ; i < categoriesFetched.length ; i++)
				{
					chaineCategories += '<option value="'+categoriesFetched[i]["id_category"]+'">'+categoriesFetched[i]["name_category"]+'</option>';
				}
  				chaineCategories += "</SELECT>";
  				document.getElementById('categoriesList').innerHTML = chaineCategories;
  				sigar_export_console("Done!");
			});
			return false;
		}

		// Function to add category
		function sigar_export_addCategory() {
			sigar_export_console("Sending new category...");
			/*call_get_page(serverUrl + "categories.php",function(data) {
  				var categoriesFetched = eval(data);
  				var chaineCategories = "<SELECT>";
  				for (var i = 0 ; i < categoriesFetched.length ; i++)
				{
					chaineCategories += '<option value="'+categoriesFetched[i]["id_category"]+'">'+categoriesFetched[i]["name_category"]+'</option>';
				}
  				chaineCategories += "</SELECT>";
  				document.getElementById('categoriesList').innerHTML = chaineCategories;
  				sigar_export_console("Done!");
			});*/
			sigar_export_console(document.getElementById('newcategoryname').value);
			return false;
		}

		// Function to get authors
		function sigar_export_getAuthors() {
			sigar_export_console("Fetching authors...");
			call_get_page(serverUrl + "authors.php",function(data) {
  				var authorsFetched = eval(data);
  				var chaineAuthors = "<SELECT>";
  				for (var i = 0 ; i < authorsFetched.length ; i++)
				{
					chaineAuthors += '<option value="'+authorsFetched[i]["id_person"]+'">'+authorsFetched[i]["name_person"]+', '+authorsFetched[i]["firstname_person"]+'</option>';
				}
  				chaineAuthors += "</SELECT>";
  				document.getElementById('authorsList').innerHTML = chaineAuthors;
  				sigar_export_console("Done!");
			});
			return false;
		}

		// Function to add category
		function sigar_export_addCategory() {
			sigar_export_console("Sending new author...");
			/*call_get_page(serverUrl + "categories.php",function(data) {
  				var categoriesFetched = eval(data);
  				var chaineCategories = "<SELECT>";
  				for (var i = 0 ; i < categoriesFetched.length ; i++)
				{
					chaineCategories += '<option value="'+categoriesFetched[i]["id_category"]+'">'+categoriesFetched[i]["name_category"]+'</option>';
				}
  				chaineCategories += "</SELECT>";
  				document.getElementById('categoriesList').innerHTML = chaineCategories;
  				sigar_export_console("Done!");
			});*/
			sigar_export_console(document.getElementById('newauthorname').value);
			return false;
		}

		// *************
		// Manage models
		// *************		


		//Vars initialization
		var selected_sources = []; /* Depends on how are sources loaded?? */
		selected_sources[1] = false; selected_sources[2] = false; selected_sources[3] = false;
		var model_list = [];

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
			model_list = new_models;
			var list_models = document.getElementById("list_models");
			for (var i = 0 ; i < new_models.length ; i++)
			{
				list_models.innerHTML += "<li onclick='sigar_info_show("+ i + ")'><input  type='checkbox' name='model" + i +"' value = 'model" + i + "'/>" + new_models[i].name_scene +"</li>"
			}
		}
		
		//Show's the model informations in the infobox at the right-bottom corner of the page.
		function sigar_info_show(id_model) 
		{
			var infobox = document.getElementById("models-infobox");
			infobox.innerHTML = "Loading model data...";
			infobox.innerHTML = model_list[id_model]['name_object'] + '<br /><input onclick="sigar_edit_model(' + id_model + ')" type=button value="Edit model" />';
		}
		
		//Edit the model's information. Show or hide edit box depending on the box's current style.
		function sigar_edit_model(id_model) 
		{
			var latlng = new google.maps.LatLng(model_list[id_model]['gps_latitude'], model_list[id_model]['gps_longitude']);
			myMarker.setPosition(latlng);
			var editbox = document.getElementById("form-editbox-innercontent");	
			editbox.innerHTML = "Loading edit data...";
			editbox.innerHTML = "<form name='editBox' method='post' action='http://54.246.97.87/SIG-AR/edit_object.php' target='uploadFrame'><div class='edit-box-float'><input style='display:none' name='id_scene' type='text' value = '" + model_list[id_model]['id_scene'] + "' /><input style='display:none' name='id_object' type='text' value='" + model_list[id_model]['id_object3d'] + "' />Longitude : <input class='narrow_input' type='text' id='longitude' name='longitude' value = '" + model_list[id_model]['gps_longitude'] + "'/><br />Latitude : <input type='text' class='narrow_input' id='latitude' name='latitude' value = '" + model_list[id_model]['gps_latitude'] + "' /><br />Altitude : <input class='narrow_input' type='text' id='altitude' name='altitude' value = '" + model_list[id_model]['gps_altitude'] + "' /></div><div class='edit-box-float'>Filename : <input class='wide_input' type='text' id='filename' name='filename' value = '" + model_list[id_model]['name_scene'] + "' /><br />Model name : <input class='wide_input' type='text' id='name' name='name' value = '" + model_list[id_model]['name_object'] + "' /></div><br /><br /><input type='submit' value='Submit Modifications' /></form>";
		}		