public class AttachmentTriggerHandler extends TriggerHandler {
	private List<Attachment> newList;
	private List<Attachment> oldList;
	private Map<Id, Attachment> newMap;
	private Map<Id, Attachment> oldMap;

	public override void setupNewList() {
		newList = (List<Attachment>) newSObjList;
	}

	public override void setupNewMap() {
		newMap = new Map<Id, Attachment>(newList);
	}
   
    public override void onAfterUpdate() {
        makeFileDeleteAttachment();
    }
    
   public override void onAfterInsert() {
       makeFileDeleteAttachment();
    }

	public void makeFileDeleteAttachment() {
	   Set<Id> attachmentIdsToDelete = new Set<Id>();
       List<Attachment> attachmentsToDelete = new List<Attachment>();
       List<ContentVersion> contentVersions = new List<ContentVersion>();
	   List<ContentVersion> contentVersionsWithDocId = new List<ContentVersion>();  
	   
	   for (Attachment attach : newList) {
			//Insert ContentVersion
			ContentVersion cVersion = new ContentVersion();
			cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. 
			cVersion.PathOnClient = attach.Name;//File name with extention
			cVersion.Origin = 'H';//C-Content Origin. H-Chatter Origin.
			cVersion.OwnerId = attach.OwnerId;//Owner of the file
			cVersion.Title = attach.Name;//Name of the file
			cVersion.VersionData = attach.Body;//File content
		
			contentVersions.add(cVersion);
			attachmentsToDelete.add(attach);
		}

		insert contentVersions;

		Map<Id, Attachment> contentVersionMap = new Map<Id, Attachment>();

		for (Integer i = 0; i < contentVersions.size(); i++) {
			contentVersionMap.put(contentVersions[i].Id, attachmentsToDelete[i]);
		}

		contentVersionsWithDocId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id IN: contentVersions];

		//System.debug(contentVersionsWithDocId);
		List<ContentDocumentLink> contentDocLinks = new List<ContentDocumentLink>();

		for(ContentVersion cVersion : contentVersionsWithDocId) {
			ContentDocumentLink cDocLink = new ContentDocumentLink();
        	cDocLink.ContentDocumentId = cVersion.ContentDocumentId; //Add ContentDocumentId
			cDocLink.LinkedEntityId = contentVersionMap.get(cVersion.Id).parentId; //Add attachment parentId
        	cDocLink.ShareType = 'I';//V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        	cDocLink.Visibility = 'InternalUsers';//AllUsers, InternalUsers, SharedUsers
			contentDocLinks.add(cDocLink);
		}
        insert contentDocLinks;

		List<Attachment> aReturned = new List<Attachment>();
		aReturned = [SELECT Id FROM Attachment Where Id IN: attachmentsToDelete];
		//System.debug(aReturned);
		delete aReturned;
	}
}