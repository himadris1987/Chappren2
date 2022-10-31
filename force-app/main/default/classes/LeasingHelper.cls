public class LeasingHelper {
        @InvocableMethod
		public static List<List<Space__c>> getSpacesFromLeaseSpaces(List<List<Lease_Space__c>> leaseSpaces) {
            List<Id> spaceIds = new List<Id> ();
            List<Lease_Space__c> leaseSpaceSingleList = new List<Lease_Space__c>();
            leaseSpaceSingleList = leaseSpaces[0];
            for (Lease_Space__c singleLeaseSpace : leaseSpaceSingleList) {
                spaceIds.add(singleLeaseSpace.Space__c);
            }
            List<Space__c> relatedSpacesSingleList = new List <Space__c>();
            relatedSpacesSingleList = [SELECT Id FROM Space__c WHERE Id IN :spaceIds];
            List<List<Space__c>> relatedSpaces =  new List<List<Space__c>>();
            relatedSpaces.add(relatedSpacesSingleList);
            return relatedSpaces;
        }
}