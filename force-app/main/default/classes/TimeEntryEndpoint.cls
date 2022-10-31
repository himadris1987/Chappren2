@RestResource(urlMapping='/time_entry/*')
global class TimeEntryEndpoint {
	@HttpGet
    global static TimeEntryResult getTimeEntry() {
        RestRequest req = RestContext.request;
        Map<String, String> params = req.params;
        TimeEntryResult res  = new TimeEntryResult();

        String projectId = params.get('project');
        String contactEmail = params.get('contact');
		if(!String.isBlank(contactEmail)) {
			contactEmail = EncodingUtil.urlDecode(contactEmail, 'UTF-8');
		}
        else {

            res.Error_Code = 'CONTACT_EMAIL_MUST_BE_PROVIDED';
			res.message = 'Must provide a Contact email.';
			RestContext.response.statusCode = 400;
			return res;
        }
        List<String> fieldNames = new List<String> {
			'Id', 
            'Contact__c', 
            'Contact__r.Name',
			'Contact__r.Email', 
            'Hours__c', 
            'Description__c',
			'Date__c',
			'Project__r.Name',
			'Project__r.Type__c'
		};
        
        List<String> optWhereClauses = new List<String>();
        
        Boolean projectAndContact = !String.isBlank(projectId) && !String.isBlank(contactEmail);

        String whereClause = '';
        if(projectAndContact) {
            whereClause = 'Project__c = :projectId AND Contact__r.Email = :contactEmail';
        }
        else {
            
            if(!String.isBlank(contactEmail)) {
                whereClause = 'Contact__r.Email = :contactEmail AND Date__c >= LAST_N_DAYS:29';
            }
        }
       
        String query = 'SELECT ' + String.join(fieldNames,',') + ' FROM Time_Entry__c';
        
        if(!String.isBlank(whereClause)) {
            query += ' WHERE ' + whereClause;
        } 

        query += ' ORDER BY Date__c DESC LIMIT 50';

        
		try {
			res.Time_Entry_Records = (List<Time_Entry__c>) Database.query(query);
        	res.Number_Of_Time_Records = res.Time_Entry_Records.size();
		} catch (Exception ex) {
			System.debug('QUERY_FAILED');
			res.Error_Code = 'QUERY_FAILED';
			res.message = ex.getMessage();
		}
        
        return res;
    }

	@HttpPost
	global static TimeEntryResult postTimeEntry() {
		RestRequest req = RestContext.request;
		TimeEntryResult res = new TimeEntryResult();

		String body = req.requestBody.toString();

        Map<String, Object> params =  (Map<String, Object>) JSON.deserializeUntyped(body);

		Boolean RequiredValuesFound = params.containsKey('contact')  && params.containsKey('project') 
                                      && params.containsKey('hours');
		
		if (!RequiredValuesFound) {
			res.Error_Code = 'REQUIRED_FIELD_MISSING';
			res.message = 'Body must include values for contact, project, and hours.';
			RestContext.response.statusCode = 400;
			return res;
		}
		Decimal timeInput = Decimal.valueOf((String)params.get('hours'));
		if (timeInput <= 0) {
			res.Error_Code = 'BAD_PARAMETER';
			res.message = 'Hours must be greater than zero.';
			RestContext.response.statusCode = 400;
			return res;
		}

		
		String contactEmail = String.escapeSingleQuotes((String) params.get('contact'));
		String projectId = String.escapeSingleQuotes((String) params.get('project'));
		
		List<Project_Member__c> projectMember = new List<Project_Member__c>();

		projectMember = [SELECT Id, Contact__c FROM Project_Member__c 
							WHERE Project__c = :projectId AND 
							Project__r.Status__c != 'Archived' AND
							Contact__r.Email = :contactEmail AND 
							Status__c = 'Active'];

		if(projectMember.isEmpty()) {
			res.Error_Code = 'PROJECT_MEMBER_NOT_FOUND';
			res.message = 'Must be an active project member on an non archived project to submit time.';
			RestContext.response.statusCode = 404;
			return res;
		}

		Date timeDate = System.today();
		if (params.containsKey('date')) {
			System.debug(params.get('date'));
			timeDate = Date.valueOf((String) params.get('date'));
		}

		String entryType = '';
		if (params.containsKey('type')) {
			entryType = String.escapeSingleQuotes((String) params.get('type'));
		}


		Time_Entry__c timeEntryRecord = new Time_Entry__c(Id = (String)params.get('id'), 
											Contact__c = projectMember[0].Contact__c, 
											Project__c = projectId,
											Date__c = timeDate,
											Hours__c = timeInput,
											Type__c = entryType,
											Description__c = (String)params.get('description'));
		
		try {
			upsert timeEntryRecord;
		} catch (Exception ex) {
			res.Error_Code = 'INSERT_OR_UPDATE_FAILED';
			res.message = ex.getMessage();
			RestContext.response.statusCode = 400;
			return res;
		}
		res.Time_Entry_Records.add(timeEntryRecord);
		res.Number_Of_Time_Records = 1;
		RestContext.response.statusCode = 201;
		return res;
	
	}

	@HttpDelete
	global static TimeEntryResult deleteTimeEntry() {
		RestRequest req = RestContext.request;
		TimeEntryResult res = new TimeEntryResult();

        Map<String, String> params =  req.params;

		Boolean RequiredValuesFound = params.containsKey('Id');
		
		if (!RequiredValuesFound) {
			res.Error_Code = 'REQUIRED_FIELD_MISSING';
			res.message = 'Id is a required parameter.';
			RestContext.response.statusCode = 400;
			return res;
		}

		String timeEntryId = String.escapeSingleQuotes(params.get('Id'));

		try {
			Time_Entry__c t = new Time_Entry__c(Id = timeEntryId);
			delete t;
		} catch (Exception ex) {
			res.Error_Code = 'DELETE_FAILED';
			res.message = ex.getMessage();
			RestContext.response.statusCode = 400;
			return res;
		}
		res.Number_Of_Time_Records = 1;
		res.Message = 'Record deleted.';
		RestContext.response.statusCode = 200;
		return res;

	}
	global class TimeEntryResult {
		 public Integer Number_Of_Time_Records = 0;
		 public List<Time_Entry__c> Time_Entry_Records = new List<Time_Entry__c>();
		 public String Message;
		 public String Error_Code; 
	}
}