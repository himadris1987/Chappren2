public class WFTApprenticeshipRosterController {
  public Id apprenticeshipId { get; set; }
  public String apprenticeshipName { get; set; }
  
  public List<Apprentice__c> apprentices { get; set; }
  public Id apprenticeId { get; set; }
  public String apprenticeName {get; set;}

  public String currentUserContactId;

  // Notes
  public boolean displayNotes {get; set;}
  public String notesType { get; set; }
  public String notes { get; set; }
  public Student_Engagement__c studentEngagement { get; set; }
  
  // careerReadyCheck(evaluate)
  public Boolean displayCareerReadyCheck { get; set; }
  private Career_Ready_Check__c careerReadyCheck;
  public String interviewprepNoteTextModal { get; set; }
  public String marketingNoteTextModal { get; set; }
  public String skillreadinessNoteTextModal { get; set; }
  public String communicationNoteTextModal { get; set; }
  public String initiativeNoteTextModal { get; set; }
  public String contributingtosuccessNoteTextModal { get; set; }
  public String gritNoteTextModal { get; set; }
  public String communityengagementNoteTextModal { get; set; }
  public String softskillsNoteTextModal { get; set; }
  public String technicalskillsNoteTextModal { get; set; }
  public String productivityNoteTextModal { get; set; }
  public String teamcontributorNoteTextModal { get; set; }
  public String salesNoteTextModal { get; set; }
  public String teachableNoteTextModal { get; set; }
  public String cultureNoteTextModal { get; set; }
  public String analyticalNoteTextModal { get; set; }
  public String hiringstatusPicklistModal { get; set; }
  public String hiringstatusNoteTextModal { get; set; }
  public String contributingtootherssuccessNoteTextModal { get; set; }
  public String interviewprepPicklistModal { get; set; }
  public String marketingPicklistModal { get; set; }
  public String skillreadinessPicklistModal { get; set; }
  public String communicationPicklistModal { get; set; }
  public String initiativePicklistModal { get; set; }
  public String gritPicklistModal { get; set; }
  public String communityengagementPicklistModal { get; set; }
  public String softskillsPicklistModal { get; set; }
  public String technicalskillsPicklistModal { get; set; }
  public String productivityPicklistModal { get; set; }
  public String teamcontributorPicklistModal { get; set; }
  public String teachablePicklistModal { get; set; }
  public String salesPicklistModal { get; set; }
  public String culturePicklistModal { get; set; }
  public String analyticalPicklistModal { get; set; }
  public String apprenticeshipLeadsInterviewPicklistModal {get; set;}
  public String apprenticeshipLeadsInterviewNoteTextModal {get; set;}

  public WFTApprenticeshipRosterController() {
    apprenticeshipId = apexpages.currentPage().getparameters().get('Id');
    getUserContactId();
    getApprentices();
  }

  public void getApprentices() {
    apprentices = [
      SELECT
        Id, Name, Contact__r.Slack_Image__c, Contact__r.Pronouns__c, Contact__r.Github_Account__c,
        Contact__r.Id, Contact__r.Name, Apprenticeship__r.Name
      FROM 
        Apprentice__c
      WHERE 
        Apprenticeship__c = : apprenticeshipId
        AND (Status__c = 'Scheduled' OR Status__c = 'Active')
        ORDER BY  Contact__r.firstname
    ];
    apprenticeshipName = apprentices.isEmpty() ? '' : apprentices[0].Apprenticeship__r.Name;
  }

  // Career Ready Check Modal
  public void saveCareerReadyCheck() {
    careerReadyCheck = new Career_Ready_Check__c(
      Apprentice__c = apprenticeId,
      Analytical__c = analyticalPicklistModal,
      Analytical_Notes__c = analyticalNoteTextModal,
      Communication__c = communicationPicklistModal,
      Communication_Notes__c = communicationNoteTextModal,
      Community_Engagement__c = communityengagementPicklistModal,
      Community_Engagement_Notes__c = communityengagementNoteTextModal,
      Contributing_to_Success_Notes__c = contributingtosuccessNoteTextModal,
      Contributing_to_the_Success_of_Others__c = contributingtootherssuccessNoteTextModal,
      Culture__c = culturePicklistModal,
      Culture_Notes__c = cultureNoteTextModal,
      Grit__c = gritPicklistModal,
      Grit_Notes__c = gritNoteTextModal,
      Hiring_Status__c = hiringstatusPicklistModal,
      Hiring_Status_Notes__c = hiringstatusNoteTextModal,
      Initiative__c = initiativePicklistModal,
      Initiative_Notes__c = initiativeNoteTextModal,
      Interview_Prep__c = interviewprepPicklistModal,
      Interview_Prep_Notes__c = interviewprepNoteTextModal,
      Marketing_Notes__c = marketingNoteTextModal,
      Marketing__c = marketingPicklistModal,
      Productivity__c = productivityPicklistModal,
      Productivity_Notes__c = productivityNoteTextModal,
      Sales__c = salesPicklistModal,
      Sales_Notes__c = salesNoteTextModal,
      Skill_Readiness__c = skillreadinessPicklistModal,
      Skill_Readiness_Notes__c = skillreadinessNoteTextModal,
      Soft_Skills__c = softskillsPicklistModal,
      Soft_Skills_Notes__c = softskillsNoteTextModal,
      Teachable__c = teachablePicklistModal,
      Teachable_Notes__c = teachableNoteTextModal,
      Team_Contributor__c = teamcontributorPicklistModal,
      Team_Contributor_Notes__c = teamcontributorNoteTextModal,
      Technical_Skills__c = technicalskillsPicklistModal,
      Technical_Skills_Notes__c = technicalskillsNoteTextModal,
      Apprenticeship_Leads_Interview__c = apprenticeshipLeadsInterviewPicklistModal,
      Apprenticeship_Leads_Interview_Notes__c = apprenticeshipLeadsInterviewNoteTextModal,
      Apprenticeship__c = apprenticeshipId
    );

    insert careerReadyCheck;
    closeCareerReadyCheck();
  }

  public void closeCareerReadyCheck() {
      displayCareerReadyCheck = false; 
      clearCareerReadyCheckValues();   
  }     

  public void showCareerReadyCheck() {
      displayCareerReadyCheck = true;    
  }

  public void clearCareerReadyCheckValues() {
    analyticalPicklistModal = null;
    analyticalNoteTextModal = null;
    communicationPicklistModal = null;
    communicationNoteTextModal = null;
    communityengagementPicklistModal = null;
    communityengagementNoteTextModal = null;
    contributingtosuccessNoteTextModal = null;
    contributingtootherssuccessNoteTextModal = null;
    culturePicklistModal = null;
    cultureNoteTextModal = null;
    gritPicklistModal = null;
    gritNoteTextModal = null;
    hiringstatusPicklistModal = null;
    hiringstatusNoteTextModal = null;
    initiativePicklistModal = null;
    initiativeNoteTextModal = null;
    interviewprepPicklistModal = null;
    interviewprepNoteTextModal = null;
    marketingPicklistModal = null;
    marketingNoteTextModal = null;
    productivityPicklistModal = null;
    productivityNoteTextModal = null;
    salesPicklistModal = null;
    salesNoteTextModal = null;
    skillreadinessPicklistModal = null;
    skillreadinessNoteTextModal = null;
    softskillsPicklistModal = null;
    softskillsNoteTextModal = null;
    teachablePicklistModal = null;
    teachableNoteTextModal = null;
    teamcontributorPicklistModal = null;
    teamcontributorNoteTextModal = null;
    technicalskillsPicklistModal = null;
    technicalskillsNoteTextModal = null;
    apprenticeshipLeadsInterviewPicklistModal = null;
    apprenticeshipLeadsInterviewNoteTextModal = null;
    apprenticeId = null;
    apprenticeName = null;
    notesType = null;
    notes = null;
    // noteTypeModal = null;
    careerReadyCheck = null;
  }

  public PageReference saveNotes() {
    if (String.isBlank(notes)) {
        return null;
    }
    studentEngagement = new Student_Engagement__c(
        Engagement_Type__c = notesType,
        Student__c =  apprenticeId,
        Engagement_Notes__c = notes,
        WFT_Staff_Member__c = currentUserContactId);

    insert studentEngagement;

    closeNotes();
    return null;
  }

  private void clearNotesValues() {
    apprenticeId = null;
    apprenticeName = null;
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
    User currentUser = [SELECT Id, contactId FROM User WHERE Id =: userId];
    
    if (String.isBlank(currentUser.contactId)) {
        List<Contact> userContacts = [SELECT Id FROM Contact WHERE User__c =: userId];
        if (userContacts.size() > 0) {
            currentUserContactId = userContacts[0].Id;
        }
    }
  }
}