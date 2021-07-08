/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 07-07-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   07-06-2021   Satish Chandrashekar   Initial Version
**/
@isTest
public with sharing class TestDataFactory {

    public static Map<String,String> leaddetails(){
        
        Map<String,String> leads = new Map<String,String>();
        leads.put('FirstName', 'Testing');
        leads.put('LastName', 'Admin');
        leads.put('Email', 'testlead@gmail.com');
        leads.put('Company', 'Testing Admin');
        leads.put('Subject', 'TestFor DirectLead');
        leads.put('Description', 'myPlainText');
        
        return leads;
    }

    public static User createUser(String str){

        String profileName;
        if(str == 'Admin'){
            profileName = 'System Administrator';
        }
        else{
            profileName = 'Chatter Free User';
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name=: profileName]; 
        User u = new User(Alias = 'sysadmin', Email='sysadmin@playful-koala-lqrcxl-dev-ed.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='sysadmin@playful-koala-lqrcxl-dev-ed.com'); 
        insert u;

        return u;
    }

    public static Messaging.InboundEmail testemail(){
        
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        email.subject = 'TestForLead';
        email.plainTextBody = 'Test';
        email.fromName = 'Mr. SIT Tester';

        return email;
    } 

    public static Messaging.InboundEnvelope testenvp(){
        
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        env.fromAddress = 'TestLead@gmail.com';
        env.toAddress = 'abc@123.in.salesforce.com';
        return env;
    }

    public static Lead createLead(){

        AssignmentRule ar = new AssignmentRule();
        ar = [SELECT id FROM AssignmentRule WHERE sObjectType = 'Lead' and Active = true WITH SECURITY_ENFORCED LIMIT 1];
        Database.DMLOptions dmlopts = new Database.DMLOptions();
        dmlopts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;

        Lead newLead = new Lead(Email = 'testlead@gmail.com', 
        LastName = 'Admin',
        FirstName = 'Testing', 
        Company = 'Testing Admin',
        LeadSource = 'Email',
        Enquiry_Type_Queue__c = 'General', 
        Description = 'Testing Description is too long');
        
        newLead.setOptions(dmlopts);
        insert newLead;
        
        return newLead;
    }

    public static Contact createContact(User u){
        
        Contact con1 = new Contact(
        Email = 'testlead@gmail.com', 
        LastName = 'Testing Admin',
        OwnerId = u.Id);
        insert con1;

        return con1;
    }

    public static Task createLeadTask(Lead l){

        Task newTask = new Task(Description = 'Testing Description',
        Priority = 'Normal',
        Status = 'Inbound Email',
        Subject = 'Testing Subject',
        IsReminderSet = true,
        //OwnerId = tempOwner, 
        ReminderDateTime = System.now()+1,
        ActivityDate = System.today()+2,
        WhoId = l.Id);
        // Insert the new Task 
        insert newTask;

        return newTask;
    }

    public static Task createContactTask(Contact c){

        Task newTask = new Task(Description = 'Testing Description',
        Priority = 'Normal',
        Status = 'Inbound Email',
        Subject = 'Testing Subject',
        IsReminderSet = true,
        OwnerId = c.OwnerId, 
        ReminderDateTime = System.now()+1,
        ActivityDate = System.today()+2,
        WhoId = c.Id);
        // Insert the new Task 
        insert newTask;

        return newTask;
    }


}
