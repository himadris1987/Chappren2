@isTest
public class LeasingHelperTest {
	
	@isTest
    public static void testLeaseSpaces() {
      
        Space__c spa = new Space__c(Name = 'Test', Status__c = 'New'); 
	   insert spa;

	   Account acc = new Account(Name = 'testAcc');
	   insert acc;

	   Contact con = new Contact(AccountId = acc.Id, LastName = 'Tester');
	   insert con;

	   Opportunity opp = new Opportunity(Name = 'testOpp', AccountId = acc.Id, Industry__c = 'Media', 
						 CloseDate = date.today(), StageName = 'New', ForecastCategoryName = 'Omitted', 
						 Primary_Contact__c = con.Id);
	   insert opp;

	   Lease_Space__c leaseSpace = new Lease_Space__c(Opportunity__c = Opp.Id, Space__c = spa.Id);		
	   insert leaseSpace;
	
	   List<Lease_Space__c> leaseList = new List<Lease_Space__c>();
       leaseList.add(leaseSpace);
       
       List<List<Lease_Space__c>> leaseSpaceWrapper = new List<List<Lease_Space__c>>();
       leaseSpaceWrapper.add(leaseList);
        
       List<List<Space__c>> spaceWrapper = LeasingHelper.getSpacesFromLeaseSpaces(leaseSpaceWrapper);
   
       
       System.assertEquals(spa.Id, spaceWrapper[0].get(0).Id);
    }
}