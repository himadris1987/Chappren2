public class AddressUtility {
    public static String getMarket(String postalCode) {
        List<Market__c> markets =  new List<Market__c>();
        markets = [SELECT Id, Name, PostalCodes__c 
                   FROM Market__c Where Status__c = 'Active'];
        
		if (markets.isEmpty()) {
            System.debug('No active markets were found');
            return 'Other';
        }
		
		List<String> postalCodes = new List<String>();
		postalCode = postalCode.deleteWhitespace();
        
		for (Market__c market : markets) {
			market.PostalCodes__c = market.PostalCodes__c.deleteWhitespace();
			postalCodes = market.PostalCodes__c.split(',');
			
			if (postalCodes.contains(postalCode)) {
				return market.Name;
			}
		}
        System.debug('Address Utility | No markets were found with postal code: ' + postalCode);	
		return 'Other';
    }
    
    public static String getPublicKnowledgeMarket(String postalCode) {
        List<Market__c> markets =  new List<Market__c>();
        markets = [SELECT Id, Name, PostalCodes__c 
                   FROM Market__c Where Status__c = 'Active' AND Public_Knowledge__c = true];
        
		if (markets.isEmpty()) {
            System.debug('No active public markets were found');
            return 'Other';
        }
		
		List<String> postalCodes = new List<String>();
		postalCode = postalCode.deleteWhitespace();
        
		for (Market__c market : markets) {
			market.PostalCodes__c = market.PostalCodes__c.deleteWhitespace();
			postalCodes = market.PostalCodes__c.split(',');
			
			if (postalCodes.contains(postalCode)) {
				return market.Name;
			}
		}
        System.debug('Address Utility | No markets were found with postal code: ' + postalCode);	
		return 'Other';
    }
	
	@InvocableMethod(label='Get Market by Postal Code' description='Returns the Market Name for the provided Postal Code.' category='Market')
	public static List<String> getMarket(List<String> postalCodes) {
        List<Market__c> markets =  new List<Market__c>();
        List<String> marketNames = new List<String>();
      
        if(postalCodes == null || postalCodes.isEmpty()) {
            System.debug('PostalCodes was empty or null');
            return null;
        }
        
        markets = [SELECT Id, Name, PostalCodes__c 
                   FROM Market__c Where Status__c = 'Active'];
 
		if (markets.isEmpty()) {
            System.debug('No active markets were found');
            return null;
        }

        Integer postalCodeCounter = 0;
        
        for (String postalCode : postalCodes) {
            System.debug(postalCode);	 
            postalCode = postalCode.deleteWhitespace();
              
            if (String.isBlank(postalCode)) {
                marketNames.add('Other'); 
                continue;
            }

            postalCodeCounter++;
            for (Market__c market : markets) {
                
                market.PostalCodes__c = market.PostalCodes__c.deleteWhitespace();
                List<String> postalCodesFromMarket = market.PostalCodes__c.split(',');
                
                if (postalCodesFromMarket.contains(postalCode)) {
                    marketNames.add(market.Name);
                    break;
                }  
			}
            if (marketNames.size() < postalCodeCounter ) {
                marketNames.add('Other'); 
            }     
        }
		System.debug(marketNames);
        return marketNames;
    } 

    public static List<String> getUSStates() {
        List<String> states = new List<String>{'Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana','Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire','New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island','South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin','Wyoming'};
        return states;
    }

     public static List<SelectOption> getUSStatesSelectOptions() {
        List<String> stateStrings = getUSStates();
        List<SelectOption> states = new List<SelectOption>();
        states.add(new SelectOption('', 'State'));
        for (String state : stateStrings) {
            states.add(new SelectOption(state,state));
        }
        return states;
     }
}