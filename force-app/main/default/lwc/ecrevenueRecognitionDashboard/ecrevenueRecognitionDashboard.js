import { LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import milestoneCalculation from '@salesforce/apex/EC_RevenueRecognitionController.milestoneCalculation';

const COLUMNS = [
    { 
        label: 'Milestone / Product Name', 
        fieldName: 'name', 
        type: 'text'
    },
    { 
        label: 'Recognized Revenue', 
        fieldName: 'recognizedRevenue', 
        type: 'currency'
    },
    { 
        label: 'Milestone Date', 
        fieldName: 'milestoneDate', 
        type: 'date'
    },
    { 
        label: 'Invoice Status', 
        fieldName: 'invoiceStatus', 
        type: 'text'
    }
];
export default class EcRevenueRecognitionDashboard extends LightningElement {
    @api recordId;
    @track oppDataObj = {};
    @track revenueItems = [];
    columns = COLUMNS;
    showSpinner = true;

    @wire(milestoneCalculation, { opportunityId: '$recordId' })
    wiredMilestones({ error, data }) {
        if (data) {
            this.oppDataObj = JSON.parse(data);
            this.revenueItems = this.addKeysData(this.oppDataObj );
        } else if (error) {
            this.showToastMessage('ERROR',error.body.message,'error');
        }
        this.showSpinner = false;
    }

    addKeysData(milestones) {
        return milestones.revRecMilestonesList.map(milestone => ({
            ...milestone,                
            key: milestone.name,         
            _children: milestone.revRecMilestonesItemList.map(child => ({
                ...child,               
                key: milestone.name + '-' +child.name         
            }))
        }));
    }
    

    showToastMessage(title, message, variant){
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}