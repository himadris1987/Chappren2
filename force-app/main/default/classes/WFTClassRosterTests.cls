@isTest
public with sharing class WFTClassRosterTests {
  @TestSetup
  static void makeData(){
    User adminUser = [SELECT Id FROM User WHERE Profile.Name = 'System Administrator'  
              AND UserRole.Name = 'System Administrator' AND IsActive = true LIMIT 1];
      
    System.runAs ( adminUser ) {
      Contact currUserAsContact = new Contact(firstName = 'Contact', lastName = 'User111', email = 'currUserAsContact111@test.com', User__c = adminUser.Id);
      insert currUserAsContact;
    }
          
    Class__c newClass = new Class__c(
      Name = 'Websites for Beginners',
      Class_nights__c = 'Monday / Wednesday',
      Start_date__c = date.today(),
      End_date__c = date.today() + 45
    );
    insert newClass;

    //student 1
    contact student1 = new contact(
      firstName = 'Student1',
      lastName = 'Student1',
      wft_student__c = true,
      email = 'student1@gmail.com'
    );
    insert student1;

    registration__c registration1 = new registration__c(
      registrant__c = student1.Id,
      class__c = newClass.Id
    );
    insert registration1;

    Attendance__c attendance1 = new Attendance__c(
        registration__c = registration1.Id,
        date__c = date.today(),
        present__c = false,
        student__c = student1.Id
      );
    insert attendance1;

    //student 2
    contact student2 = new contact(
        firstName = 'Student2',
        lastName = 'Student2',
        wft_student__c = true,
        email = 'student2@gmail.com'
      );
    insert student2;

    registration__c registration2 = new registration__c(
        registrant__c = student2.Id,
        class__c = newClass.Id
      );
    insert registration2;

    Attendance__c attendance2 = new Attendance__c(
        registration__c = registration2.Id,
        date__c = date.today(),
        present__c = true,
        student__c = student2.Id
      );
    insert attendance2;

    //student 3
    contact student3 = new contact(
      firstName = 'Student3',
      lastName = 'Student3',
      wft_student__c = true,
      email = 'student3@gmail.com'
    );
    insert student3;

    registration__c registration3 = new registration__c(
      registrant__c = student3.Id,
      class__c = newClass.Id
    );
    insert registration3;

    Attendance__c attendance3 = new Attendance__c(
      registration__c = registration3.Id,
      date__c = date.today(),
      present__c = false,
      student__c = student3.Id
    );
    insert attendance3;
  }


  @isTest
  static void getRegistrationsTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    c.classId = [SELECT Id FROM Class__c LIMIT 1].id;
    c.selectedDate = date.today();
    
    Test.startTest();
    c.getRegistrations();
    Test.stopTest();

    System.assertEquals(3, c.rosterRows.size());
  }

  @isTest
  static void getRegistrationsWithNoSelectedDateTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    c.classId = [SELECT Id FROM Class__c LIMIT 1].id;
    c.selectedDate = null;
    
    Test.startTest();
    c.getRegistrations();
    Test.stopTest();

    System.assertEquals(0, c.rosterRows.size());
}

  @isTest
  static void getRegistrationsWithNoAttendanceTest() {
    WFTClassRosterController c = new WFTClassRosterController();

    Class__c class5 = new Class__c(
      Name = 'Websites for Beginners Class 5',
      Class_nights__c = 'Monday / Wednesday',
      Start_date__c = date.today(),
      End_date__c = date.today() + 45
    );
    insert class5;

    contact student5 = new contact(
      firstName = 'Student5',
      lastName = 'Student5',
      wft_student__c = true,
      email = 'student5@gmail.com'
    );
    insert student5;

    registration__c registration5 = new registration__c(
      registrant__c = student5.Id,
      class__c = class5.Id
    );
    insert registration5;

    c.classId = class5.Id;
    c.selectedDate = date.today();
    
    Test.startTest();
    c.getRegistrations();
    Test.stopTest();

    System.assertEquals(1, c.rosterRows.size());
  }
 
  @isTest 
  static void  saveAttendancesTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    c.classId = [SELECT Id FROM Class__c LIMIT 1].id;
    c.selectedDate = date.today();
    c.getRegistrations();
    
    Test.startTest();
    c.saveAttendances();
    Test.stopTest();

    System.assertEquals(3, c.rosterRows.size());
  }

  @isTest 
  static void saveNotesTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    c.notes = 'Test notes';

    Test.startTest();
    c.saveNotes();
    Test.stopTest();

    Student_Engagement__c notes = [SELECT Engagement_Notes__c FROM Student_Engagement__c LIMIT 1];
    System.assertEquals('Test notes', notes.Engagement_Notes__c);
  }

  @isTest 
  static void saveNotesBlankTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    c.notes = '';

    Test.startTest();
    c.saveNotes();
    Test.stopTest();

    list<Student_Engagement__c> notes = [SELECT Engagement_Notes__c FROM Student_Engagement__c];
    System.assertEquals(0, notes.size());
  }

  @isTest 
  static void createAttendanceTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    Registration__c reg = [SELECT Id, Registrant__c FROM Registration__c LIMIT 1];
    
    Test.startTest();
    Attendance__c att = c.createAttendance(null, reg.Id, reg.registrant__c, true);
    Test.stopTest();
    
    System.assertEquals(true, att.present__c);
  }

  @isTest 
  static void showNotesTest() {
    WFTClassRosterController c = new WFTClassRosterController();
    
    Test.startTest();
    c.showNotes();
    Test.stopTest();

    System.assertEquals(true, c.displayNotes);
  }

  @isTest 
  static void getUserContactIdTest() {
    WFTClassRosterController c = new WFTClassRosterController();

    contact contactUser = new contact(
      firstName = 'Contact1',
      lastName = 'User1',
      email = 'contactUser11@gmail.com',
      user__c = UserInfo.getUserId()
    );
    insert contactUser;

    Test.startTest();
    c.getUserContactId();
    Test.stopTest();

    system.assertEquals(contactUser.Id, c.currentUserContactId);
  }
}