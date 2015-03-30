<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
		<style type="text/css">
			html, body {
				height: 100%;
				margin: 0;
				padding: 0;
			}
			#street_canvas {
				height: 100%;
				width: 100%;
                -webkit-transition: opacity 0.5s ease-in-out;
                -moz-transition: opacity 0.5s ease-in-out;
                -o-transition: opacity 0.5s ease-in-out;
                transition: opacity 0.5s ease-in-out;
            }
		</style>
		<title>Street View</title>
<script type="text/javascript" src="https://maps.googleapis.com/maps/api/js?key=AIzaSyDoAzCsGpAURFNinovB6-pUfSodvKwUSlw
&sensor=false">
		</script>
		<script type="text/javascript">
			var panorama;
			var panoramaOptions;
			var currentPosition;
			var currentLatitude;
			var currentLongitude;
			var currentHeading;
			var currentPitch;
			var panoramaService;
			var currentPanoramaLinks;
			var movingHeading;
			var nLinks;
			var bFastForward;

			function initialize() {
				currentLatitude = <?php echo $_GET["latitude"]?>;
				currentLongitude = <?php echo $_GET["longitude"]?>;
				currentHeading = <?php echo $_GET["heading"] ?>;
				currentPitch = 0;
				bFastForward = false;
				
				currentPosition = new google.maps.LatLng(currentLatitude, currentLongitude);
				
				panoramaOptions = {
					position: currentPosition,
					pov: {
						heading: currentHeading,
						pitch: currentPitch,
                        zoom: 1
					}
				};
				
				panoramaService = new google.maps.StreetViewService();
				panorama = new google.maps.StreetViewPanorama(document.getElementById("street_canvas"),panoramaOptions);
				nLinks = -1; // Initialization, which means that panorama is neither yet moved forward nor backward
				movingHeading = -1;
			
				panoramaService.getPanoramaByLocation(currentPosition, 50, function(data, status){
					if (status == google.maps.StreetViewStatus.ZERO_RESULTS)
                    {
                        mapXplorer.notification("No street view is available in this location.", "info");
					}
					else if (status == google.maps.StreetViewStatus.UNKNOWN_ERROR)
                    {
                        mapXplorer.notification("Error in retrieving street view data.", "error");
                    }
					else
					{
					}
				});
				
				google.maps.event.addListener(panorama, 'position_changed', function() {
					mapXplorer.syncLatitudeLongitudeHeadingPathlinks(panorama.getPosition().lat(), panorama.getPosition().lng(), movingHeading, nLinks);
				});
			}
			
			function turnUpBy(pitchParam){
				currentPitch += 1*pitchParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnDownBy(pitchParam){
				currentPitch -= 1*pitchParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnLeftBy(headingParam){
				currentHeading -= 1*headingParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnRightBy(headingParam){
				currentHeading += 1*headingParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnPov(headingParam, pitchParam) {
				currentHeading = headingParam;
				currentPitch = pitchParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnPitch(pitchParam) {
				currentPitch = pitchParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function turnHeading(headingParam) {
				currentHeading = headingParam;
				panorama.setPov({heading: currentHeading, pitch: currentPitch});
			}
			
			function moveForward() {
				var destinationLink;
				
				for (var i=0; i<panorama.links.length; i++)
				{
					if (destinationLink == undefined)
					{
						destinationLink = panorama.links[i];
						continue;
					}
					if (getHeadingForwardDifference(panorama.links[i]) < getHeadingForwardDifference(destinationLink))
					{
						destinationLink = panorama.links[i];
					}
				}
				nLinks = panorama.links.length;
				panoramaService.getPanoramaById(destinationLink.pano, function(data, status) {
					if (status == google.maps.StreetViewStatus.OK) {
						nLinks = data.links.length;
					}
				});
				
				movingHeading = destinationLink.heading;
				panorama.setPano(destinationLink.pano);
			}

			function moveBackward() {
				var destinationLink;

				for (var i=0; i<panorama.links.length; i++)
				{
					if (destinationLink == undefined)
					{
						destinationLink = panorama.links[i];
						continue;
					}
					if (getHeadingBackwardDifference(panorama.links[i]) < getHeadingBackwardDifference(destinationLink))
					{
						destinationLink = panorama.links[i];
					}
				}
				panoramaService.getPanoramaById(destinationLink.pano, function(data, status) {
					if (status == google.maps.StreetViewStatus.OK) {
						nLinks = data.links.length;
					}
				});
				
				movingHeading = (destinationLink.heading>180)? destinationLink.heading-180 : destinationLink.heading+180;
				panorama.setPano(destinationLink.pano);
			}

			function getHeadingBackwardDifference(link) {
				var difference;
				var currentBackwardHeading = (panorama.pov.heading>=180)? panorama.pov.heading-180 : panorama.pov.heading+180;
				
				if (link.heading >= currentBackwardHeading)
				{
					difference = link.heading - currentBackwardHeading;
					if (difference > 180) difference = currentBackwardHeading+360 - link.heading;
				}
				else 
				{
					difference = currentBackwardHeading - link.heading;
					if (difference > 180) difference = link.heading+360 - currentBackwardHeading;
				}
				return difference;
			}

			function getHeadingForwardDifference(link) {
				var difference;
				if (link.heading >= panorama.pov.heading)
				{
					difference = link.heading - panorama.pov.heading;
					if (difference > 180) difference = panorama.pov.heading+360 - link.heading;
				}
				else 
				{
					difference = panorama.pov.heading - link.heading;
					if (difference > 180) difference = link.heading+360 - panorama.pov.heading;
				}
				return difference;
			}
			
			function fastForward(){
				var destinationLink;
				if (!bFastForward)	// initial state of fastForward process
				{
					//mapXplorer.log("Fast Forward is called.");
					currentPanoramaLinks = panorama.links;
				}
				for (var i=0; i < currentPanoramaLinks.length; i++)
				{
					if(destinationLink == undefined)
					{
						destinationLink = currentPanoramaLinks[i];
						continue;
					}
					if(getHeadingForwardDifference(currentPanoramaLinks[i]) < getHeadingForwardDifference(destinationLink))
					{
						destinationLink = currentPanoramaLinks[i];
					}
				}
				movingHeading = destinationLink.heading;
				panoramaService.getPanoramaById(destinationLink.pano, function(data, status){
					if (status == google.maps.StreetViewStatus.OK)
					{
						//window.external.ConsoleDebugLine("Destination = " + data.location.pano);
						if (data.links.length > 2) // if it is intersection
						{
							bFastForward = false; // stop fastForward recursion process
							panorama.setPano(data.location.pano);	// go to that street view
							mapXplorer.notification("Arrived at an Intersection", "info");
						}
						else
						{
							bFastForward = true;	// start fastForward recursion process
							currentPanoramaLinks = data.links;
							panorama.setPano(data.location.pano);	// comment this line if want to directly go to destination
							//mapXplorer.log("Moving forward to next intersection. Hold on tight!");
							//mapXplorer.notification("Moving forward to next intersection. Hold on tight!", "info");
							fastForward();
						}
					}
				});
			}
		</script>
	</head>
    <body onload="initialize()" scroll="no">
		<div id="street_canvas"></div>
    </body>
</html>
