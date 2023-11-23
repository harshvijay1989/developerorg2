// Owner Name : Roshina Azmat
// Designation : salesforce Developer
//Email : roshina@crmlanding.in
//purpose : handle Header and Footer records
public class pre_configurationController {


    /*@AuraEnabled
    public static blob yourApexMethod(String htmlCode, String htmlCode1) {
        //htmlCode = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta http-equiv="Content-Style-Type" content="text/css" /><meta name="generator" content="Aspose.Words for .NET 23.9.0" /><title></title><style type="text/css">body { line-height:108%; font-family:Rockwell; font-size:11pt }h1, h2, h3, h4, h5, h6, p { margin:0pt }li, table { margin-top:0pt; margin-bottom:0pt }h1 { margin-top:3pt; margin-bottom:2pt; text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:25pt; font-weight:normal; text-transform:uppercase; color:#000000 }h2 { text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:normal; text-transform:uppercase; color:#000000 }h3 { page-break-inside:avoid; page-break-after:avoid; line-height:108%;  font-size:11pt }.IndexHeading { line-height:108%; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:bold }.Initials { text-align:center; line-height:normal; font-family:Franklin Gothic Demi; font-size:55pt; text-transform:uppercase; color:# }.IntenseQuote { margin:18pt 43.2pt; text-align:center; line-height:108%; border-top:0.75pt solid #; border-bottom:0.75pt solid #; padding-top:10pt; padding-bottom:10pt; font-size:11pt; font-style:italic; color:#d01818; -aw-border-bottom:0.5pt single; -aw-border-top:0.5pt single }.List { margin-left:18pt; text-indent:-18pt; line-height:108%; </style></head><body border="1"><div><p class="NoSpacing"><span style="height:0pt; display:block; position:absolute; z-index:-1"></span><span style="-aw-import:ignore">&#xa0;</span></p><table cellspacing="0" cellpadding="0" style="border-collapse:collapse"><tr style="height:12.95pt"><td colspan="2" style="width:153pt; vertical-align:middle"><p class="Initials"><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>RJ</span></span><span> </span></p></td><td style="width:31.5pt; vertical-align:middle"><p class="NoSpacing" style="text-align:center"><span style="-aw-import:ignore">&#xa0;</span></p></td><td style="width:328.5pt; vertical-align:middle"><h1><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>Chela Arapelli</span></span></h1><h2><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>beauty blogger</span></span><span> | </span><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>www.interestingsite.com</span></span></h2></td><td style="width:12.6pt; vertical-align:middle"><p class="NoSpacing" style="text-align:right"><span style="-aw-import:ignore">&#xa0;</span></p></td></tr></table><p class="NoSpacing"><span style="-aw-import:ignore">&#xa0;</span></p></div><hr/></body></html>';
        
        String str = '<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><meta http-equiv="Content-Style-Type" content="text/css" /><meta name="generator" content="Aspose.Words for .NET 23.9.0" /><title></title><style type="text/css">body { line-height:108%; font-family:Rockwell; font-size:11pt }h1, h2, h3, h4, h5, h6, p { margin:0pt }li, table { margin-top:0pt; margin-bottom:0pt }h1 { margin-top:3pt; margin-bottom:2pt; text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:25pt; font-weight:normal; text-transform:uppercase; color:#000000 }h2 { text-align:right; page-break-inside:avoid; page-break-after:avoid; line-height:normal; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:normal; text-transform:uppercase; color:#000000 }h3 { page-break-inside:avoid; page-break-after:avoid; line-height:108%;  font-size:11pt }.IndexHeading { line-height:108%; font-family:Franklin Gothic Demi; font-size:11pt; font-weight:bold }.Initials { text-align:center; line-height:normal; font-family:Franklin Gothic Demi; font-size:55pt; text-transform:uppercase; color:# }.IntenseQuote { margin:18pt 43.2pt; text-align:center; line-height:108%; border-top:0.75pt solid #; border-bottom:0.75pt solid #; padding-top:10pt; padding-bottom:10pt; font-size:11pt; font-style:italic; color:#d01818; -aw-border-bottom:0.5pt single; -aw-border-top:0.5pt single }.List { margin-left:18pt; text-indent:-18pt; line-height:108%; </style></head><body border="1"><div><p class="NoSpacing"><span style="height:0pt; display:block; position:absolute; z-index:-1"></span><span style="-aw-import:ignore">&#xa0;</span></p><table cellspacing="0" cellpadding="0" style="border-collapse:collapse"><tr style="height:12.95pt"><td colspan="2" style="width:153pt; vertical-align:middle"><p class="Initials"><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>CA</span></span><span> </span></p></td><td style="width:31.5pt; vertical-align:middle"><p class="NoSpacing" style="text-align:center"><span style="-aw-import:ignore">&#xa0;</span></p></td><td style="width:328.5pt; vertical-align:middle"><h1><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>Chela Arapelli</span></span></h1><h2><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>beauty blogger</span></span><span> | </span><span style="-aw-sdt-content:placeholder; -aw-sdt-tag:"><span>www.interestingsite.com</span></span></h2></td><td style="width:12.6pt; vertical-align:middle"><p class="NoSpacing" style="text-align:right"><span style="-aw-import:ignore">&#xa0;</span></p></td></tr></table><p class="NoSpacing"><span style="-aw-import:ignore">&#xa0;</span></p></div><hr/></body></html>';


        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Email Template Content';
        contentVersion.PathOnClient = 'EmailTemplateContent.doc'; // You can choose a filename
        contentVersion.VersionData = Blob.valueOf(htmlCode);
        contentVersion.FirstPublishLocationId = '0061y000009tBO2AAM';
        insert contentVersion;

        
        return contentVersion.VersionData;
        // Add your logic here
    }*/ 
    //-------------------------
    @AuraEnabled(cacheable=true)
    public static List<Standard_Header__c> getAllStandardHeaders(){
        return [select id,Header__c,Logo__c, Header_Info__c from Standard_Header__c];
    }
    
