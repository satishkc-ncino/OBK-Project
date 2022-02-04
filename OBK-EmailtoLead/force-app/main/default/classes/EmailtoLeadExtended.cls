/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 10-12-2021
 * @last modified by  : Satish Chandrashekar
 * Modifications Log 
 * Ver   Date         Author                 Modification
 * 1.0   07-04-2021   Satish Chandrashekar   Initial Version
 * 1.1   15-08-2021   Satish Chandrashekar   Added the Donation Capture Logic
 * 1.2   12-10-2021   Satish Chandrashekar   Deprecated the Donation Email Capture Logic and Added logic to duplicateCheck function
**/
global with sharing class EmailtoLeadExtended implements Messaging.InboundEmailHandler{

    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env)
    {
        // Create an InboundEmailResult object for returning the result of the Apex Email Service 
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String myPlainText= '';
        String fromid = email.fromAddress;
        String toid = env.toAddress;
        myPlainText = email.plainTextBody;
        String subject;
        String fName;
        String lName;
        String eMailId;
        String company;
        Boolean forwardTrue;
        String typeval;
        String enqType;
        Map<String,String> directMsg  = new Map<String,String>();
        Map<String,String> forwardMsg = new Map<String,String>();

    
        //Logic to fork Domain Check with Map and List to store the results from Metadatarecords
        List<String> domain = new List<String>();
        Map<String,String> tomailcheck = new Map<String,String>();
        try{
            obk_EmailtoLead__mdt[] eIds = [SELECT ID, MasterLabel, SF_Email_Id__c, From_Email__c FROM obk_EmailtoLead__mdt WITH SECURITY_ENFORCED];
            //Loop: runthrough the results and structure data for verification
            for(obk_EmailtoLead__mdt erec : eIds){
                domain.add(erec.From_Email__c);
                tomailcheck.put(erec.SF_Email_Id__c,erec.MasterLabel);
            }
        }
        catch(QueryException qe){
            System.Debug(qe);
        }

       //logic to seperate the Inbound Donations & Other Emails
        String don = 'notifications@typeform.com';
        String info = 'info@obk.org.au';
        String event = 'events@obk.org.au';
        String fwd;
        //forwardTrue = domain.contains(fromid); //Verify if the incoming email is from OBK Domain or External
        
        /*if(fromid == don){
            fwd = 'don';
        }
        else */
        if(fromid == info || fromid == event){
            fwd = 'true';
        }
        else{
            fwd = 'false';
        }
        //string fwd = string.valueOf(forwardTrue); //Converting the Boolean to String


        //Verification of TOID and Switch to determine the queue for Lead
        Boolean b = tomailcheck.containskey(toid);
        if(b=true){
            typeval = tomailcheck.get(toid);
        }
        switch on typeval{
            when 'EventsObk'{
                enqType = 'Custom Event';
            }
            when 'InfoMailbox'{
                enqType = 'General';
            }
        }

        //Switch to determine the Email Processing Logic
        switch on fwd{
            when 'true'{
                //Send details to hydrate and create lead
                forwardMsg = EmailtoLeadHandler.forwardEmailLogic(email);
                EmailtoLeadHandler.duplicateCheck(forwardMsg, enqType); // This will complete duplicate check and Create Lead / Task accordingly
            }
            when 'false'{
                //Send details to hydrate and create lead
                directMsg = EmailtoLeadHandler.directEmailLogic(email);
                EmailtoLeadHandler.duplicateCheck(directMsg, enqType); //This will complete duplicate check and Create Lead / Task accordingly.
            }
            /*when 'don'{
                //Send details to hyderate and create lead or contact or task under contact
                forwardMsg = EmailtoLeadHandler.donationsLogic(email);
                EmailtoLeadHandler.duplicateCheck(forwardMsg, enqType);
            }*/
        }


    // Set the result to true. No need to send an email back to the user with an error message 
    result.success = true;

    // Return the result for the Apex Email Service 
    return result;
    }
}
