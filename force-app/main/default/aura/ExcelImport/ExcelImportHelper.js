({
     disableExcelInput: function(cmp) {
         cmp.set("v.disabled", true);
         cmp.set("v.isLoading", true);
     },
enableExcelInput: function(cmp) {
    cmp.set("v.disabled", false);
    cmp.set("v.isLoading", false);
},

importTableAndThrowEvent: function(cmp, evt, helper) {
    evt.stopPropagation();
    evt.preventDefault();
    try {
        const file = helper.validateFile(cmp, evt);
        helper.readExcelFile(file)
        .then($A.getCallback(excelFile => {
            // console.log(JSON.stringify(excelFile));
            helper.throwSuccessEvent(cmp, excelFile);
        }))
            .catch($A.getCallback(exceptionMessage => {

            helper.throwExceptionEvent(cmp, exceptionMessage);

        }))
            .finally($A.getCallback(() => {
            helper.enableExcelInput(cmp);
        }))
        } catch (exceptionMessage) {
            console.log(exceptionMessage);
            helper.throwExceptionEvent(cmp, exceptionMessage);
            helper.enableExcelInput(cmp);
        }
        },

            validateFile: function(cmp, evt) {
                const files = evt.getSource().get("v.files");
                if (!files || files.length === 0 || $A.util.isUndefinedOrNull(files[0])) {
                    throw cmp.get("v.messageNoFileSpecified");
                }

                const file = files[0];
                const fileSizeThreshold = cmp.get("v.fileSizeThreshold");
                if (file.size > fileSizeThreshold) {
                    throw (cmp.get("v.messageFileSizeExceeded") + ': ' + fileSizeThreshold + 'b');
                }
                return file;
            },

            readExcelFile: function(file) {
                return new Promise(function (resolve, reject) {
                    var selectedFile =file;
                    let filename;
                    var reader = new FileReader();
                    reader.onload = function(event) {
                        filename = file.name;
                        var XL_row_object ;
                        var data = event.target.result;
                        var workbook = XLSX.read(data, {
                            type: 'binary'
                        });
                        // console.log(workbook.SheetNames.length);
                        workbook.SheetNames.forEach(function(sheetName) {
                            if(XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]).length!=0){
                                XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
                                //console.log(JSON.stringify(XL_row_object));
                                //document.getElementById("jsonObject").innerHTML = json_object;
                            }


                        })
                        try {
                            resolve({
                                "fileName": filename,
                                "xlsx":XL_row_object
                            });

                        } 
                        catch (error) {
                            reject(error);
                        }
                    };
                    reader.onerror = function(event) {
                        console.error("File could not be read! Code " + event.target.error.code);
                    };
                    reader.readAsBinaryString(selectedFile);
                });
            },

            throwExceptionEvent: function(component, message) {
                const errorEvent = component.getEvent("onImport");
                errorEvent.setParams({
                    "type": "ERROR",
                    "message": message
                });
                errorEvent.fire();
            },

            throwSuccessEvent: function(component, parsedFile) {
                const successEvent = component.getEvent("onImport");
                //console.log(JSON.stringify(parsedFile));
                successEvent.setParams({
                    "type": "SUCCESS",
                    "fileName": parsedFile.fileName,
                    "table": parsedFile.xlsx
                });
                successEvent.fire();
            }
        })