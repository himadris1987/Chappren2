@isTest
public class AddressUtilityTests {
    @TestSetup
    static void setup() {
		Market__c market = new Market__c(Name = 'Fresno',
								Public_Knowledge__c = true, 
								Status__c = 'Active', 
								PostalCodes__c = '93721,93725');
		insert market;
        
    }

	@isTest
	public static void getMarketTest() {
		System.assertEquals('Fresno', AddressUtility.getMarket('93721'));
	}
	@isTest
	public static void getPublicKnowledgeMarketTest() {
		System.assertEquals('Fresno', AddressUtility.getPublicKnowledgeMarket('93721'));
	}
	@isTest
	public static void getMarketTestMarketNotFound() {
		System.assertEquals('Other', AddressUtility.getMarket('937'));
	}

	@isTest
	public static void getMarketTestNoActiveMarkets() {
		Market__c market = [SELECT Id, Name, Status__c FROM Market__c WHERE Status__c = 'Active'];
		market.Status__c = 'Inactive';
		update market;
		System.assertEquals('Other', AddressUtility.getMarket('937'));
	}
    
    @isTest
	public static void getMarketInvocableNotFound() {
        
        List<String> postalCodes = new List<String>{'937'};
		List<String> marketNames = AddressUtility.getMarket(postalCodes);
		System.assertEquals('Other', marketNames[0]);
	}
    @isTest
    public static void getMarketInvocablePostalCodeFound() {
        
        List<String> postalCodes = new List<String>{'93721'};
		List<String> marketNames = AddressUtility.getMarket(postalCodes);
		System.assertEquals('Fresno', marketNames[0]);
	}
	@isTest
	 public static void getMarketInvocableMultiplePostalCodes() {
        
        List<String> postalCodes = new List<String>{'93721','93725'};
		List<String> marketNames = AddressUtility.getMarket(postalCodes);
		System.assertEquals(2, marketNames.size());
	}
	@isTest
	public static void getMarketInvocableBlankPostalCode() {
        
        List<String> postalCodes = new List<String>{'93721','','93725'};
		List<String> marketNames = AddressUtility.getMarket(postalCodes);
		System.assertEquals(3, marketNames.size());
	}
	 @isTest
	public static void getMarketInvocableNoMarkets() {
        
        List<String> postalCodes = new List<String>{'93721'};
		delete [SELECT Id FROM Market__c WHERE Name = 'Fresno'];
		System.assertEquals(null, AddressUtility.getMarket(postalCodes));
	}

	 @isTest
	public static void getMarketInvocableInputNull() {
		 List<String> postalCodes;
		System.assertEquals(null, AddressUtility.getMarket(postalCodes));
	}

	
	@isTest
	public static void getUSStatesTest() {
		System.assertEquals(50, AddressUtility.getUSStates().size());
	}

	@isTest
	public static void getUSStatesSelectOptionsTest() {
		System.assertEquals(51, AddressUtility.getUSStatesSelectOptions().size());
	}
}