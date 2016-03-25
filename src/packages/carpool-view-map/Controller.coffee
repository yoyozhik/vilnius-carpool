@mapPersistQuery = ['aLoc', 'bLoc', 'alert', 'trip']
locRadiusFilter = 1000 * 180 / (3.14*6371*1000);

@updateUrl = (param, latlng)->
  location = googleServices.toLocation(latlng);
  locStr = googleServices.encodePoints([location]);
  params = {};
  params[param] = locStr
  goExtendedQuery {}, params, mapPersistQuery

class ControllerHelper
  showRideView: (tripId)->
    Router.go('ShowRide', {}, {query: {trip: tripId}});
  selectTrip: (tripId, filterTrip)->
    da ["trips-matcher"], "Selected trip #{tripId} depend on mobile or web view", tripId
    if Router.current({reactive: false}).route.getName() is "Notifications"
      Router.go "ShowRide", {}, {query:{trip: filterTrip._id}}
    else
      goExtendedQuery {}, {trip: tripId}, mapPersistQuery
  showDrive: (tripId)->
    Router.go "ShowDrive", {}, {query:{trip: tripId}}
  showPickup: (tripId)->
    Router.go "ShowPickup", {}, {query:{trip: tripId}}

@controllerHelper = new ControllerHelper();


class @CarpoolController extends RouteController
  layoutTemplate: 'carpoolMapLayout',
  yieldTemplates:
    MapView: to: 'map'

class @RegisterController extends CarpoolController
  layoutTemplate: 'carpoolMapLayout',
  yieldTemplates:
    MapView: to: 'map'

###
  ControllerHelper methods
###
@currentTripMarkers = (params)->
  query = {}
  if params.query.aLoc
    da ['geoloc'], "Location present in url has biggest priority:", params.query.aLoc
    aLoc = googleServices.decodePoints(params.query.aLoc)[0]
  else
    aLoc = Session.get("geoIpLoc");
  if aLoc
    query["fromLoc"] = aLoc
    googleServices.afterInit ()=>
      latlng = googleServices.toLatLng(aLoc)
      da ["trips-filter"], "Update A location", aLoc
      mapView.setCurrentTripFrom null, latlng, null, null, (refinedLatlng, refinedAddress)->
        # TODO check why this can't be moved to mapView
        da ["trips-filter"], "Update A address", refinedAddress
        mapView.trip.from.setAddress(refinedAddress)

  if params.query.bLoc
    da ['geoloc'], "Location present in url has biggest priority:", params.query.bLoc
    bLoc = googleServices.decodePoints(params.query.bLoc)[0]
    query["toLoc"] = bLoc
    googleServices.afterInit ()=>
      latlng = googleServices.toLatLng(bLoc)
      da ["trips-filter"], "Update B location", bLoc
      mapView.setCurrentTripTo null, latlng, null, null, (refinedLatlng, refinedAddress)->
        # TODO check why this can't be moved to mapView
        da ["trips-filter"], "Update B address", refinedAddress
        mapView.trip.to.setAddress(refinedAddress)
  return query

class @CarpoolMapController extends CarpoolController
  layoutTemplate: 'carpoolMapLayout',
  yieldTemplates:
    MapView: to: 'map'

  onBeforeAction: ()->
    unless Meteor.userId()
      da ['data-publish'], "0. No user, nothing to subscribe", Meteor.userId();
      @render("MapView", {to: 'map'});
      @render("CarpoolLogin");
      return
    @next();

  data: ->
    @stopsSubs = Meteor.subscribe("stops");

    if(@stopsSubs.ready())
      mapView.setActionProgress('stops',100);
    else
      mapView.setActionProgress('stops',0);

    # Filter trips by parameters in query - these are set then trip form is filled
    query = currentTripMarkers(@params);

    activeTrips = carpoolService.pullActiveTrips query, mapView.setActionProgress.bind(mapView, 'activeTrips')

    #if mapView.progress.getProgress() isnt 100 then return

    #activeTrips = carpoolService.getActiveTrips().fetch()
    da ['data-publish'], "7. Draw active trips:", activeTrips
    stopsOnRoutes = {};
    da ["stops-drawing"], "Collect the stops to be marked"
    for trip in activeTrips
      da ["stops-drawing"], "Trip stops", trip.stops
      stopsOnRoutes[stop._id] = stop for stop in trip.stops
      mapView.drawActiveTrip trip
    mapView.invalidateActiveTrips(_(activeTrips).pluck("_id"));

    ownTrips = carpoolService.pullOwnTrips {}, mapView.setActionProgress.bind(mapView, 'ownTrips')
    da ['data-publish-ownTrips','stops-drawing'], "Draw own trips:", ownTrips
    for trip in ownTrips
      stopsOnRoutes[stop._id] = stop for stop in trip.stops
      mapView.drawOwnTrip trip
    mapView.invalidateOwnTrips(_(ownTrips).pluck("_id"));

    stops = carpoolService.getStops();
    #da ["stops-drawing"], "Controller stops", stops
    mapView.showStops stops, stopsOnRoutes

    # Redraw trip on top
    if @params.query.trip?
      da ["trips-matcher"], "Highlight selected trip: #{@params.query.trip}"
      trip = _(activeTrips).findWhere({_id: @params.query.trip})
      mapView.selectTrip(trip);

    result =
      currentTrip: mapView.trip
      activeTrips: activeTrips
      myTrips: ownTrips
      stops: stops
      selectedTrip: @params.query.trip
