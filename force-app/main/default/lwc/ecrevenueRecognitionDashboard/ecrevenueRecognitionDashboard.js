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
            this.revenueItems = this.transformData(JSON.parse(data));
        } else if (error) {
            this.showToastMessage('ERROR',error.body.message,'error');
        }
        this.showSpinner = false;
    }

    transformData(milestones) {
        return milestones.revRecMilestonesList.map(milestone => ({
            id: milestone.milestoneName,
            name: milestone.milestoneName,
            recognizedRevenue: milestone.recognizedRevenue,
            invoiceStatus: milestone.invoiceStatus,
            _children: milestone.revRecMilestonesItemList.map(product => ({
                id: milestone.milestoneName + '-' + product.productName,
                name: product.productName,
                recognizedRevenue: product.TotalPrice,
                invoiceStatus: ''
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