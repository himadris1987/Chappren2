@isTest
public class CWLeadControllerTests {
    static testMethod void testLead() {
        
        Lead newLead = new Lead(firstName = 'Test', lastName = 'Lead', email = 'test@test.com', phone = '1234567890', company = 'hi');
        cwLeadController nL = new cwLeadController();
        nL.createNewLead();
        insert newLead;
        string leadCompany = 'hi';
        string newEmail = 'test@test.com';
        system.assertEquals(newLead.email, newEmail);
        system.assertEquals(newLead.company, leadCompany);
    }
}