/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   07-05-2021   Satish Chandrashekar   Initial Version
 * 1.1   15-08-2021   Satish Chandrashekar   Donation Logic Test Methods
 * 1.2   12-10-2021   Satish Chandrashekar   Deprecated Donation Logic Test
**/

@isTest
private with sharing class EmailtoLeadExtendedTest {

    //All Testcases supporting  EmailtoLeadHandler Class
    @isTest
    private static void createleadTest(){
        
        Map<String, String> leaddetails = TestDataFactory.leaddetails();
        String email = leaddetails.get('Email');
        String type = 'General';
        User u = TestDataFactory.createUser('Admin');

        System.runAs(u){
            test.startTest();
            EmailtoLeadHandler.createLead(leadDetails, type);
            test.stopTest();
            Lead l = [SELECT Id, Email FROM Lead WHERE Email =:email];
            System.assertEquals(email, l.Email, 'Lead Created');
        }
    }

    @isTest
    private static void noleadandcontacttest(){

        Map<String,String> details = TestDataFactory.leaddetails();
        String type = 'General';
        User u = TestDataFactory.createUser('Admin');
        
        System.runAs(u){
            test.startTest();
            String msg = EmailtoLeadHandler.duplicateCheck(details, type);
            test.stopTest();
            System.assertEquals('Lead Created', msg, 'NO Duplicates Test  Success');
        }
    }

    @isTest
    private static void duplicateleadtest(){

        Map<String,String> details = TestDataFactory.leaddetails();
        String type = 'General';
        User u = TestDataFactory.createUser('Admin');
        Lead l = TestDataFactory.createlead();
        Id leadid = l.id;
        
        System.runAs(u){
            test.startTest();
            String msg = EmailtoLeadHandler.duplicateCheck(details, type);
            test.stopTest();
            Task t = [SELECT Id, WhoId FROM Task WHERE WhoId =: leadid];
            System.assertEquals('Task created under Lead', msg, 'Duplicate Lead Test Success');
            System.assertEquals(leadid, t.WhoId, 'Task Successfully Created for Duplicate Lead');
        }
    }

    @isTest
    private static void duplicatecontacttest(){

        Map<String,String> details = TestDataFactory.leaddetails();
        String type = 'General';
        User u = TestDataFactory.createUser('Admin');
        Contact c = TestDataFactory.createContact(u);
        Id conid = c.id;
        
        System.runAs(u){
            test.startTest();
            String msg = EmailtoLeadHandler.duplicateCheck(details, type);
            test.stopTest();
            Task t = [SELECT Id, WhoId FROM Task WHERE WhoId =: conid];
            System.assertEquals('Task created under Contact', msg, 'Duplicate Lead Test Success');
            System.assertEquals(conid, t.WhoId, 'Task Successfully Created for Duplicate Contact');
        }
    }

    @isTest
    private static void forwardlogictest(){
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = '(\n ________________________________\n From: Satish Krishnamurthy Chandrashekar <satish.chandrashekar@ncino.com>\n Sent: Friday, 2 July 2021 5:34:18 PM (UTC+10:00) Canberra, Melbourne, Sydney\n To: Info <info@obk.org.au>\n Subject: Test Body of Email - 2\n \n \n FIRST UAT TEST MAIL)';
        env.fromAddress = 'info@obk.org.au';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';
        String originalMail = 'satish.chandrashekar@ncino.com';
        
        Test.startTest();
        Map<String,String> logicresult = EmailtoLeadHandler.forwardEmailLogic(email);
        String emailid = logicresult.get('Email');
        System.assertEquals(emailid, originalMail, 'Test Success');
        Test.stopTest();
    }


    //All Test Cases supporting EmailtoLeadExtended Class
    @isTest
    private static void errortest(){
        
        User u = TestDataFactory.createUser('Standard');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = 'Test';
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Mr. SIT Tester';
        
        Test.startTest();
            System.runAs(u){
            EmailtoLeadExtended emailServiceObj = new EmailtoLeadExtended();
            Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(true, result.success, 'Query Exception'); 
            }
        Test.stopTest(); 
    }

    @isTest
    private static void forwardmailtest(){
        User u = TestDataFactory.createUser('Admin');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = '(\n ________________________________\n From: Satish Krishnamurthy Chandrashekar <satish.chandrashekar@ncino.com>\n Sent: Friday, 2 July 2021 5:34:18 PM (UTC+10:00) Canberra, Melbourne, Sydney\n To: Info <info@obk.org.au>\n Subject: Test Body of Email - 2\n \n \n FIRST UAT TEST MAIL)';
        env.fromAddress = 'info@obk.org.au';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';
        String originalMail = 'satish.chandrashekar@ncino.com';
        
        EmailtoLeadExtended emailServiceObj = new EmailtoLeadExtended();
        
        Test.startTest();
            System.runAs(u){    
            Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(true, result.success, 'Forward Value');

            }
        Test.stopTest(); 
    }

    /* Deprecating Unused Test Methods
    @isTest
    private static void donationsLogicTest(){
        User u = TestDataFactory.createUser('Admin');

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'TestForLead';
        email.plainTextBody = TestDataFactory.donationemailtest();
        env.fromAddress = 'notifications@typeform.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        email.fromName = 'Testing Admin';
        String originalMail = 'satish.chandrashekar@ncino.com';
        
        EmailtoLeadExtended emailServiceObj = new EmailtoLeadExtended();
        
        Test.startTest();
            System.runAs(u){    
            Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env);
            System.assertEquals(true, result.success, 'Donation Email Success');

            }
        Test.stopTest(); 
    } */

}