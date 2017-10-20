open util/boolean
open util/ordering[Time]

sig User{
	id: Int,
	email: Stringa,
	password: Stringa,
	preferences: Preference, //one because the user can only have a set of preferences
	schedule: some Meeting,
	owns: seq OwnMean,
	subscribed: some SharingSystem,
}

//per controllare che i viaggi avvengano sempre uno dopo l'altro per ogni utente
//uso .next dato che ho ordinato Time (planned: User -> one Travel, //o some?)
//RIVEDERE
//oppure state (come spiego alla classe Travel
sig Time{
	state: User -> one Travel, //o some?
	
}

/*
u: User nella definizione di un fact |
u.Time.state

sig Time{
	dateTime: 
}
*/

sig Date{}

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

sig Meeting{}

sig Region{}

//POI invece che City indicando le coordinate?
//però ricordo che la di Nitto non le riteneva utili nell'alloy in quanto non servivano a 
//testare il modello
sig POI{
	latitude: Stringa,
	longitude: Stringa,
} //omettibili

sig Travel{//stato richiesto del tipo Confirmed, MeanRequested, inProgress
	startingTime: Int,
	endingTime: Int,
}
sig MeanOfTransp{
	ticketNeeded: Bool, //controllare che se true ci sia un ticket associato all'utente
	seats: Int,
}
{ seats>0}

sig OwnMean{}

sig PublicMean{}

sig SharingSystem{}

sig Ticket{}

sig ExternalCompany{}

sig PublicTranspCompany{}

sig SharingCompany{}
