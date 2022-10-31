public with sharing virtual class SlackUsersService {
    //Singleton code:
	
    @testVisible private static SlackUsersService instance;

    public static SlackUsersService getInstance() {
        if (instance == null) {
            instance = new SlackUsersService();
        }

        return instance;
    }



   
    //Get JSON Response From Slack when Requesting a Profile
    public Class Response{
        public Boolean ok;
    	public Profile profile;	
    }
    //Get JSON Response From Slack when Requesting a Profile
     public Class UserResponse{
        public Boolean ok;
    	public User user;	
    }
    //Profile and UserId used by functions
    public Profile slackProfile;
  	public String userId;
    
    public Id refreshId;
    
    public SlackUsersService(){
        slackProfile = new Profile();
    }
    
    public SlackUsersService(ApexPages.StandardController sc){
        refreshId = sc.getId();
    }
    
    public PageReference RefreshButton(){
        Set<Id> contactIdToUpdate = new Set<Id>();
        contactIdToUpdate.add(refreshId);
        SlackBatchUpdate b = new SlackBatchUpdate();
        b.contactIds = contactIdToUpdate;

		if (!System.isBatch()) {
			Database.executeBatch(b, 1);
		}
        PageReference page = new PageReference('https://bitwiseindustries.lightning.force.com/lightning/r/Contact/'+refreshId+'/view');
        page.setRedirect(true);
        return page;
        
    }
  
    //Update SlackImage, amd SlackHandle on a Contact using userId and slackProfile, should only be used if slack Id already exists on Contact
    //if slackId or SlackProfile are null function returns else looks for Contact in Org with the matching Slack_Id if no contact exists returns
    //If contact does exist then Slack Fields are updated and upserted into Org
    public virtual Contact updateContactSlackFieldsFromProfileAndUserId(){
    	
        Contact myContact = new Contact();
        
        if(slackProfile == null || String.IsBlank(userId))
            return null;
        
        try{
            
        	myContact = [SELECT ID, Name, Email, Slack_Handle__c, Slack_Id__c, Slack_Image__c, Slack_Email_Address__c FROM Contact WHERE Slack_Id__c = :userId];
            
        }catch(QueryException e) {

    		System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
		}
        
        myContact.Slack_Image__c = slackProfile.image_192.replace('\\','');
        myContact.Slack_Handle__c = slackProfile.display_name;
        myContact.Slack_Email_Address__c = slackProfile.email;
        //System.debug(myContact.Slack_Image__c);

        return myContact;            
    }
    
    //Add SlackId, SlackImage, and SlackHandle to a Contact using userId and slackProfile, should only be used if no slack Id exists for contact because it matches
    //by Email 
    //if slackId or SlackProfile are null function returns else looks for Contact in Org with the matching Slack_Email if no contact exists returns
    //If contact does exist then Slack Fields are updated and upserted into Org
   	 public virtual Contact addContactSlackFieldsFromProfileUsingEmail(){
    	
        Contact myContact = new Contact();
        
        if(slackProfile == null || String.IsBlank(userId))
            return null;
        
        try{
            
        	myContact = [SELECT ID, Name, Email, Slack_Handle__c, Slack_Id__c, Slack_Image__c, Slack_Email_Address__c FROM Contact WHERE Slack_Email_Address__c = :slackProfile.email];
            
        }catch(QueryException e) {

    		System.debug('The following exception has occurred: ' + e.getMessage());
            return null;
		}
         
        if(String.IsEmpty(myContact.Slack_Id__c)){
                 
   			//System.debug(slackProfile.image_192);
   			myContact.Slack_Id__c = userId;
        	myContact.Slack_Image__c = slackProfile.image_192.replace('\\','');
        	myContact.Slack_Handle__c = slackProfile.display_name;
        	//System.debug(myContact.Slack_Image__c);
        }
        else{
             return null;
         }
        return myContact;            
    }
    
    //Request from Slack a userId and a profile associated with the email paramater.
    //if email is null the function returns, if the HTTP request fails the profile and userId are set to Null
    public virtual void getUserIdAndProfileFromEmail(String email){
        Slack_API_Settings__c settings = Slack_API_Settings__c.getOrgDefaults();
		UserResponse current = new UserResponse();
        Http http = new Http();
    	HttpRequest request = new HttpRequest();
        
        if(String.isBlank(email)){
            slackProfile = null;
            userId = null;
            return;
        }
        request.setEndpoint('https://slack.com/api/users.lookupByEmail');
    	request.setMethod('GET');
    	request.setBody('token='+settings.Token__c+'&email='+email);
    	HttpResponse response = http.send(request);
        System.debug(response);
        
        if (response.getStatusCode() == 200){
           
           String results = (String) response.getBody();
           System.debug(results);
           current = (UserResponse)JSON.deserialize(results, UserResponse.class);
            if(current.ok == false){
                slackProfile = null;
            	userId = null;
                return;
            }
           slackProfile = current.user.profile;
           userId = current.user.id;
            if(slackProfile.email == null || String.IsBlank(userId)) {
            	slackProfile = null;
            	userId = null;
            }
               
        }
        else {
            slackProfile = null;
            userId = null;
            //System.debug(response.getStatus());
            //System.debug(response.getBody());
        }
  	
        
    }
    
    //Request from Slack a profile associated with the slackUserId paramater.
    //if slackUserId is null the function returns, if the HTTP request fails the profile is set to Null 
    public virtual void getProfileFromUserId(String slackUserId){
        Slack_API_Settings__c settings = Slack_API_Settings__c.getOrgDefaults();
		Response current = new Response();
        Http http = new Http();
    	HttpRequest request = new HttpRequest();
        slackProfile = new Profile();
        
        
        if(String.isBlank(slackUserId)){
            slackProfile = null;
            userId = null;
            return;
        }
        
        userId = slackUserId;
    	request.setEndpoint('https://slack.com/api/users.profile.get');
    	request.setMethod('GET');
    	request.setBody('token='+settings.Token__c+'&user='+userId);
    	HttpResponse response = http.send(request);
        System.debug(response);
        
        if (response.getStatusCode() == 200){
           
           String results = (String) response.getBody();
           System.debug(results);
           current = (Response)JSON.deserialize(results, Response.class);
           if(current.ok == false){
                slackProfile = null;
            	userId = null;
                return;
            }
           slackProfile = current.profile;
           System.debug(slackProfile);
           if(slackProfile.email == null)
               return;
        }
        else {
            slackProfile = null;
            userId = null;
            //System.debug(response.getStatus());
            //System.debug(response.getBody());
        }
  	
    }
    //Class to handle deserialize JSON request when asking for a user from Slack
    public class User{
        public String id;
        public String team_id;
        public String name;
        public Boolean deleted;
        public String color;
        public String real_name;
        public String tz;
        public String tz_label;
        public Integer tz_offset;
        public Profile profile;
        public Boolean is_admin;
        public Boolean is_owner;
        public Boolean is_primary_owner;
        public Boolean is_restricted;
        public Boolean is_ultra_restricted;
        public Boolean is_bot;
        public Integer updated;
        public Boolean is_app_user;
        public Boolean has_2fa;
        
    }
    
    //Class to handle deserialize JSON request when asking for a user from Slack 
	public class Profile{
        public String title;
        public String phone;
        public String skype;
        public String real_name;
        public String real_name_normalized;
        public String display_name;
        public String display_name_normalized;
        public String status_text;
        public String status_emoji;
        public Integer status_expiration;
        public String avatar_hash;
        public String image_original;
        public String is_custom_image;
        public String first_name;
        public String last_name;
        public String email;
        public String image_24;
        public String image_48;
        public String image_72;
        public String image_192;
        public String image_512;
        public String image_1024;
        public String status_text_canonical;
     }
      
}