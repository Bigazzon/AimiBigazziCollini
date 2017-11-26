public void tripsUpdateAlgorithm(){
  for(Event e :  personalEventsController.getEventsList()){
    tripPlanningAlgorithm(e.getToTrip(), e);
    tripPlanningAlgorithm(e.getFromTrip(), e);
  }
  dynamicScheduleAlgorithm();
}
