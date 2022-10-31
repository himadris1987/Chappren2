@isTest
public class WFTAttendanceTableTests {
  @TestSetup
  static void setup() {
    Class__c classNoAttendance = new Class__c(
      Name = 'Test Class No Attendance',
      Class__c = 'JavaScript for Beginners',
      Class_Nights__c = 'Tuesday / Thursday',
      Start_Date__c = Date.today().addDays(30),
      End_Date__c = Date.today().addDays(60),
      Instruction_Time__c = '36 hrs. Instruction',
      Class_Capacity__c = 35,
      Class_Skill_Level__c = 'Beginner',
      Class_Cost__c = 250,
      Class_Description__c = 'This is a test class.',
      Posted_To_Website__c = Date.today(),
      Removed_From_Website__c = Date.today().addDays(30)
    );
    insert classNoAttendance;

    Class__c classRec = new Class__c(
      Name = 'Test Websites for Beginners',
      Class__c = 'Websites for Beginners',
      Class_Nights__c = 'Monday / Wednesday',
      Start_Date__c = Date.today().addDays(30),
      End_Date__c = Date.today().addDays(60),
      Instruction_Time__c = '36 hrs. Instruction',
      Class_Capacity__c = 35,
      Class_Skill_Level__c = 'Beginner',
      Class_Cost__c = 250,
      Class_Description__c = 'This is a test class.',
      Posted_To_Website__c = Date.today(),
      Removed_From_Website__c = Date.today().addDays(30)
    );
    insert classRec;

    Contact student = new contact(
      firstName = 'Student1',
      lastName = 'Student1',
      email = 'cohortdevorgs+bwadmin@gmail.com.invalid'
    );
    insert student;

    Contact student2 = new Contact(
      firstName = 'Student2',
      lastName = 'Student2',
      email = 'cohortdevorgs+bwadmin@gmail.com.invalid2'
    );
    insert student2;

    Contact student3 = new Contact(
      firstName = 'Student3',
      lastName = 'Student3',
      email = 'cohortdevorgs+bwadmin@gmail.com.invalid3'
    );
    insert student3;

    Registration__c registration = new registration__c(
      registrant__c = student.Id,
      Class__c = classRec.Id
    );
    insert registration;

    Registration__c registration2 = new registration__c(
      registrant__c = student2.Id,
      Class__c = classRec.Id
    );
    insert registration2;

    Registration__c registration3 = new registration__c(
      registrant__c = student3.Id,
      Class__c = classRec.Id
    );
    insert registration3;

    List<Attendance__c> attendance = new List<Attendance__c>();

    // start of student4
    Contact student4 = new Contact(
      firstName = 'Student4',
      lastName = 'Student4',
      email = 'cohortdevorgs+student4@gmail.com.invalid2'
    );
    insert student4;

    Registration__c registration4 = new registration__c(
      registrant__c = student4.Id,
      Class__c = classRec.Id
    );
    insert registration4;

    Attendance__c att4 = new Attendance__c(
      registration__c = registration4.Id,
      date__c = Date.valueOf('2021-01-04'),
      present__c = false,
      student__c = student4.Id
    );

    attendance.add(att4);
    // end of student4

    Attendance__c newAttendance = new Attendance__c(
      registration__c = registration.Id,
      date__c = Date.valueOf('2021-02-04'),
      present__c = true,
      student__c = student.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration.Id,
      date__c = Date.valueOf('2021-02-24'),
      present__c = true,
      student__c = student.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration2.Id,
      date__c = Date.valueOf('2021-01-19'),
      present__c = true,
      student__c = student2.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration2.Id,
      date__c = Date.valueOf('2021-01-21'),
      present__c = true,
      student__c = student2.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration2.Id,
      date__c = Date.valueOf('2021-01-26'),
      present__c = false,
      student__c = student2.Id
    );
    attendance.add(newAttendance);

    //Student 3
    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-01-19'),
      present__c = false,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-01-21'),
      present__c = true,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-01-26'),
      present__c = false,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-01-28'),
      present__c = false,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-02-02'),
      present__c = true,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    newAttendance = new Attendance__c(
      registration__c = registration3.Id,
      date__c = Date.valueOf('2021-02-04'),
      present__c = true,
      student__c = student3.Id
    );
    attendance.add(newAttendance);

    insert attendance;
  }

  @isTest
  static void getAttendancesTest() {
    Map<String, List<String>> attMap = new Map<String, List<String>>();
    Class__c testClass = [
      SELECT Id
      FROM Class__c
      WHERE Class_Nights__c = 'Monday / Wednesday'
      LIMIT 1
    ];

    Test.startTest();
    attMap = WFTAttendanceTableController.getAttendances(testClass.Id);
    Test.stopTest();

    System.assertEquals(5, attMap.size());
  }

  @isTest
  static void getAttendancesTestNoAttendances() {
    Map<String, List<String>> attMap = new Map<String, List<String>>();
    Class__c testClass = [
      SELECT Id
      FROM Class__c
      WHERE Class__c = 'JavaScript for Beginners'
      LIMIT 1
    ];

    Test.startTest();
    attMap = WFTAttendanceTableController.getAttendances(testClass.Id);
    Test.stopTest();

    System.assertEquals(0, attMap.size());
  }
}