    @AuraEnabled
    public static String deleteHeaderFooters(List<String> recordIds){
        List<Documnet_Template_Config__c> deleteList =  [select id  from Documnet_Template_Config__c Where Id IN : recordIds];
        
        if(!deleteList.isEmpty()){
            delete deleteList;
            return 'SUCCESS';
        }
        return null;
    }
    
    @AuraEnabled
    public static String updateConfigRecords(Documnet_Template_Config__c headerData, 
                                              Documnet_Template_Config__c footerData,
                                              String filedata){
        
         fileModal file = new fileModal();
        Map<String,Object> fileDataMap = (Map<String,Object>)JSON.deserializeuntyped(filedata);
       // file.recordId = (String)fileDataMap.get('recordId');
        file.base64 = (String)fileDataMap.get('base64');
        file.filename = (String)fileDataMap.get('filename');

        List<Documnet_Template_Config__c> configRecordList = new  List<Documnet_Template_Config__c>{headerData, footerData}; 
        System.debug('configRecordList' + configRecordList);
        if(!configRecordList.isEmpty()){
              update configRecordList;
        }    
        String recordId = headerData.Id;
       // System.debug('recordId' +recordId);
                                                  
         
        if(file != null && file.base64 != null){
               uploadLogo(recordId, file.base64, file.filename);
         }                                          
       
       return 'SUCCESS';
    }
    
     public class fileModal{
        @AuraEnabled public String recordId{get;set;}
        @AuraEnabled public String base64{get;set;}
        @AuraEnabled public String filename{get;set;}
    }

    @AuraEnabled
    public static String uploadLogo(String recordId, String base64, String filename) {
        
        System.debug('recordId' + recordId);
        Id recordTypeId = Schema.SObjectType.Documnet_Template_Config__c.getRecordTypeInfosByDeveloperName().get('Document_Header').getRecordTypeId();
        List<Documnet_Template_Config__c> listForImg = [SELECT Id, Name,RecordTypeId, RecordType.Name FROM Documnet_Template_Config__c where RecordTypeId =: recordTypeId];
        System.debug('listForImg' + listForImg);

        Attachment attach = new Attachment();
        attach.ParentId = recordId;
        attach.Name = filename;
        //attach.ContentType = fileType;
        attach.Body = EncodingUtil.base64Decode(base64); 
        insert attach;
        return 'SUCCESS';
        
    }


    @AuraEnabled
    public Static Map<String, List<DocumnetTemplateConfigModal>>  getHeaderAndFooterData(){
        
        Map<String, Documnet_Template_Config__c> dtcMap = new  Map<String, Documnet_Template_Config__c>([SELECT Id, RecordTypeId,RecordType.Name,Logo_Width__c,Logo_Height__c, UId__c ,Template_Name__c, Name, Horizontal_Margin__c, Vertical_Margin__c, 
                                                                                                         Font_Family__c, Font_Size__c, Header_Text__c, Header_Text_Position__c,Footer_Text__c, Footer_Text_Position__c, Header_Text_Color__c, 
                                                                                                         is_Header_Border_Apply__c, Header_Border_Color__c, Footer_Text_Color__c, 
                                                                                                         is_Footer_Border_Apply__c, is_Apply_Logo__c, Logo_Position__c,Page_Number_Formate__c,CreatedDate FROM Documnet_Template_Config__c  ORDER BY CreatedDate ASC]);                     
        
        Map<String, String> recordIdWithBase64Map = new Map<String, String>();
        Map<String, String> recordIdWithAttIdMap = new Map<String, String>();
        for(Attachment att : [SELECT Id, ParentId, Body FROM Attachment WHERE ParentId IN: dtcMap.keySet() ORDER BY CreatedDate DESC]){
            if(!recordIdWithBase64Map.containsKey(att.ParentId)){
                recordIdWithBase64Map.put(att.ParentId, EncodingUtil.base64Encode(att.Body));
                recordIdWithAttIdMap.put(att.ParentId, att.Id);
            } 
        }
        
        Map<String, List<DocumnetTemplateConfigModal>> configMap = new Map<String, List<DocumnetTemplateConfigModal>>();
        for (Documnet_Template_Config__c obj : dtcMap.values()) {
            if(!configMap.containsKey(obj.Template_Name__c)){
                configMap.put(obj.Template_Name__c,  new List<DocumnetTemplateConfigModal>());
            }
            String attachmentBase64 = recordIdWithBase64Map.containsKey(obj.Id) ? recordIdWithBase64Map.get(obj.Id) : null;  
            String attId = recordIdWithAttIdMap.containsKey(obj.Id) ? recordIdWithAttIdMap.get(obj.Id) : null;  
            configMap.get(obj.Template_Name__c).add(new DocumnetTemplateConfigModal(obj, attId, attachmentBase64));
        }
        return configMap;  
    }
    
    public class DocumnetTemplateConfigModal{
        @AuraEnabled public Documnet_Template_Config__c record;
        @AuraEnabled public String attachmentId;
        @AuraEnabled public String attachmentBase64;
        
        public DocumnetTemplateConfigModal(Documnet_Template_Config__c record, String attachmentId, String attachmentBase64){
            this.record = record;
            this.attachmentId = attachmentId;
            this.attachmentBase64 = attachmentBase64;
        }
    }
}