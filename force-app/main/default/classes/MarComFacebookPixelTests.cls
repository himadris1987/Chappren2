@isTest
public class MarComFacebookPixelTests {
   
    
    @IsTest
    public static void testGetIpAddressTrueClient() {
        PageReference test = new PageReference('www.salesforce.com');
        test.getHeaders().put('True-Client-IP', '192.168.1.1');
        System.AssertEquals('192.168.1.1',MarComFacebookPixel.getIpAddress(test));  
    }
    @isTest
    public static void testGetIpAddressXSalesforceSIP() {
        PageReference test = new PageReference('www.salesforce.com');
        test.getHeaders().put('X-Salesforce-SIP', '192.168.1.1');
        System.AssertEquals('192.168.1.1',MarComFacebookPixel.getIpAddress(test));  
    }

    @isTest
    public static void testGetIpAddressXForwardedFor() {
        PageReference test = new PageReference('www.salesforce.com');
        test.getHeaders().put('X-Forwarded-For', '192.168.1.1');
        System.AssertEquals('192.168.1.1',MarComFacebookPixel.getIpAddress(test));  
    }

    @isTest
    public static void testWFTRegistrationVisit() {
        PageReference testPage = new PageReference('www.salesforce.com');
        testPage.getHeaders().put('X-Salesforce-SIP', '192.168.1.1');
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('MarComFacebookPixelMock');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        HttpResponse res = MarComFacebookPixel.WFTRegistrationVisit(testPage, '250.00');
        System.assertEquals(200, res.getStatusCode());
        Test.stopTest();
    }
    
}