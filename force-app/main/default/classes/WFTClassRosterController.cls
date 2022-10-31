public class WFTClassRosterController {
  //Class Information
  public Id classId { get; set; }
  public String className { get; set; }

  public Date selectedDate { get; set; }

  public List<Registration__c> registrations { get; set; }
  public List<RosterRowWrapper> rosterRows { get; set; }

  public Id studentId { get; set; }
  public String studentName { get; set; }

  // Notes
  public boolean displayNotes { get; set; }
  public String notesType { get; set; }
  public String notes { get; set; }
  public Student_Engagement__c studentEngagement { get; set; }

  @testVisible
  private String currentUserContactId;

  public WFTClassRosterController() {
    rosterRows = new List<RosterRowWrapper>();
    classId = apexpages.currentPage().getparameters().get('Id');
    selectedDate = System.today();
    getUserContactId();
    getRegistrations();
  }

  public Attendance__c createAttendance(
    Id attendanceId,
    Id registrationId,
    Id studentId,
    Boolean present
  ) {
    Attendance__c attRec = new Attendance__c(
      Registration__c = registrationId,
      Student__c = studentId,
      Date__c = selectedDate,
      Present__c = present
    );

    if (String.isNotBlank(attendanceId)) {
      attRec.Id = attendanceId;
    }

    return attRec;
  }

  public void getRegistrations() {
    rosterRows.clear();
    if (selectedDate == null) {
      return;
    }
    registrations = [
      SELECT
        Id,
        Registrant__c,
        Registrant__r.Name,
        Registrant__r.Slack_Image__c,
        Registrant__r.Pronouns__c,
        Registrant__r.GitHub_Username__c,
        Class__r.Display_Name__c,
        (
          SELECT
            Id,
            Student__c,
            Student__r.Name,
            Student__r.LastName,
            Date__c,
            Present__c
          FROM Attendances__r
          WHERE
            Registration__r.Class__c = :classId
            AND Date__c = :selectedDate
            AND Registration__r.Dropped__c = FALSE
            AND Registration__r.Dropped_w_Credit__c = FALSE
        )
      FROM Registration__c
      WHERE
        Class__r.Id = :classId
        AND Dropped__c = FALSE
        AND Dropped_w_Credit__c = FALSE
    ];

    if (registrations.size() <= 0) {
      return;
    }
    className = registrations[0].Class__r.Display_Name__c;

    for (Registration__c reg : registrations) {
      RosterRowWrapper rosterRow = new RosterRowWrapper();
      rosterRow.registrationId = reg.Id;
      rosterRow.studentId = reg.Registrant__r.Id;
      rosterRow.studentName = reg.Registrant__r.Name;
      rosterRow.pronouns = reg.Registrant__r.Pronouns__c;
      rosterRow.slackImage = reg.Registrant__r.Slack_Image__c;
      rosterRow.gitHub = reg.Registrant__r.Github_Username__c;

      if (!reg.Attendances__r.isEmpty()) {
        rosterRow.attendanceId = reg.Attendances__r[0].Id;
        rosterRow.present = reg.Attendances__r[0].Present__c ? 'true' : 'false';
        rosterRow.isAttendanceMarked = true;
      } else {
        rosterRow.isAttendanceMarked = false;
      }

      rosterRows.add(rosterRow);
    }
  }

  public class RosterRowWrapper {
    public Id attendanceId { get; set; }
    public Id registrationId { get; set; }
    public Id studentId { get; set; }
    public String slackImage { get; set; }
    public String studentName { get; set; }
    public String pronouns { get; set; }
    public String gitHub { get; set; }
    public String present { get; set; }
    public Boolean isAttendanceMarked { get; set; }
  }

  public void saveAttendances() {
    List<Attendance__c> attendances = new List<Attendance__c>();

    for (RosterRowWrapper rosterRow : rosterRows) {
      attendances.add(
        createAttendance(
          rosterRow.attendanceId,
          rosterRow.registrationId,
          rosterRow.studentId,
          Boolean.valueOf(rosterRow.present)
        )
      );
    }
    upsert attendances;
    getRegistrations();
  }

  // Notes
  public PageReference saveNotes() {
    if (String.isBlank(notes)) {
      return null;
    }
    studentEngagement = new Student_Engagement__c(
      Engagement_Type__c = notesType,
      Student__c = studentId,
      Engagement_Notes__c = notes,
      WFT_Staff_Member__c = currentUserContactId
    );

    insert studentEngagement;

    closeNotes();
    return null;
  }

  private void clearNotesValues() {
    studentId = null;
    studentName = null;
    notesType = null;
    notes = null;
  }

  public void closeNotes() {
    displayNotes = false;
    clearNotesValues();
  }

  public void showNotes() {
    displayNotes = true;
  }

  //Gets info of user who is submitting Attendnace or Notes
  public void getUserContactId() {
    String userId = UserInfo.getUserId();
    User currentUser = [SELECT Id, contactId FROM User WHERE Id = :userId];

    if (String.isBlank(currentUser.contactId)) {
      List<Contact> userContacts = [
        SELECT Id
        FROM Contact
        WHERE User__c = :userId
      ];
      if (userContacts.size() > 0) {
        currentUserContactId = userContacts[0].Id;
      }
    }
  }
}