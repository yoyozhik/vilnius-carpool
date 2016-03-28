class @ShowRideController extends CarpoolController
  layoutTemplate: 'onePanelLayout',

  data: ->
    # Fetch your own ride
    query = _id: @params.query.trip
    ownTrips  = carpoolService.pullOwnTrips query, mapView.setActionProgress.bind(mapView, 'ownTrips')
    trip = ownTrips[0]
    mapView.setCurrentTrip trip, ()->
      da ["read-trip"], "Own matching trip is shown", trip
    result =
      currentTrip: trip
    if trip
      activeTrips = carpoolService.pullActiveTrips trip, mapView.setActionProgress.bind(mapView, 'activeTrips')
      da ["read-trip"], "Active trips filtered", activeTrips
      for key, trip of activeTrips
        da ["read-trip"], "Check every trip", trip
        tripRequest = _(trip.requests).findWhere({userId: Meteor.userId()})
        if tripRequest then trip.requested = tripRequest
      result.activeTrips = activeTrips
    return result

Template.ShowRide.helpers
  tripTitle: ()->
    return TripTitle

Template.matchedDrive.events
  "click .requestRide": (event, template) ->
    da ["trip-request"], "Request ride", @_id
    carpoolService.requestRide @_id
