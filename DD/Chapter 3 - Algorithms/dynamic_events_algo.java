
public void dynamicScheduleAlgorithm(){
  Iterator dEvents = user.getPreferences().getDynamicEventsList().iterator();
  personalEventsController.resetDynamicEvents();
  DynamicEvent d = dEvents.next();
  for(Event e :  personalEventsController.getEventsList()){
    while(e.getFromTrip().getEndTime().isAfterThan(d.getBeginningTimeOfPeriod())){
      if(personalEventsController.getNext(e).getToTrip().isEqual(e.getFromTrip())){
        if(Time.getBetweenMinutes(personalEventsController.getNext(e).getStartTime(), e.getFromTrip().getEndTime()) >= d.getBreakMinutes()){
          if(!personalEventsController.isOverlappingAnotherDynamicEvent(d)){
            personalEventsController.addDynamicEvent(d, e.getFromTrip().getEndTime());
            d = dEvents.next();
          } else {
            dynamicUnfeasibilityWarning(d);
          }
        }
      } else {
        if(Time.getBetweenMinutes(personalEventsController.getNext(e).getToTrip().getStartTime(),  e.getFromTrip().getEndTime()) >= d.getBreakMinutes()){
          if(!personalEventsController.isOverlappingAnotherDynamicEvent(d)){
            personalEventsController.addDynamicEvent(d, e.getFromTrip().getEndTime());
            d = dEvents.next();
          } else {
            dynamicUnfeasibilityWarning(d);
          }
        }
      }
    }
  }
}
