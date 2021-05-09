/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 05-09-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-09-2021   Satish Chandrashekar   Initial Version
**/
@isTest
private with sharing class CreateEmailtoLeadLiteTest {
    @isTest(SeeAllData = true)
    private static void singleLead(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';

        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        System.assertEquals(result.success, true, 'Test Success');
    }

    @isTest
    private static void duplicateLead(){
        Lead newLead = new Lead(
        Email = 'TestLead@gmail.com', 
        LastName = 'Testing Admin', 
        Company = 'From Email');
        insert newLead;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';

        Lead[] testLead = [SELECT Id, Name, Email
        FROM Lead
        WHERE Email = 'TestLead@gmail.com' WITH Security_Enforced LIMIT 1];
        System.Debug('Lead Size is' + testLead.size());
        Id lid = testLead[0].Id;

        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        
        Task[] newTask = new Task[0];
        newTask.add(new Task(Description = 'myPlainText',
        Priority = 'Normal',
        Status = 'Inbound Email',
        Subject = 'TestForLead',
        IsReminderSet = true,
        ReminderDateTime = System.now()+1,
        WhoId = newLead.Id));
        insert newTask;

        Task testtask = [SELECT ID,WhoId, Subject FROM Task WHERE WhoId =: lid WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 1];
        System.Debug(testtask.Id + testtask.Subject);
        System.assertEquals(result.success, true, 'Test Success');
        System.assertEquals(testtask.Subject , 'TestForLead', 'Task Created Successfully');
    }

    

    @isTest
    private static void errortest(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Chatter Free User']; 
        User u = new User(Alias = 'standt', Email='standarduser@playful-koala-lqrcxl-dev-ed.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@playful-koala-lqrcxl-dev-ed.com'); 
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'Test';
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Mr. SIT Tester';
        
        System.runAs(u){
        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        System.assertEquals(true, result.success, 'Query Exception'); 
        } 
    }
}
