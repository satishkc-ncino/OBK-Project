/** 
 * @description       : Enhanced version of Email to Lead Handler class which creates leads from incomming emails.
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 06-02-2021
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


        //Logic to extract the Lead Queue 
        //Change this to Custom Metadata Settings.
        //String infomail = 'infoobkau@2ydwid7iqzb5s4vqzmdxauhf1j9jeeu86yfqyy0u7g7cyww70y.9d-8cruuaq.cs76.apex.sandbox.salesforce.com';
        String enqmail = 'enqoobkau@5-1zqeo8b69j9hgp4p91kkzjaoraomkygto2ujil2sxzall03bz0.9d-8cruuaq.cs76.apex.sandbox.salesforce.com';

        obk_EmailtoLead__mdt[] eIds = [SELECT ID, MasterLabel, SF_Email_Id__c FROM obk_EmailtoLead__mdt WHERE Label = 'InfoMailbox'];
        String infomail = eIds[0].SF_EMAIL_ID__c;
        System.Debug(infomail);



        // Logic: Check for existing leads with this email address 
        try{
            Lead[] leads = [SELECT Id, Name, Email
            FROM Lead
            WHERE Email = :email.fromAddress WITH Security_Enforced LIMIT 1];
            System.debug(leads.size());

            if (leads.size() == 0) { 

                //Check for Contacts
                Contact[] con = [SELECT Id, Name, Email FROM Contact WHERE Email =: email.fromAddress WITH Security_Enforced LIMIT 1];
                System.debug(con.size());
                if(con.size() == 0){
                    
                    //Logic to Set Enquiry Type
                    String type = (String.valueOf(env.toAddress)==String.valueOf(infomail)) ? 'General' : 'Custom Event';
                    
                    //Setting DML Options for Auto Lead Assignment Trigger
                    AssignmentRule ar = new AssignmentRule();
                    ar = [SELECT id FROM AssignmentRule WHERE sObjectType = 'Lead' and Active = true WITH SECURITY_ENFORCED LIMIT 1];
                    Database.DMLOptions dmlopts = new Database.DMLOptions();
                    dmlopts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;

                    // Insert a new lead
                    Lead newLead = new Lead(Email = email.fromAddress, 
                    LastName = email.fromName, 
                    Company = 'From Email',
                    LeadSource = 'Email',
                    Enquiry_Type__c = type, 
                    Description = myPlainText);
                    if(Schema.SObjectType.Lead.isCreateable()){
                        newLead.setOptions(dmlopts);
                        insert newLead;
                    }
                }
                else if(con.size() > 0){

                    if(Schema.SObjectType.Task.isCreateable() && Schema.SObjectType.Contact.isUpdateable()){
                        System.debug('Incoming email duplicates existing Contact record(s): ' + con );
                        //Also Create a Task to followup.
                        Task[] newTask = new Task[0];
                        newTask.add(new Task(Description = myPlainText,
                        Priority = 'Normal',
                        Status = 'Inbound Email',
                        Subject = email.subject,
                        IsReminderSet = true,
                        ReminderDateTime = System.now()+1,
                        ActivityDate = System.today()+2,
                        WhoId = con[0].Id));
                        // Insert the new Task 
                        insert newTask;
                        System.debug('New Task Object: ' + newTask);
                    }
                }
                
            }
            else if(leads.size()>0)
            {
                System.debug('Incoming email duplicates existing Lead record(s): ' + leads );
                //Update Lead with new info
                if(Schema.SObjectType.Task.isCreateable() && Schema.SObjectType.Lead.isUpdateable()){
                    Lead updatelead = [SELECT Id, Description,Enquiry_Type__c, LeadSource  FROM Lead WHERE Id =: leads[0].Id];
                    updatelead.Description = updatelead.Description + '\n' + 'New Update :'+ myPlainText;
                    updatelead.Enquiry_Type__c = String.isBlank(updatelead.Enquiry_Type__c) ? 'General' : updatelead.Enquiry_Type__c ; 
                    updatelead.LeadSource = String.isBlank(updatelead.LeadSource) ? 'Email' : updatelead.LeadSource;
                    
                    update updatelead;
                    //Also Create a Task to followup.
                    Task[] newTask = new Task[0];
                    newTask.add(new Task(Description = myPlainText,
                    Priority = 'Normal',
                    Status = 'Inbound Email',
                    Subject = email.subject,
                    IsReminderSet = true,
                    ReminderDateTime = System.now()+1,
                    ActivityDate = System.today()+2,
                    WhoId = leads[0].Id));
                    // Insert the new Task 
                    insert newTask;
                    System.debug('New Task Object: ' + newTask );
                }
            }
        }
        catch(System.QueryException qe){
            System.Debug(qe.getMessage());
        }

    // Set the result to true. No need to send an email back to the user with an error message 
    result.success = true;

    // Return the result for the Apex Email Service 
    return result;
    }
}
