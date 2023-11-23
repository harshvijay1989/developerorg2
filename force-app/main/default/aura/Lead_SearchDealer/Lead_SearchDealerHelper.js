({
    handleSearch: function( component, searchTerm, recordId ) {
        var action = component.get( "c.searchAccounts" );
        action.setParams({
            searchTerm: searchTerm, 
            leadRecordId: recordId
        });
        action.setCallback( this, function( response ) {
            var event = $A.get( "e.c:HMC_AccountsLoaded" );
            event.setParams({
                "accounts": response.getReturnValue()
            });
            event.fire();
        });
        $A.enqueueAction( action );
    }
})