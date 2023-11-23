({
    setParentIdAndFileContent: function(component, parentId, fileContents) {
        // Set the parent ID and file content in component attributes
        component.set("v.parentId", parentId);
        component.set("v.fileContents", fileContents);
        
          console.log('Helper parentId', parentId);
                console.log('Helper fileContents', fileContents);
               
    }
})