/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 02-08-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger EC_OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {
    EC_IsTriggerEnable__c enableTrigger = EC_IsTriggerEnable__c.getInstance();
    if(enableTrigger.EC_Is_Active_Opportunity_Trigger__c){
        if(trigger.isBefore && trigger.isInsert){
            EC_OpportunityTriggerHandler.beforeInsert(trigger.new);
        }
        if(trigger.isBefore && trigger.isUpdate){
            EC_OpportunityTriggerHandler.beforeUpdate(trigger.new, trigger.oldMap);
        }
        if(trigger.isAfter && trigger.isInsert){
            EC_OpportunityTriggerHandler.afterInsert(trigger.new);
        }
        if(trigger.isAfter && trigger.isUpdate){
            EC_OpportunityTriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
        }
    }
}