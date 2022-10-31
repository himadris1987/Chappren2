@isTest
public class LeasePDFTest {
    static testMethod void TestClass() {
        // Id propId = Schema.SObjectType.Space__c.getRecordTypeInfosByName().get('Property').getRecordTypeId();
        // Space__c space = new Space__c(Name = 'BWSS', RecordTypeId = propId);
        // insert space;
        Opportunity opp = new Opportunity(Name = 'A Company', Parking_Addendum__c = false, Signage_Addendum__c = false,
                                          Misc_Addendum__c = false, StageName = 'Closed-Won', CloseDate = date.today(),
                                          Lease_Type__c = 'Desk Hotel');
        insert opp;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        LeaseAgreementTemplateController lc = new LeaseAgreementTemplateController(sc);
        lc.oppId = opp.Id;
        system.assertEquals(lc.LeaseIsHidden, 'hidden');
        system.assertEquals(lc.MiscIsHidden, 'hidden');
        system.assertEquals(lc.ParkingIsHidden, 'hidden');
        system.assertEquals(lc.SignageIsHidden, 'hidden');
                
        PageReference a = lc.attachPDF();
        List<ContentDocument> pdfList = [SELECT Id FROM ContentDocument];
        system.assertEquals(pdfList.size(), 1);
                
    }
    
    static testMethod void TestClass2() {
        Opportunity opp2 = new Opportunity(Name = 'A Company', Parking_Addendum__c = false, Signage_Addendum__c = false,
                                          Misc_Addendum__c = false, StageName = 'Closed-Won', CloseDate = date.today(),
                                          Lease_Type__c = 'Office - Personal');
        insert opp2;
        ApexPages.StandardController sc = new ApexPages.StandardController(opp2);
        LeaseAgreementTemplateController lc2 = new LeaseAgreementTemplateController(sc);
        lc2.oppId = opp2.Id;
        system.assertEquals(lc2.DeskHotelIsHidden, 'hidden');
    }
}