@RestResource(urlMapping='/projects/*')
global class ProjectEndpoint {
    @HttpGet
    global static ProjectResult getProjectResults() {
       	RestRequest req = RestContext.request;
		System.debug(req);
		System.debug(req.params);
        Map<String, String> params = req.params;
        String projectId = params.get('project');
        String contactEmail = params.get('contact');
		
		if(!String.isBlank(contactEmail)) {
			contactEmail = EncodingUtil.urlDecode(contactEmail, 'UTF-8');

			return getProjectsByMember(contactEmail, projectId);
		}

		ProjectResult res = new ProjectResult();
		res.Error_Code = 'CONTACT_EMAIL_MUST_BE_PROVIDED';
		res.message = 'Must provide a Contact email.';
		RestContext.response.statusCode = 400;
		return res;
    }

    
    public static ProjectResult getProjectsByMember(String contactEmail, String projectId) {
		ProjectResult res = new ProjectResult();
        List<Project__c> projects = new List<Project__c>();
		List<Project_Member__c> projectMembers = new List<Project_Member__c>();

		List<Id> projectIds = new List<Id>();

		contactEmail = String.escapeSingleQuotes(contactEmail);
        //CC (3/14/22) Added a check for recordType so only LDA projects are returned.
		String projectRecordTypeId = Schema.SObjectType.Project__c.getRecordTypeInfosByName().get('LDA').getRecordTypeId();
        
        if(String.isBlank(projectId)) {
			projectMembers = [SELECT Id, Project__c FROM Project_Member__c
							  WHERE Contact__r.Email = :contactEmail AND Contact__r.LDA_Time_Tracking__c = true AND
							  Project__r.Status__c != 'Archived' AND Project__r.RecordTypeId = :projectRecordTypeId AND Status__c = 'Active'];
		}
		else {
			projectId = String.escapeSingleQuotes(projectId);
			projectMembers = [SELECT Id, Project__c FROM Project_Member__c 
						      WHERE Contact__r.Email = :contactEmail AND Contact__r.LDA_Time_Tracking__c = true AND
						  	  Project__c = :projectId AND Project__r.RecordTypeId = :projectRecordTypeId AND Project__r.Status__c != 'Archived' 
							  AND Status__c = 'Active'];
		}
	

		if( projectMembers.isEmpty()) {
			res.Error_Code = 'PROJECT_MEMBER_NOT_FOUND';
			res.message = 'Must have LDA extension access and Must be an active project member on a non archived project.';
			RestContext.response.statusCode = 404;
			return res;
		}

		for(Project_Member__c pm : projectMembers) {
			if(!projectIds.contains(pm.Project__c)) {
				projectIds.add(pm.Project__c);
			}
		}

		projects = [SELECT Id, Name, Status__c, RecordTypeId, Type__c
					FROM Project__c 
					WHERE Id IN :projectIds ORDER BY Id];

		System.debug('Projects: '+ projects.size() + ' Project Members: ' + projectMembers.size());
		return createProjectResult(projects);

    }

	public static ProjectResult createProjectResult(List<Project__c> projects) {
		ProjectResult res = new ProjectResult();
		Integer numberOfProjects = 0;
		Map<String,String> recordTypes = new Map<String, String>();
		for(Project__c project : projects) {
            Project singleResult = new Project();
			String recordType;

			singleResult.Id = project.Id;
			singleResult.Name = project.Name;
			singleResult.Status = project.Status__c;

			// FV (8/23/21) 
			// If project has record type, then return it as part of project data
			if (!String.isBlank(project.recordTypeId)) {
				if (recordTypes.containsKey(project.recordTypeId)) {
					singleResult.RecordType = recordTypes.get(project.recordTypeId);
				}
				else {
					String recordTypeName;
					recordTypeName = Schema.SObjectType.Project__c.getRecordTypeInfosById().get(project.recordTypeId).getName();
					
					if(!String.isBlank(recordTypeName)) {
						recordTypes.put(project.RecordTypeId, recordTypeName);
						singleResult.RecordType = recordTypes.get(project.recordTypeId);
						
					}
					
				}
			}

			// FV (8/31/21) 
			// If project has type, then return it as part of project data
			if (!String.isBlank(project.Type__c)) {
				singleResult.Type = project.Type__c;
			}

		
			numberOfProjects++;
			System.debug(SingleResult);
			res.projects.add(singleResult);
		}

		System.debug('Projects: '+ projects.size());
		res.Number_Of_Projects = numberOfProjects;
        return res;
	}


	global class Project {
        public Id Id;
		public String Name;
        public String Status;
		public String RecordType; // FV (8/23/21) - Added this to allow dynamic chrome extension options
		public String Type; // FV (8/31/21) - Added this to allow dynamic chrome extension options
    }

	global class ProjectResult {
		 public Integer Number_Of_Projects = 0;
		 public List<Project> Projects = new List<Project>();
         public String Message;
		 public String Error_Code; 
	}
}