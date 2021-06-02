/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 05-16-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-09-2021   Satish Chandrashekar   Initial Version
**/
@isTest
private with sharing class CreateEmailtoLeadLiteTest {
    @isTest
    private static void singleLead(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';
        
        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        
        Test.startTest();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        System.assertEquals(result.success, true, 'Test Success');
        Test.stopTest();
    }
    
    @isTest (SeeAllData = true)
    private static void duplicateLead(){
        /*Lead newLead = new Lead(
        Email = 'TestLead@gmail.com', 
        LastName = 'Testing Admin', 
        Company = 'From Email');
        insert newLead;*/

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'satish.chandrashekar@ncino.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';

        /*Lead[] testLead = [SELECT Id, Name, Email FROM Lead WHERE Email = 'TestLead@gmail.com'];
        System.Debug('Lead Size is' + testLead.size());
        Id lid = testLead[0].Id;*/

        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Test.startTest();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();
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
        
        Test.startTest();
            System.runAs(u){
            CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
            Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(true, result.success, 'Query Exception'); 
            }
        Test.stopTest(); 
    }

    @isTest (SeeAllData = true)
    private static void duplicateContact(){
        
        /* List<Contact> conlist = new List<Contact>();

        Contact con1 = new Contact(
        Email = 'TestLead@gmail.com', 
        LastName = 'Testing Admin');
        conlist.add(con1);

        Contact con2 = new Contact(
        Email = 'SKCTestLead@gmail.com', 
        LastName = 'SKCTesting Admin');
        conlist.add(con2);

        insert conlist; */

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'satish.chandrashekar@ncino.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';

        /* List<Contact> testContact = [SELECT Id, Name, Email FROM Contact WHERE Email = 'satish.chandrashekar@ncino.com'];
        Integer cid = testContact.size(); */
        
        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Test.startTest();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        Test.stopTest();
    }

    @isTest (SeeAllData = true)
    private static void duplicateContact1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'sysadmin', Email='sysadmin@playful-koala-lqrcxl-dev-ed.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sysadmin@playful-koala-lqrcxl-dev-ed.com'); 
        

        List<Contact> conlist = new List<Contact>();

        Contact con1 = new Contact(
        Email = 'TestLead@gmail.com', 
        LastName = 'Testing Admin');
        conlist.add(con1);

        Contact con2 = new Contact(
        Email = 'SKCTestLead@gmail.com', 
        LastName = 'SKCTesting Admin');
        conlist.add(con2);

        insert conlist; 

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'myPlainText';
        env.fromAddress = 'satish.chandrashekar@ncino.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';

        Test.startTest();
        System.runAs(u){
        CreateEmailtoLeadLite emailServiceObj = new CreateEmailtoLeadLite();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
        System.assertEquals(true, result.success, 'Task Created for Contact'); 
        }
        Test.stopTest();
    }
}
