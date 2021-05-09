/**
 * @description       : Enhanced version of Email to Lead Handler class which creates leads from incomming emails.
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 05-09-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-09-2021   Satish Chandrashekar   Initial Version
**/
global with sharing class CreateEmailtoLeadLite implements Messaging.InboundEmailHandler{
    
    //Function with Logic to map to the default Owner
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';
        String fromid = email.fromAddress;
        myPlainText = email.plainTextBody;

        // Logic 1: Check for existing leads with this email address 
        try{
            Lead[] leads = [SELECT Id, Name, Email
            FROM Lead
            WHERE Email = :email.fromAddress WITH Security_Enforced LIMIT 1];
            System.debug(leads.size());

            if (leads.size() == 0) { 
                    // Insert a new lead
                    if(Schema.SObjectType.Lead.isCreateable()){
                        Lead newLead = new Lead(Email = email.fromAddress, 
                        LastName = email.fromName, 
                        Company = 'From Email');
                        insert newLead;
                    }
            }
            else 
            {
                System.debug('Incoming email duplicates existing Lead record(s): ' + leads );
                Task[] newTask = new Task[0];
                newTask.add(new Task(Description = myPlainText,
                Priority = 'Normal',
                Status = 'Inbound Email',
                Subject = email.subject,
                IsReminderSet = true,
                ReminderDateTime = System.now()+1,
                WhoId = leads[0].Id));
                // Insert the new Task 
                insert newTask; 
                System.debug('New Task Object: ' + newTask );
            }
        }
        catch(System.QueryException qe){
            System.Debug(qe.getMessage());
        }

    // Set the result to true. No need to send an email back to the user 
    // with an error message 
    result.success = true;

    // Return the result for the Apex Email Service 
    return result;
    }

    //Function with Logic to map the right queue.
    /*global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';
        String fromid = email.fromAddress;
        myPlainText = email.plainTextBody;
        
        //Criteria of Email Box
        String infobox = 'info@obk.org.au';
        String enquirybox = 'enquiry@obk.org.au';

        // Logic: Check for existing leads with this email address 
        try{
            Lead[] leads = [SELECT Id, Name, Email
            FROM Lead
            WHERE Email = :email.fromAddress WITH Security_Enforced LIMIT 1];
            System.debug(leads.size());


            String lname = email.fromName;
            String emailid = email.fromAddress;
            List<String> emids = email.toAddresses;
            String q = emids[0];
            System.Debug(lname + ' ' + emailid + ' ' + fromid + ' ');

            if (leads.size() == 0) { 
                //Check Criteria to Assign the lead to the right Queue
                if(q == infobox){
                    List<Group> qids = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Genaral_Enquiries'];
                    Id qid = qids[0].Id;
                    createLead(qid, lname, emailid);
                }
                else if(q == enquirybox){
                    List<Group> qids = [SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'Event_Enquiry_Queue'];
                    Id qid1 = qids[0].Id;
                    createLead(qid1, lname, emailid);
                }
                else{
                    Id qid3 = null;
                    createLead(qid3, lname, emailid);
                }
            }
            else 
            {
                System.debug('Incoming email duplicates existing Lead record(s): ' + leads );
                Task[] newTask = new Task[0];
                newTask.add(new Task(Description = myPlainText,
                Priority = 'Normal',
                Status = 'Inbound Email',
                Subject = email.subject,
                IsReminderSet = true,
                ReminderDateTime = System.now()+1,
                WhoId = leads[0].Id));
                // Insert the new Task 
                insert newTask; 
                System.debug('New Task Object: ' + newTask );
            }
        }
        catch(System.QueryException qe){
            System.Debug(qe.getMessage());
        }

    // Set the result to true. No need to send an email back to the user 
    // with an error message 
    result.success = true;

    // Return the result for the Apex Email Service 
    return result;
    }

    global static String createLead(Id qid, String lname, String mailid){
    
        // Insert a new lead
        if(Schema.SObjectType.Lead.isCreateable() && qid != null){
            Lead newLead = new Lead(Email = mailid, 
            LastName = lname, 
            Company = 'From Email',
            OwnerId = qid);
            insert newLead;
        }
        else if(Schema.SObjectType.Lead.isCreateable() && qid == null){
            Lead newLead = new Lead(Email = mailid, 
            LastName = lname, 
            Company = 'From Email');
            insert newLead;
        }
        
        return 'Success';
    }*/
}
