public with sharing class WFTAttendanceTableController {
  @AuraEnabled(cacheable=true)
  public static Map<String, List<String>> getAttendances(Id recordId) {
    List<Date> attendanceDates = new List<Date>();
    List<String> attendanceNames = new List<String>();
    List<String> datesForHeader = new List<String>();
    Map<String, List<String>> attendanceMap = new Map<String, List<String>>();

    List<Attendance__c> attendanceRecords = new List<Attendance__c>();
    Integer maxNumbOfAttendanceDates;

    attendanceRecords = [
      SELECT id, Student__r.name, Date__c, Present__c
      FROM Attendance__c
      WHERE Registration__r.Class__r.id = :recordId
      ORDER BY Student__r.name, Date__c
    ];

    if (attendanceRecords.isempty()) {
      return attendanceMap;
    }

    //loops through attendance records for student names & attendance dates.
    for (Attendance__c Student : attendanceRecords) {
      if (!attendanceNames.contains((Student.Student__r.name))) {
        attendanceNames.add(Student.Student__r.name);
      }
      if (
        Student.Date__c != null && !attendanceDates.contains((Student.Date__c))
      ) {
        attendanceDates.add(Student.Date__c);
      }
    }

    attendanceNames.sort();
    attendanceDates.sort();
    maxNumbOfAttendanceDates = attendanceDates.size();

    // Add header row with dates
    for (Datetime dt : attendanceDates) {
      datesForHeader.add(dt.format('MM/dd/yy', 'PDT'));
    }

    attendanceMap.put('Student', datesForHeader);

    //loops through attendance records for class datepubl
    for (String sName : attendanceNames) {
      List<String> aDisplay = new List<String>();
      for (Date d : attendanceDates) {
        if (attendanceRecords.isEmpty()) {
          aDisplay.add('N/A');
        } else {
          Attendance__c a = attendanceRecords.remove(0);

          if (sName == a.Student__r.Name) {
            if (d != a.Date__c) {
              aDisplay.add('N/A');

              if (attendanceRecords.isEmpty())
                attendanceRecords.add(a);
              else
                attendanceRecords.add(0, a);
            } else {
              aDisplay.add(a.Present__c ? 'P' : 'A');
            }
          } else {
            List<Attendance__c> copy = new List<Attendance__c>();
            copy.add(a);
            copy.addAll(attendanceRecords);
            attendanceRecords = copy;
            break;
          }
        }
      }

      Integer numbMissingAttendance =
        maxNumbOfAttendanceDates - aDisplay.size();
      for (Integer i = 0; i < numbMissingAttendance; i++) {
        aDisplay.add('N/A');
      }

      attendanceMap.put(sName, aDisplay);
    }

    return attendanceMap;
  }
}