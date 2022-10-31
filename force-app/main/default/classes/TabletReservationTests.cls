@isTest
public class TabletReservationTests {
    static testMethod void testMethods() {
        account newAccount = new account(name = 'TestAccount');
        insert newAccount;
        contact newContact = new contact(firstName = 'test', lastName = 'tester', account = newAccount, email = 'test@test.com');
        insert newContact;
        //membership__c newMember = new membership__c(status__c = 'active', account__c = newAccount.id, contact__c = newContact.id, name = '123', Membership_Start_Date__c = system.TODAY(), Membership_End_Date__c = system.TODAY() + 30, type__c = 'individual');
        //insert newMember;
        space__c newSpace = new space__c(name = 'Test', status__c = 'available');
        insert newSpace;
        //reservation__c currentReservation = new reservation__c(contact__c = newContact.id, membership__c = newMember.id, space__c = newSpace.id, start__c = system.now(), end__c = system.now() + 1);
        //insert currentReservation;
		ApexPages.currentPage().getParameters().put('id', newSpace.id);
        TabletReservation tr = new TabletReservation();
		system.assertEquals(tr.getToday, system.today());
        system.assertEquals(tr.currentTime, system.now());
        system.assertEquals(tr.currentRoom.id, newSpace.id);
    }
}