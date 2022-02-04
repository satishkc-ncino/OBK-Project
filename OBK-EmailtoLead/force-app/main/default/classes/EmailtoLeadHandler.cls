/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   07-03-2021   Satish Chandrashekar   Initial Version
 * 1.1   15-08-2021   Satish Chandrashekar   Added the Donation Capture Logic
 * 1.2   12-10-2021   Satish Chandrashekar   Deprecated the Donation Email Capture Logic and Added logic to duplicateCheck function
**/
public with sharing class EmailtoLeadHandler {
    
    //variables
    public String fName;
    public String lName;
    public String company;
    public String subject;
    public String description;
    public String eMailId;

    
    /* Function to Check Duplicate Lead or Contact*/
    //Change Log: 12-Oct-2021 : Added IsConverted and IsDeleted in SOQL Query WHERE Clasuse for both Lead and Contact
    public static String duplicateCheck(Map<String,String> details, String type){
        String tempid = details.get('Email');
        String msg;
        try{
            Lead[] leads = [SELECT Id, Name, Email, OwnerId, IsConverted, IsDeleted
            FROM Lead
            WHERE Email = :tempid AND IsConverted = false AND IsDeleted = false WITH Security_Enforced LIMIT 1];
            System.debug(leads.size());

            if(leads.size() == 0){
                Contact[] con = [SELECT Id, Name, Email, OwnerId, IsDeleted FROM Contact WHERE Email =: tempid AND IsDeleted = false WITH Security_Enforced LIMIT 1];
                if(con.size() == 0){
                    createLead(details, type);
                    msg = 'Lead Created';    
                }
                else{
                    System.debug('Incoming email duplicates existing Contact record(s): ' + con );
                    Map<String, Id> taskdetails = new Map<String,Id>();
                    taskdetails.put('OwnerId', con[0].OwnerId);
                    taskdetails.put('Id', con[0].Id);
                    //Create Task for Contact
                    createTask(taskdetails, details);
                    msg = 'Task created under Contact';
                }
            }
            else{
                System.debug('Incoming email duplicates existing Lead record(s): ' + leads );
                Map<String, Id> taskdetails = new Map<String,Id>();
                taskdetails.put('OwnerId', leads[0].OwnerId);
                taskdetails.put('Id', leads[0].Id);
                //Create Task for Lead
                createTask(taskdetails, details);
                msg = 'Task created under Lead';
            }
        }
        catch(System.QueryException qe){
            System.Debug(qe.getMessage());
        }

        return msg;
    }

    /* Function to map the lead Fields for Forwarded Email Logic directly from the Email Inbound Message Service
        Extract the Email Body and get the details of the original Email and hydrate details to create a lead & Task
    */
    public static Map<String,String> forwardEmailLogic(Messaging.inboundEmail email){
        
        //function variables
        String ffName;
        String flName;
        String fcompany;
        String fsubject;
        String fdescription;
        String feMailId;
        Map<String,String> fresults = new Map<String,String>();

        if(email.plainTextBody != Null && email.plainTextBody != ''){
            String[] emailBodyRows = email.plainTextBody.split('\n');
            System.Debug(emailBodyRows);
            for (String bodyRow:emailBodyRows) {
                String[] rowContents = bodyRow.split(':');
                System.Debug(JSON.serializePretty(rowContents));
                integer counter = rowContents.size();
                if(counter >1){
                        String label = rowContents[0].trim();
                        String value = rowContents[1].trim();
                        switch on label {
                            when 'From' {
                                feMailId = value.substringBetween('<','>');
                                System.Debug(feMailId);
                                String nt = value.remove(feMailId);
                                String nt1 = nt.remove('<');
                                String nt2 = nt1.remove('>');
                                String[] fullName = nt2.split(' ');
                                String firstName = fullName.size() > 0 ? fullName[0] : value;
                                integer i2 = (nt2.length() - firstName.length());
                                String lastName = nt2.right(i2);
                                ffName = firstName;
                                flName = lastName;
                                fcompany = firstName + ' ' + lastName;
                                System.Debug('First Name is  ' + firstName);
                                System.Debug('Last Name is  ' + lastName);                                                
                            }	
                            when 'Subject' {	
                                fsubject = value;
                                System.Debug('subject ' + value);
                            }
                        }//SWITCH
                }//IF
                else{ //Concatenate all the Descriptions
                    fdescription = fdescription + rowContents[0].trim();
                }
            }
        }
        fresults.put('FirstName', ffName);
        fresults.put('LastName', flName);
        fresults.put('Email', feMailId);
        fresults.put('Company', fcompany);
        fresults.put('Subject', fsubject);
        fresults.put('Description', fdescription);

        return fresults;           
        
    }

    // Function to map the Donations Email from Typeform
    // Extract the Email Body and get the details of the original Email and hydrate details to create a lead & Task
    //Decision was made to Discard this Development - Hence hiding this code
    /*public static Map<String,String> donationsLogic(Messaging.inboundEmail email){
        
        String dfName;
        String dlName;
        String dcompany;
        String dsubject;
        String ddescription;
        String deMailId;
        Map<String,String> dresults = new Map<String,String>();

        List<String> finallist = new List<String>();
        String[] emailBodyRows = email.plaintextbody.split('\n');
        System.Debug(emailBodyRows);
        string[] rowContents;
        integer counter;
        Map<String,String> countermap = new Map<String,String>();
        for (String bodyRow:emailBodyRows) {
                        rowContents = bodyRow.split('\\*');
                        System.Debug(JSON.serializePretty(rowContents));
                        counter = rowContents.size();
                        System.Debug(counter);	
        }

        for(String row:rowContents){
            string value = row.trim();
            integer full = value.length();
            integer s = value.lastindexOf('?');
            integer co = full - (s+1);
            String finalval = value.right(co);
            System.Debug(finalval);
            finallist.add(finalval);
        }

        dfName = finallist[1];
        dlName = finallist[2];
        String temp = finallist[6]; 
        System.debug(temp);
        integer c1 = temp.lastIndexOf('<');
        deMailId = temp.left(c1);
        dcompany = finallist[1] + ' ' + finallist[2];
        dsubject = finallist[0];
        ddescription = finallist[3] + '\n' + finallist[4] + '\n'  + finallist[5] + '\n' + finallist[7];


        dresults.put('FirstName', dfName);
        dresults.put('LastName', dlName);
        dresults.put('Email', deMailId);
        dresults.put('Company', dcompany);
        dresults.put('Subject', dsubject);
        dresults.put('Description', ddescription);
            
        System.debug(JSON.serializePretty(dresults));
        return dresults;

    } */


    // Function to map the lead Fields for Direct Email Logic directly from the Email Inbound Message Service
    public static Map<String,String> directEmailLogic(Messaging.inboundEmail email){

        //function variables
        String dfName;
        String dlName;
        String dcompany;
        String dsubject;
        String ddescription;
        String deMailId;
        Map<String,String> dresults = new Map<String,String>();

        dlName = email.fromName;
        deMailId = email.fromAddress;
        dcompany = email.fromName;
        dsubject = email.subject;
        ddescription = email.plainTextBody;

        dresults.put('FirstName', dfName);
        dresults.put('LastName', dlName);
        dresults.put('Email', deMailId);
        dresults.put('Company', dcompany);
        dresults.put('Subject', dsubject);
        dresults.put('Description', ddescription);

        return dresults;       

    }

    //Function to Create a Lead, Takes lead field values as Parameters from eithr Direct / Forwarded Email Logic functions
    public static void createLead(Map<String,String> leadDetails, String type){
        
        //Setting DML Options for Auto Lead Assignment Trigger
        AssignmentRule ar = new AssignmentRule();
        ar = [SELECT id FROM AssignmentRule WHERE sObjectType = 'Lead' and Active = true WITH SECURITY_ENFORCED LIMIT 1];
        Database.DMLOptions dmlopts = new Database.DMLOptions();
        dmlopts.AssignmentRuleHeader.AssignmentRuleId = ar.Id;

        // Insert a new lead
        Lead newLead = new Lead(Email = leadDetails.get('Email'), 
        LastName = leadDetails.get('LastName'),
        FirstName = leadDetails.get('FirstName'), 
        Company = leadDetails.get('Company'),
        LeadSource = 'Email',
        Enquiry_Type_Queue__c = type, 
        Description = leadDetails.get('Description'));
        if(Schema.SObjectType.Lead.isCreateable()){
            newLead.setOptions(dmlopts);
            insert newLead;
        }
    }

    //Function to Create a Task related to the Contact or Lead
    public static void createTask(Map<String,Id> obj, Map<String,String> taskdetails){
        
        System.Debug(JSON.serializePretty(obj));
        Id tempWho = obj.get('Id');
        Id tempOwner = obj.get('OwnerId');
        Boolean owner;

        //Logic to set the Task Owner
        String objName = tempOwner.getSObjectType().getDescribe().getName();
        System.Debug(objName);
        switch on objName{
            when 'User'{
                List<User> u = [SELECT Id, IsActive FROM User WHERE Id =:tempOwner WITH Security_Enforced];
                owner = u[0].IsActive;
            }
            when 'Group'{
                owner = false;
            }
        }

        if(owner == true){
            //Also Create a Task to followup.
            Task[] newTask = new Task[0];
            newTask.add(new Task(Description = taskdetails.get('Description'),
            Priority = 'Normal',
            Status = 'Inbound Email',
            Subject = taskdetails.get('Subject'),
            IsReminderSet = true,
            OwnerId = tempOwner, 
            ReminderDateTime = System.now()+1,
            ActivityDate = System.today()+2,
            WhoId = tempWho));
            // Insert the new Task 
            insert newTask;
            System.debug('New Task Object: ' + newTask);
        }
        else{
            //Also Create a Task to followup.
            Task[] newTask = new Task[0];
            newTask.add(new Task(Description = taskdetails.get('Description'),
            Priority = 'Normal',
            Status = 'Inbound Email',
            Subject = taskdetails.get('Subject'),
            IsReminderSet = true,
            //OwnerId = tempId, Lost of User / Queue issues need to be solved - Yummy Tech Debt for future releases
            ReminderDateTime = System.now()+1,
            ActivityDate = System.today()+2,
            WhoId = tempWho));
            // Insert the new Task 
            insert newTask;
            System.debug('New Task Object: ' + newTask);
        }
        
    }

}
