public with sharing class LeaseAgreementTemplateController {
    public String ParkingIsHidden {get; set;}
    public String SignageIsHidden {get; set;}
    public String MiscIsHidden {get; set;}
    public String LeaseIsHidden {get; set;}
    public String DeskHotelIsHidden {get; set;}
    public String today {get; set;}
    public String oppId {get; set;}
    public Opportunity opp {get; set;}

    private String pdfName = 'LADHPSMX';

    public LeaseAgreementTemplateController(ApexPages.StandardController sc) {
        today = date.today().format();
        oppId = sc.getId();
        opp = [
            SELECT Id, Name, Parking_Addendum__c, Signage_Addendum__c, Misc_Addendum__c, RecordType.Name, Lease_Type__c, Month_to_Month__c,
                    Override_Leasing__c, Override_Parking__c, Override_Signage__c
            FROM Opportunity 
            WHERE Id = :oppId
            ];

        //applies "hidden" class to addendums/components that are not included
        if (opp.RecordType.Name != 'Leasing - Standard' || opp.Lease_Type__c == 'Desk Hotel') {
            LeaseIsHidden = 'hidden';
            pdfName = pdfName.remove('LA');
        } 
        if (opp.Lease_Type__c != 'Desk Hotel') {
            DeskHotelIsHidden = 'hidden';
            pdfName = pdfName.remove('DH');
        } 
        if (opp.Parking_Addendum__c == false && opp.Override_Parking__c == false) {
            ParkingIsHidden = 'hidden';
            pdfName = pdfName.remove('P');
        }
        if (opp.Signage_Addendum__c == false && opp.Override_Signage__c == false) {
            SignageIsHidden = 'hidden';
            pdfName = pdfName.remove('S');
        }
        if (opp.Misc_Addendum__c == false) {
            MiscIsHidden = 'hidden';
            pdfName = pdfName.remove('M');
        }
        if (opp.Lease_Type__c != 'Parking Only') {
            pdfName = pdfName.remove('X');
        }

    }

    //defines a method to attach a Lease Agreement PDF to the Opportunity record
    //this method will be called from the "AttachPDFToOpp" VF button
    public PageReference attachPDF() { 
        PageReference pdfPage = Page.LeaseAgreementTemplate;
        // PageReference pdfSuccess = Page.LeasePDFSuccess;
        pdfPage.getParameters().put('id',oppId); //specifies the Opp Id of the Lease Agreement Template
        Blob body; //creates a variable of the Blob data type
        body = (Test.isRunningTest()) ? Blob.valueOf('Test Body') : pdfPage.getContent(); 
        //sets the content of the "body" Blob to the content of the Lease Agreement Template

        //deletes old Content Document that is linked to Opp, if it exists
        try {
            List<Id> oldConDocIds = new List<Id>();
            List<ContentDocumentLink> conDocLinks = [
                SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :oppId
            ];
            for (ContentDocumentLink cdl : conDocLinks) {
                oldConDocIds.add(cdl.ContentDocumentId);
            }
            List<ContentDocument> oldConDocs = [
                SELECT Id FROM ContentDocument WHERE Id IN :oldConDocIds AND Title LIKE '%HS Template%'];
            delete oldConDocs;
        } catch (Exception ex) {

        }
                
        ContentVersion conVer = new ContentVersion(); //used to store the PDF, auto-creates a ContentDocument
        conVer.ContentLocation = 'S'; //determines where document is stored (Salesforce or External)
        conVer.PathOnClient = opp.Name + ' HS Template ' + pdfName + '.pdf'; //names the file
        conVer.Title = opp.Name + ' HS Template ' + pdfName; //sets the display name of the file
        conVer.VersionData = body; //sets the content of the file to the content of the "body" Blob
        insert conVer;

        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVer.Id].ContentDocumentId;
        //selects the Content Document using the id from the Content Version

        ContentDocumentLink conDocLink = new ContentDocumentLink();
        conDocLink.ContentDocumentId = conDoc;
        conDocLink.LinkedEntityId = oppId; //add the Opportunity as a linked entity
        conDocLink.ShareType = 'I'; //Inferred sharing (only users w/ access to the opp record can see the file)
        conDocLink.Visibility = 'AllUsers';
        insert conDocLink;
        PageReference oppPage = new PageReference('/' + oppId);
        return oppPage; //redirect user to current Opp
    }
}