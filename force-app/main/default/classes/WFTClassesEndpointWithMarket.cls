@RestResource(urlMapping='/WFTClasses/V2')
global class WFTClassesEndpointWithMarket {
    @HttpGet
    global static ClassResult WFTClassesEndpointWithMarket() {
        ClassResult res = new ClassResult();
        
        //Market__c Order by removed, should be readded for multiple market sorting
        List<Class__c> classes = [
			SELECT Id, 
			Display_Name__c,
			Name,
            Class__c,
			Class_Cost__c, 
			Market__c, 
			Class_Description__c,
			Instructor__c,
            Attendance_Type__c,
			Class_Length__c, 
			Class_Nights__c, 
			Scheduled_Time__c,
            Time_Zone__c,
			Class_Skill_Level__c,
			Instruction_Time__c,
            Attendance_Type_Graphic_URL__c,
			Badge_Graphic_URL__c,
			Registration_Page_URL__c,
			Start_Date__c, 
			End_Date__c 
			FROM Class__c
			WHERE Dont_Display_on_Website__c = false 
			AND Posted_to_Website__c <= TODAY 
			AND Removed_from_Website__c > TODAY ORDER BY Market__c, Class_Order__c, Start_Date__c];
        
		res.records = classes;
		res.numberOfClasses = classes.size();

		List<Market__c> bwMarkets = new List<Market__c>();
		bwMarkets = [SELECT Id, Name, Description__c, PostalCodes__c FROM Market__c WHERE Status__c = 'Active'];
		
		res.numberOfMarkets = bwMarkets.size();

		for (Market__c market : bwMarkets) {
			market.postalCodes__c.deleteWhitespace();
		}
		res.allowedMarkets = bwMarkets;
        return res;
    }
    
    global class ClassResult {
		public Integer numberOfClasses;
		public Integer numberOfMarkets;
		public List<Market__c> allowedMarkets;
		public List<Class__c> records;
    } 

}