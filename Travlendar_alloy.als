open util/boolean
open util/ordering[Time]

sig User{
	id: Int,
	email: Stringa,
	password: Stringa,
	preferences: Preference, //one because the user can only have a set of preferences
	schedule: seq Meeting,
	owns: some OwnMean,
	subscribed: some SharingSystem,
	provides: some Ticket,
}{
	id>0
}

fact noUnauthorizedMean{
	some u: User, t: Travel | u.owns in t.personalMean || u.subscribed in t.sharingMean || 
	u.provides in t.needed
}

fact uniqueID {
	all u1, u2: User | (u1 != u2) => u1.id != u2.id
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
	
}

sig Meeting{
	date: Int,
	startingTime: Int,
	endingTime: Int,
	place: Stringa,
	requires: some Travel,
	locate: Region,
}{
	date>0 &&
	startingTime>0 &&
	endingTime>startingTime
}

fact meetingAssociatedToUser{
	all m: Meeting | one u: User | m in u.schedule[0]
}

sig Region{}

//POI invece che City indicando le coordinate?
//però ricordo che la di Nitto non le riteneva utili nell'alloy in quanto non servivano a 
//testare il modello
sig POI{
	latitude: Stringa,
	longitude: Stringa,
} //omettibili

sig Travel{//stato richiesto del tipo Confirmed, MeanRequested, inProgress
	date: Int,
	startingTime: Int,
	endingTime: Int,
	personalMean: set OwnMean,
	sharingMean: set SharingSystem,
	needed: set Ticket,	
	associated: one Meeting,//aggiornare uml
}{
startingTime>0 && date>0 &&
endingTime>startingTime && endingTime < associated.startingTime && date = associated.date
}

sig MeanOfTransp{
	ticketNeeded: Bool, //controllare che se true ci sia un ticket associato all'utente
	seats: Int,
}
{ seats>0}

sig OwnMean{}

sig PublicMean{
	requires: one Ticket,
}

sig SharingSystem{}

sig Ticket{
	id: Stringa, //assumo che sia sempre giusto il biglietto, non faccio controlli a riguardo
	seasonPass: Bool,
	purchased: ExternalCompany, //omettibile: non trattiamo questo in alloy in quanto
												//l'utilità della classe è solo quella di mostrare che 
												//ci sono aziende esterne che sono in qualche modo
												//(come spiegato nel documento) associate all'app
}

sig ExternalCompany{}

sig PublicTranspCompany{}

sig SharingCompany{}

pred show{
#User=1
}

run show for 3

run addMeeting for 3

run deleteMeeting for 1
