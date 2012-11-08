		var initialLocation = new google.maps.LatLng(48.87079, 2.31689); // Initial location : Paris
		
		// Function to initialize the Google Map part
		function initialize(divId) {
		  var myOptions = {
		    zoom: 6, // Default zoom level
		    mapTypeId: google.maps.MapTypeId.ROADMAP //
		  };
		  // Initialize the map
		  var map = new google.maps.Map(document.getElementById(divId), myOptions);
		  // Center the map on the initial location
		  map.setCenter(initialLocation);
		};