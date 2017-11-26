
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
      mapsController.obtainArrivalTimeFromDepartureTime(t1);
    } else{
      previousTrip = personalEventsController.getPrevious(e).getFromTrip();
      t1.setEndTime(Time.addMinutes(e.getStartTime(), -5));
      mapsController.obtainDepartureTimeFromArrivalTime(t1);

      if(Time.getBetweenMinutes(t1.getStartTime(), previousTrip.getEndTime()) >= 30){
        trips.add(t1);
        break;
      }
      t1.setStartingLocation(personalEventsController.getPrevious(e).getLocation());
      t1.setStartTime(Time.addMinutes(personalEventsController.getPrevious(e).getEndTime(), 5));
      mapsController.obtainArrivalTimeFromDepartureTime(t1);
      if(t1.getEndTime().isGreater(Time.addMinutes(e.getStartTime(), -5))){ break; }
    }

    if(previousTrip.getMOT().isPersonal()){
      if(!t1.getMOT().isEqual(previousTrip.getMOT())){ break; }
    } else {
      if(t1.getMOT().isPersonal()){ break; }
    }

    if(e.getStartTime().isLaterThan(user.getPreferences.getMaxTimeBikeWalk()) && (t1.getMOT.isEqual(MeansOfTransport.BIKE) || t1.getMOT.isEqual(MeansOfTransport.WALK))){ break; }
    
    if(badWeather(t1.getStartingLocation(), t1.getStartTime()) && t1.getMOT.isEqual(MeansOfTransport.BIKE)){ break; }

    if(mapsController.getWalkDistance(t1) >= user.getPreferences().getMaxWalkDistance()){ break; }

    if(checkStrikes(t1.getStartingLocation(), t1.getStartTime()) && t1.getMOT.isEqual(MeansOfTransport.PUBLICTRANSPORT)){ break; }

    if(t.hasPassengers() && !t1.getMOT().admitPassengers()){ break; }

    trips.add(t1);
  }

  if(trips.isEmpty()){
    unfeasibilityWarning(e); // warn the user he cannot come to this event in time from the previous
    personalEventsController.removePrimaryEvent(e);
    personalEventsController.addSecondaryEvent(e);
  }

  if(t.isEcoFriendly()){ // t is initialized with the lowest EcoPoints (scale assigned to every means of transport) and with a travel time of 1 day
    for(Trip t1 : trips){
      if(t1.getMOT().getEcoPoint() > t.getMOT().getEcoPoint()){
        t = t1;
      } else if(t1.getMOT().getEcoPoint() == t.getMOT().getEcoPoint() && t1.getTravelTime() < t.getTravelTime()){
        t = t1;
      }
    }
  } else {
    for(Trip t1 : trips){
      if(t1.getTravelTime() > t.getTravelTime()){ t=t1; }
  }

  if(!(user.getHomeLocation().isEqual(t.getDestination()) || user.getHomeLocation().isEqual(t.getStartingLocation()))){
    personalEventsController.getPrevious(e).setFromTrip(t);
  }

  if(t.getMOT().needsTicket() && !user.getPreferences().hasSeasonPass(t1.getMOT())){
    ticketWarning(t);
  }
}
