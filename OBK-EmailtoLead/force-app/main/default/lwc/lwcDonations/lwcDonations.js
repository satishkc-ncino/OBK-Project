/**
 * @description       : 
 * @author            : Satish Chandrashekar
 * @group             : 
 * @last modified on  : 02-04-2022
 * @last modified by  : Satish Chandrashekar
**/
import { LightningElement, wire, track, api } from 'lwc';
import {NavigationMixin} from "lightning/navigation";
//import getURL from "@salesforce/apex/DonationsController.getURL";


export default class LwcDonations extends NavigationMixin(LightningElement) {


    //Automate the Link for Next Release
    /*  @api paylink;
    error;

    @wire(getURL)
    wiredRecords(results){
        const {data, error} = results;
        if(data){
            this.error = undefined;
            this.paylink = data;
            console.log(this.paylink);
            alert(this.paylink);
        }
        else if(error){
            this.error = error;
            this.paylink = undefined;
        }
    } */
    salutationsList = [
        { label: 'Mr.', value: 'Mr.' },
        { label: 'Ms.', value: 'Ms.' },
        { label: 'Mrs.', value: 'Mrs.' },
        { label: 'Dr.', value: 'Dr.' },
        { label: 'Prof.', value: 'Prof.' },
    ];
    get salutationOptions() {
        return this.salutationsList;
    }


    handleRedirect() {
        this[NavigationMixin.Navigate]({
            type : 'standard__webPage',
            attributes: {
                //url : this.paylink
                url : 'https://buy.stripe.com/test_4gwg1e0VT1LNdz2fYY'
            }
        });
}
}