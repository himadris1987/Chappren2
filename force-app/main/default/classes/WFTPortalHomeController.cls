public class WFTPortalHomeController {
	public List<Class__c> classes { get; set; }
  	public List<Apprenticeship__c> apprenticeships { get; set; }
  	String dayFormat = 'MM/DD';
  	public String recordId {get; set; }
  	private User currentUser;
  	public Profile userProfile;
  	public Boolean  showApprenticeships {get;set;}
   	public Boolean showClasses {get;set;}
  	public List<Profile> seeAllClassesProfiles;
  
  	public WFTPortalHomeController() {
    	currentUser = [SELECT Id, Name, Email, ContactId FROM User WHERE Id =: UserInfo.getUserId()];
    
		userProfile = [SELECT Id, Name
					   FROM Profile
                   	   WHERE Id = : UserInfo.getProfileId()]; 
    
    	seeAllClassesProfiles = new List<Profile>();
    	seeAllClassesProfiles = [SELECT Id, Name
                             	 FROM Profile
							 	 WHERE Name = 'WFT User'
							 	 OR Name = 'System Administrator'
							 	 OR Name = 'BW System Admin'
							  	 OR Name = 'BW Executive'];

    	System.debug(seeAllClassesProfiles);
    	getClasses();
    	getApprenticeships();
  	}
  
	public void getClasses() {
	  	// Determine if WFT Community User or if Allowed to See all Classes
	  	if (seeAllClassesProfiles.contains(userProfile)) {
		  	classes = [SELECT Id, Display_Name__c, Class_Nights__c, Start_Date__c, End_Date__c, 
                       Scheduled_Time__c, Time_Zone__c, Instructor__r.Name
		  			   FROM Class__c WHERE Start_Date__c <= :System.today().addDays(7) 
                       AND End_Date__c >= :System.today().addDays(-7) 
                       AND Num_Students_Registered__c > 0
                       ORDER BY Display_Name__c, Start_Date__c];
		  	
		  	showClasses = !classes.isEmpty();
		  	return;
      	} 
      
		if (!String.isBlank(currentUser.ContactId)) {
			classes = [SELECT Id, Display_Name__c, Class_Nights__c, Start_Date__c, End_Date__c, 
                       Scheduled_Time__c, Time_Zone__c, Instructor__r.Name
		  			   FROM Class__c WHERE Start_Date__c <= :System.today().addDays(7) 
                       AND End_Date__c >= :System.today().addDays(-7) 
                       AND Num_Students_Registered__c > 0
					   AND (Instructor__c = :currentUser.ContactId
					   OR Co_Teacher__c = :currentUser.ContactId
					   OR Teachers_Assistant__c = :currentUser.ContactId)
					   ORDER BY Display_Name__c, Start_Date__c];
			
			showClasses = !classes.isEmpty();
			return;
		}

		classes = [SELECT Id, Display_Name__c, Class_Nights__c, Start_Date__c, End_Date__c, 
                   Scheduled_Time__c, Time_Zone__c, Instructor__r.Name
		  		   FROM Class__c WHERE Start_Date__c <= :System.today().addDays(7) 
                   AND End_Date__c >= :System.today().addDays(-7) 
                   AND Num_Students_Registered__c > 0
				   AND (Instructor__r.Email = :currentUser.Email
				   OR Co_Teacher__r.Email = :currentUser.Email
				   OR Teachers_Assistant__r.Email = :currentUser.Email)
				   ORDER BY Display_Name__c, Start_Date__c];
					
		
		showClasses = !classes.isEmpty();
	}

	public void getApprenticeships() {
		// Determine if WFT Community User or if Allowed to See all Apprenticeships
		
		if ( seeAllClassesProfiles.contains(userProfile)) {
			apprenticeships = [SELECT Id, Name, Start_Date__c, End_Date__c, 
                               Apprentice_Pathway__c, Tech_Stack__c, Apprenticeship_Lead__r.Name 
							   FROM Apprenticeship__c
							   WHERE status__c != 'Inactive'
							   ORDER BY Name];
	
			showApprenticeships = !apprenticeships.isEmpty();
			return;
		} 
		if (!String.isBlank(currentUser.ContactId)) {
			apprenticeships = [SELECT Id, Name, Start_Date__c, End_Date__c,
                               Apprentice_Pathway__c, Tech_Stack__c, Apprenticeship_Lead__r.Name
							   FROM Apprenticeship__c
							   WHERE status__c != 'Inactive'
							   AND Apprenticeship_Lead__c = :currentUser.ContactId
							   ORDER BY Name];
			
            showApprenticeships = !apprenticeships.isEmpty();	
			return;
		}

		apprenticeships = [SELECT Id, Name, Start_Date__c, End_Date__c,
                           Apprentice_Pathway__c, Tech_Stack__c, Apprenticeship_Lead__r.Name
						   FROM Apprenticeship__c
						   WHERE status__c != 'Inactive'
						   AND Apprenticeship_Lead__r.Email = :currentUser.Email
						   ORDER BY Name];
		
        showApprenticeships = !apprenticeships.isEmpty();
		
	}

  public Pagereference toClassRoster() {

    String url = '/apex/WFTClassRoster?id=' + recordId;
    return new PageReference(url);
  }

  public Pagereference toApprenticeshipRoster() {

    String url = '/apex/WFTApprenticeshipRoster?id=' + recordId;
    return new PageReference(url);
  }
}