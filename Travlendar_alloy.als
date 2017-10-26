open util/boolean
open util/ordering[Time]

sig User{
	email: Stringa,
	preferences: Preference, //one because the user can only have a set of preferences
	schedule: seq Meeting,
	owns: set OwnMean,
	subscribed: set SharingSystem,
	provides: set Ticket,
}{
	(#subscribed>0 or #owns>0 or #provides>0)
	#schedule>0
}

fact userHasTickets{
	some u: User | all t: Ticket | t in u.provides
}

fact noUnauthorizedMean{
	all u: User, t: Travel | u.owns in t.mean || u.subscribed in t.mean || 
	u.provides in t.needed
}

fact uniqueMail {
	all u1, u2: User | (u1 != u2) => u1.email != u2.email
}

enum TravelState{Confirmed, MeanRequested, InProgress, NotSpecified}

//per controllare che i viaggi avvengano sempre uno dopo l'altro per ogni utente
//uso .next dato che ho ordinato Time (planned: User -> one Travel, //o some?)
//RIVEDERE
//oppure state (come spiego alla classe Travel
sig Time{
	state: Meeting -> set TravelState, //at each time every Travel has a state
}

fact start {// At the start all travels request a mean
	all m: Meeting | first.state[m] = NotSpecified
}

pred User.addMeeting[u: User, m: Meeting] {
	u.schedule = this.schedule.insert[#this.schedule, m]
}

/**
* Precondition: not this.schedule.isEmpty
*/
pred User.deleteMeeting[u: User, m: Meeting] {
	m in this.schedule.elems
	u.schedule = this.schedule.delete[0]
	not m in u.schedule.elems
}

/*
u: User nella definizione di un fact |
u.Time.state

sig Time{
	dateTime: 
}
*/

sig Stringa{}

/*non credo vadano modellate in alloy, in quanto dovrei descrivere i vincoli
globali per testare se vengano rispettati nel modello
vedrò se torneranno utili con i vari requirements e contraints
*/
sig Preference{
	carshare: Bool,
	bikeshare: Bool,
	ownMean: Bool,
	publicMean: Bool,
	walking: Bool,
	house: Bool,
	work: Bool,
	minCarbon: Bool,
	//lateHours non saprei come farlo
	
}{
all p: Preference | one u: User | p in u.preferences
}

/*fact consistentPreferences{
	all p: Preference | one u: User | p in u.preferences && p.carshare=True <=> #u.subscribed>0
	&& p.ownMean=True <=> #u.owns>0
	&& p.bikeshare=True <=> #u.subscribed>0
	&& p.publicMean=True <=> #u.provides>0
}*/

fact consistentPreferences{
	all p: Preference | one u: User | p in u.preferences && #u.subscribed>0 => p.carshare=True
	&&  #u.owns>0 => p.ownMean=True
	&&  #u.subscribed>0 => p.bikeshare=True
	&&  #u.provides>0 => p.publicMean=True
}

sig Meeting{
	date: Int,
	startingTime: Int,
	endingTime: Int,
	requires: set Travel,
	locate: Region,
}{
	date>0 &&
	startingTime>0 &&
	endingTime>startingTime
	#requires>0
}

fact meetingOfAUser{
all m: Meeting | one u: User | one i: u.schedule.inds | m in u.schedule[i]
}

fact travelsStartAtDifferentTime{
	no disj t1, t2: Travel | one m: Meeting | m in t1.associated && m in t2.associated && t1.startingTime=t2.startingTime
}

sig Region{
	contains: some POI,
}

//POI invece che City indicando le coordinate?
//però ricordo che la di Nitto non le riteneva utili nell'alloy in quanto non servivano a 
//testare il modello
sig POI{} 
{
	all p: POI | one r: Region | p in r.contains
}

sig Travel{//stato richiesto del tipo Confirmed, MeanRequested, inProgress
	date: Int,
	startingTime: Int,
	endingTime: Int,
	//personalMean: set OwnMean,
	//sharingMean: set SharingSystem,
	mean: set MeanOfTransp,
	needed: lone Ticket,	
	associated: one Meeting,//aggiornare uml
	start: one POI,
	end: one POI
}{
startingTime>0 && date>0
&& endingTime>startingTime && endingTime < associated.startingTime && date = associated.date
start!=end
//#mean=1
}

fact needTicketIfPublicMean{
	all t: Travel | all m: PublicMean | #t.needed>0 <=> m.ticketNeeded=True
}

/*fact meanInPreference{
	all t: Travel | one u: User | all i: u.schedule.inds | all m: MeanOfTransp | 
	m in u.schedule[i].requires.mean <=> 
} don't know how to do it*/

fact AtLeastOneMeanForTravel {
	some m: MeanOfTransp | some tick:Ticket | all t: Travel | /*m in t.personalMean || m in t.sharingMean*/
	m in t.mean || tick in t.needed
}//not sure this works


fact TravelCompatibleToUser{
	all t: Travel | all u: User | all i: u.schedule.inds  | t in u.schedule[i].requires =>
 	(/*(some m: t.personalMean |  m in u.schedule[i].requires.personalMean) || 
	(some sm: t.sharingMean | sm in u.schedule[i].requires.sharingMean) ||*/
	(some m: t.mean |  m in u.schedule[i].requires.mean) ||
	(some tick: Ticket | tick in u.schedule[i].requires.needed))
}

fact travelAssociatedToMeeting{
	all t: Travel | one  m: Meeting | t in m.requires
}

abstract sig MeanOfTransp{
	ticketNeeded: Bool, //controllare che se true ci sia un ticket associato all'utente
}

sig OwnMean extends MeanOfTransp{
}{
ticketNeeded=False
}

sig PublicMean extends MeanOfTransp{
	need: one Ticket,
}{
ticketNeeded=True
}

fact MeanExistsOnlyIfUsed{
	all m: MeanOfTransp | some t: Travel | /*m in t.personalMean || m in t.sharingMean*/
	m in t.mean	
}

fact TicketExistsOnlyIfUsed{
	all tick: Ticket | some t: Travel | tick in t.needed	
}

sig SharingSystem extends MeanOfTransp{}
{
ticketNeeded=False
}

sig Ticket{
	seasonPass: Bool,
	//purchased: ExternalCompany, //omettibile: non trattiamo questo in alloy in quanto
												//l'utilità della classe è solo quella di mostrare che 
												//ci sono aziende esterne che sono in qualche modo
												//(come spiegato nel documento) associate all'app
}

/*
sig ExternalCompany{}

sig PublicTranspCompany{}

sig SharingCompany{}*/

pred show{
#User=1
#Meeting=2
}

run show for 3

run addMeeting for 1

run deleteMeeting for 1


