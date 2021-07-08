/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 07-04-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   05-08-2021   Satish Chandrashekar   Initial Version
**/
global with sharing class CreateEmailtoLead implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';
        String fromid = email.fromAddress;
        myPlainText = email.plainTextBody;
        String infomail = 'infoobkau@2ydwid7iqzb5s4vqzmdxauhf1j9jeeu86yfqyy0u7g7cyww70y.9d-8cruuaq.cs76.apex.sandbox.salesforce.com';
        String enqmail = 'enqoobkau@5-1zqeo8b69j9hgp4p91kkzjaoraomkygto2ujil2sxzall03bz0.9d-8cruuaq.cs76.apex.sandbox.salesforce.com';


        // Logic 1: Check for existing leads with this email address 
        try{
            Lead[] leads = [SELECT Id, Name, Email
            FROM Lead
            WHERE Email = :email.fromAddress WITH Security_Enforced LIMIT 1];
            System.debug(leads.size());

            if (leads.size() == 0) { 
                // Logic 2: Check if there is a contact already
                Contact[] con = [SELECT Id, Name, Email FROM Contact WHERE Email =: email.fromAddress WITH Security_Enforced LIMIT 1];
                System.debug(con.size());
                if(con.size() == 0){
                    String toadd = env.toAddress;
                    String type;
                    if(toadd == infomail){
                        type = 'General';
                    }
                    else if(toadd == enqmail){
                        type = 'Custom Event';
                    }

                    // Insert a new lead
                    if(Schema.SObjectType.Lead.isCreateable()){
                        Lead newLead = new Lead(Email = email.fromAddress, 
                        LastName = email.fromName, 
                        Company = 'From Email',
                        LeadSource = 'Email',
                        Enquiry_Type__c = type, 
                        Description = myPlainText);
                        insert newLead;
                    }
                }
                else {
                    Task[] newTask = new Task[0];
                    newTask.add(new Task(Description = myPlainText,
                    Priority = 'Normal',
                    Status = 'Inbound Email',
                    Subject = email.subject,
                    IsReminderSet = true,
                    ReminderDateTime = System.now()+1,
                    WhoId = con[0].Id));
                    // Insert the new Task 
                    insert newTask; 
                    System.debug('New Task Object: ' + newTask );
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
}