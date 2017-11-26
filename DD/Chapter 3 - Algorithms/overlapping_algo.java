
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
