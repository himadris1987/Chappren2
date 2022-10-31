@isTest
public class WFTPortalHomeTests {
    
    @testSetup
    static void setup() {
        Account a = new Account(Name='Test Account');
        insert a;
        Contact teacher = new Contact(FirstName = 'Teacher', LastName = 'Teaher', AccountId = a.Id, Email = 'teacher@teacher.com', Qualified_Instructor__c = true);
        insert teacher;

        Contact coTeacher = new Contact(FirstName = 'co-teacher', LastName = 'co-teacher', AccountId = a.Id, Email = 'co-teacher@co-teacher.com', Qualified_Instructor__c = true);
        insert coTeacher;
        
        Contact student = new Contact(FirstName = 'student', LastName = 'student', AccountId = a.Id, Email = 'student@bw.com');
        insert student;
    
        class__c newClass = new class__c(name = 'Test Class', Instructor__c = teacher.Id, Co_Teacher__c = coTeacher.Id,
        class_nights__c = 'Monday / Wednesday', start_date__c = date.today() - 10, end_date__c = date.today() + 45);
        insert newClass;
        
        insert new Registration__c(Registrant__c = student.Id, Class__c = newClass.Id);

        class__c newClass2 = new class__c(name = 'Test Class', Instructor__c = coTeacher.Id,
        class_nights__c = 'Monday / Wednesday', start_date__c = date.today() - 10, end_date__c = date.today() + 45);
        insert newClass2;
        
        insert new Registration__c(Registrant__c = student.Id, Class__c = newClass2.Id);
    }
    
    
    static testMethod void testGetClassesWFTProfile() {    
	
        UserRole ur = [SELECT Id, Name, PortalType, PortalAccountId FROM UserRole where Name = 'System Administrator' LIMIT 1];
		User adminUser = [SELECT Id, Name, UserRoleId FROM User Where Profile.Name='System Administrator' AND IsActive = true LIMIT 1];
        System.debug(ur);
		adminUser.UserRoleId = ur.Id;
        update adminUser;
        System.debug(adminUser);

        User teacherUser;
        System.runAs ( adminUser ) {
            
			Contact teacher = [SELECT Id FROM Contact WHERE Email='teacher@teacher.com'];
            Profile p = [SELECT Id FROM Profile WHERE Name='WFT Community User'];

            teacherUser = new User(Alias = 'newUser', Email='teacher@teacher.com',
            EmailEncodingKey='UTF-8', FirstName='Testing', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, ContactId = teacher.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='teacher@teacher.com');

            insert teacherUser;
        }
 
        System.runAs(teacherUser) {
            WFTPortalHomeController pc = new  WFTPortalHomeController();  
            pc.getClasses();
            System.assertEquals(1, pc.classes.size());
        }
    }

    static testMethod void testGetClassesAdminProfile() {    
	
        WFTPortalHomeController pc = new  WFTPortalHomeController();  
        pc.getClasses();
        System.assertEquals(2, pc.classes.size());

    }

    static testMethod void testGetClassesStandardUserProfile() {    
	
        UserRole ur = [SELECT Id, Name, PortalType, PortalAccountId FROM UserRole where Name = 'System Administrator' LIMIT 1];
		User adminUser = [SELECT Id, Name, UserRoleId FROM User Where Profile.Name='System Administrator' AND IsActive = true LIMIT 1];
        System.debug(ur);
		adminUser.UserRoleId = ur.Id;
        update adminUser;
        System.debug(adminUser);

        User teacherUser;
        System.runAs ( adminUser ) {
 
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

            teacherUser = new User(Alias = 'newUser2', Email='teacher@teacher.com',
            EmailEncodingKey='UTF-8', FirstName='Testing2', LastName='Testing2', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = p.Id, IsActive = true,
            TimeZoneSidKey='America/Los_Angeles', UserName='teacher2@teacher.com');

            insert teacherUser;
        }
 
        System.runAs(teacherUser) {
            WFTPortalHomeController pc = new  WFTPortalHomeController();  
            pc.getClasses();
            System.assertEquals(1, pc.classes.size());
        }
    }
    @isTest
    public static void testToClassRoster() {
        WFTPortalHomeController pc = new  WFTPortalHomeController();
		pc.recordId = 'classId';
		String url = pc.toClassRoster().getUrl();
		System.assertEquals(true, url.contains('classId'));
	}

    @isTest
	public static void testToApprenticeshipRoster() {
		WFTPortalHomeController pc = new  WFTPortalHomeController();
		pc.recordId = 'apprenticeshipId';
		String url = pc.toApprenticeshipRoster().getUrl();
		System.assertEquals(true, url.contains('apprenticeshipId'));
	}
}