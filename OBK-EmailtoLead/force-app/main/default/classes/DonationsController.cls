/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 02-04-2022
 * @last modified by  : Satish Chandrashekar
**/
public with sharing class DonationsController {
    
    @Auraenabled(cacheable = true)
    public static void checkCustomer(){
        //Here Goes the Duplicate Check and Update File
        Boolean ok;
    }

    @Auraenabled(cacheable = true)
    public static String getURL(){

        //Declare Variables
        boolean prod;
        String paymentlink;

        //Check Org is Prod or Sandbox
        Organization org = [SELECT Id, InstanceName, IsSandbox, Name, OrganizationType FROM Organization WITH SECURITY_ENFORCED LIMIT 1];
        prod = org.IsSandbox;


        //Execute Appropriate SOQL
        if(prod == false){
            obk_StripeIntegration__mdt[] paylink = [SELECT ID, MasterLabel, StringURL__c, PaymentURL__c, Is_Prod__c from obk_StripeIntegration__mdt WHERE Label='PaymentLink' AND Is_Prod__c =false WITH SECURITY_ENFORCED] ;
            //paymentlink = paylink[0].PaymentURL__c;
            paymentlink = paylink[0].StringURL__c;
        }
        else{
            obk_StripeIntegration__mdt[] paylink = [SELECT ID, MasterLabel, StringURL__c, PaymentURL__c, Is_Prod__c from obk_StripeIntegration__mdt WHERE Label='PaymentLink' AND Is_Prod__c = true WITH SECURITY_ENFORCED] ;
            //paymentlink = paylink[0].PaymentURL__c;
            paymentlink = paylink[0].StringURL__c;
        }

        return paymentlink;
        
    }
}
