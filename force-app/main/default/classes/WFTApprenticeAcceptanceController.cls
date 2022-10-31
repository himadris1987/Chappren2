public class WFTApprenticeAcceptanceController {
    //Getting and setting the fields to be Queried
    public String appId{get; set;}
    public String appFirstName {get; set;}
    public String appLastName {get; set;}
    public String appName {get; set;}
    public String appWage {get; set;}
	 public String appLead {get; set;}
	public Date appStartDate {get; set;}
	public Boolean appAcceptance {get; set;}
    
    @TestVisible private Apprentice__c apprentice; 


   //start of the SQOL Query 
    public WFTApprenticeAcceptanceController() {
        appFirstName = '';
        appLastName = '';
        appName = '';
        appWage = '';
		appStartDate = null;
		appLead = '';
		appAcceptance = false;
        appId = apexpages.currentPage().getparameters().get('Id');
        GetApprentice();
        

    }

    public void GetApprentice() {
        List<Apprentice__c> apprentices = new List<Apprentice__c>(); 
        apprentices =[SELECT Id, Contact__r.FirstName, Contact__r.LastName, Apprenticeship__r.Name, Apprentice_Acceptance__c,Apprenticeship_Lead__r.Name, Hourly_Wage__c, Start_Date__c FROM Apprentice__c WHERE Id =: appId ];
        if ( apprentices.size() == 1 ) {
            apprentice = apprentices[0];
            appFirstName = apprentice.Contact__r.FirstName;
            appLastName = apprentice.Contact__r.LastName;
			appName = apprentice.Apprenticeship__r.Name;
			appWage = apprentice.Hourly_Wage__c;
			appStartDate = apprentice.Start_Date__c;
			appLead = apprentice.Apprenticeship_Lead__r.Name;
			appAcceptance = apprentice.Apprentice_Acceptance__c; 
        }
        else {
            System.debug(apprentices);
        }
    }
    
    public PageReference acceptApprenticeship() {
        if(apprentice.Id == null){
            return null;
        } 
        System.debug(apprentice);
		if(apprentice.Apprentice_Acceptance__c) {
			return null;
		}
		
		apprentice.Apprentice_Acceptance__c = true;
        
        Map<String, Object> apprenticeMap = new Map<String, Object>();
        apprenticeMap.put('id', apprentice.Id);
        apprenticeMap.put('acceptance', apprentice.Apprentice_Acceptance__c);
        String body = JSON.serialize(apprenticeMap);
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://hooks.zapier.com/hooks/catch/8857632/o7nh2ri/');
        req.setBody(body);
        req.setMethod('POST');
        res = http.send(req);
        System.debug(res);

        
        
		//update apprentice;
        return null;
    }

}