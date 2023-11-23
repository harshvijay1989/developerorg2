({
    onInit : function(component, event, helper) {
        const empApi = component.find('empApi');
        var userId = $A.get("$SObjectType.CurrentUser.Id");
        component.set("v.userId", userId);
        console.log('current User Id : '+userId);
        empApi.onError($A.getCallback(error => {
            console.error('EMP API error: ', JSON.stringify(error));
        }));
            const channel = '/event/ESignPlatformEvent__e';
            const replayId = -1;
            
            empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            component.set('v.Status', eventReceived.data.payload.Status__c);
            component.set('v.Message', eventReceived.data.payload.Message__c);
            component.set('v.documentName', eventReceived.data.payload.documentId__c);
            console.log('cehcek : ',eventReceived.data);
            console.log('recordIdPlatformEvent : ',eventReceived.data.payload.recordId__c);
            console.log('recordId : ',component.get("v.recordId"));
            var currentUserId = eventReceived.data.payload.recordId__c;
            //component.set("v.showPopup", true);
            if(currentUserId === userId){
            	console.log('in');
            	//component.set("v.showPopup", true);
        	}
            /*if(component.get('v.recordId') == eventReceived.data.payload.recordId__c){
            	console.log('in if');
            	component.set("v.showPopup", true);
        	}*/
        }))
            .then(subscription => {
            console.log('Subscribed request sent to: ', subscription.channel);
            component.set('v.subscription', subscription);
        });
        },
            
            closePopup: function(component, event, helper) {
                component.set("v.showPopup", false);
            },
            
            handleClick: function(component, event, helper){
                component.set("v.showPopup", false);
            },
            
            submitDetails: function(component, event, helper){
                window.location.reload();
                component.set("v.showPopup", false);
            }
        })