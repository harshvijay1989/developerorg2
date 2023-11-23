({
    
    closeQA : function(component, event, helper) { 
        cosole.log('close action Called')
        $A.get("e.force:closeQuickAction").fire(); 
        $A.get("e.force:refreshView").fire(); 
    }
})