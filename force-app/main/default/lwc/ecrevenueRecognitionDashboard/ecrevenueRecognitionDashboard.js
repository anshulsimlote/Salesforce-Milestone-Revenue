import { LightningElement, wire, api, track} from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import milestoneCalculation from '@salesforce/apex/EC_RevenueRecognitionController.milestoneCalculation';

export default class RevenueRecognitionDashboard extends LightningElement {
    @api recordId;
    @track oppDataObj = {};
    showSpinner = true;

    @track columns = [
        { label: 'Milestone', fieldName: 'milestoneName' },
        { label: 'Milestone Date', fieldName: 'milestoneDate', type: 'date' },
        { label: 'Recognized Revenue', fieldName: 'recognizedRevenue',  type: 'currency' },
        { label: 'Invoice Status', fieldName: 'invoiceStatus' }
        
    ];

    @wire(milestoneCalculation, { opportunityId: '$recordId' })
    wiredMilestones({ error, data }) {
        if (data) {
            this.oppDataObj = JSON.parse(data);
        } else if (error) {
            this.showToastMessage('ERROR',error.body.message,'error');
        }
        this.showSpinner = false;
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