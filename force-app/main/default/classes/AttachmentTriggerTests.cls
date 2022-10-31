@isTest
public class AttachmentTriggerTests {
    @isTest
    public static void newAttachment() {
		Attachment attachment = new Attachment();
		attachment.Body = Blob.valueOf('Hello World!');
    	attachment.Name = String.valueOf('test.txt');
        
        Account act = new Account();
        act.Name = 'Test';
        
        insert act;
        
        act = [SELECT Id, Name FROM Account Where Name = 'Test'];
        
        attachment.ParentId = act.Id;
        
        insert attachment;
        
       	List<Attachment> attach = [SELECT Id, Name FROM Attachment Where Name='test.txt'];
        
        System.AssertEquals(0, attach.size());
    }
}