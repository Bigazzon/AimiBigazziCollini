
 /*
 *   Event is already initialized with to/from trip;
 *   by default the trip to the event starts from home
 *   and it ends on event location, instead the trip from
 *   the event starts from event location and goes to home.
 */

public void overlappingCheckAlgorithm(Event event){
  ArrayList<Event> overlap = personalEventsController.getOverlappingEvents(event);  // in SQL !((TStart1>=TEnd)||(TEnd1<=TStart))
  if (!overlap.isEmpty()){
    overlappingWarning(event);
    if(getPrimaryEventChoice(event,overlap)){  // 1 if the event is chosen as primary instead of the ones it overlaps with
      personalEventsController.removePrimaryEvent(overlap);
      personalEventsController.addSecondaryEvent(overlap);
      personalEventsController.addPrimaryEvent(event);
      tripsUpdateAlgorithm();
    } else {
      personalEventsController.addSecondaryEvent(event);
    }
  } else {
    personalEventsController.addPrimaryEvent(event);
    tripsUpdateAlgorithm();
  }
}

public void tripsUpdateAlgorithm(){
  for(Event e :  personalEventsController.getEventsList()){
    tripPlanningAlgorithm(e.getToTrip(), e);
    tripPlanningAlgorithm(e.getFromTrip(), e);
  }
  dynamicScheduleAlgorithm();
}

public void tripPlanningAlgorithm(Trip t, Event e){
  ArrayList<Trip> trips = new ArrayList<>();
  ArrayList<MeansOfTransport> motList;
  Trip previousTrip;
  if(t.isCustom()){
    motList = t.getCustomMOTs();
  } else {
    motList = user.getPreferences().getMOTList();
  }
  for(MeansOfTransport mot : motList){
    Trip t1 = new Trip(t,mot);
    if(user.getHomeLocation().isEqual(t.getDestination())){
      previousTrip = e.getToTrip();
      t1.setStartTime(Time.addMinutes(e.getEndTime(), 5));
      mapsController.setArrivalTimeFromDepartureTime(t1);
    } else{
      previousTrip = personalEventsController.getPrevious(e).getFromTrip();
      t1.setEndTime(Time.addMinutes(e.getStartTime(), -5));
      mapsController.setDepartureTimeFromArrivalTime(t1);
      if(Time.getBetweenMinutes(t1.getStartTime(), previousTrip.getEndTime()) >= 30){
        trips.add(t1);
        break;
      }
      t1.setStartingLocation(personalEventsController.getPrevious(e).getLocation());
      t1.setStartTime(Time.addMinutes(personalEventsController.getPrevious(e).getEndTime(), 5));
      mapsController.setArrivalTimeFromDepartureTime(t1);
      if(t1.getEndTime().isGreater(Time.addMinutes(e.getStartTime(), -5))){
        break;
      }
    }
    if(previousTrip.getMOT().isPersonal()){
      if(!t1.getMOT().isEqual(previousTrip.getMOT())){ break; }
    } else {
      if(t1.getMOT().isPersonal()){ break; }
    }
    if(badWeather(t1.getStartingLocation(), t1.getStartTime()) && t1.getMOT.isEqual(MeansOfTransport.BIKE)){ break; }
    if()
  }
}
