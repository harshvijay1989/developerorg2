({
    
    handleFilesChange: function (component, event, helper) {
        var fileInput = component.find("fuploader").getElement();
        var file = fileInput.files[0];
        
        if (file) {
            var reader = new FileReader();
            reader.onload = function (e) {
                var fileContents = e.target.result;
                var parentId = component.get("v.parentId");
                console.log('parentId', parentId);
                console.log('fileContents', fileContents);
                
                // Add a wait time of 2 seconds (2000 milliseconds)
                var delayTime = 1000;
                            helper.setParentIdAndFileContent(component, parentId, fileContents);

                // Call the server-side controller to process the CSV file after the delay
                setTimeout(function () {
                    var action = component.get("c.processCSVFile");
                    action.setParams({
                        parentId: parentId,
                        fileContents: fileContents
                    });
                    action.setCallback(this, function (response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var tableData = response.getReturnValue();
                            console.log('tableData==>', JSON.stringify(tableData));
                            component.set("v.csvData", tableData);
                            component.set("v.showDataTable", true); 
                            component.set("v.showButtons", true);
                            
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title: 'Success!',
                                message: 'File uploaded successfully.',
                                type: 'success'
                            });
                            toastEvent.fire();
                        } else {
                            component.set("v.showDataTable", false); 
                            component.set("v.showButtons", false);
                        }
                    });
                    $A.enqueueAction(action);
                }, delayTime);
            };
            reader.readAsText(file);
        }
    },
    
    handleSave: function(component, event, helper) {
       
        // Get the CSV data from the component attribute
        var csvData = component.get("v.csvData");
        console.log('csvData',csvData);
        // Call the server-side controller method to save the data
        var action = component.get("c.saveDataToApex");
        action.setParams({
            csvData: csvData
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                // Handle success
                var result = response.getReturnValue();
                // You can add additional logic or show a success toast message here
            } else {
                // Handle any errors
            }
        });
        $A.enqueueAction(action);
    },
    
    handleSaveandProcess: function(component, event, helper) {
    }
})