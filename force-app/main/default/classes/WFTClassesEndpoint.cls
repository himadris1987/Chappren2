@RestResource(urlMapping='/WFTClasses')
global class WFTClassesEndpoint {
    @HttpGet
    global static ClassResult WFTClassesEndpoint() {
        ClassResult res = new ClassResult();
        
		res.baseURL = 'https://bitwiseindustries.secure.force.com/WFTClassRegistration?id=';

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
			AND Removed_from_Website__c > TODAY ORDER BY Class_Order__c, Start_Date__c];
        
		res.records = classes;
		res.totalSize = classes.size();
        return res;
    }
    
    global class ClassResult {
	public Integer totalSize;
    public String baseURL;
	public List<Class__c> records;
    } 

}