public class documentPreviewController {
    public String pdfURL { get; set; }
    public String contentVersionId { get; set; }
    public ContentVersion contentVersion { get; private set; }
    public String contentUrl { get; private set; }
    public documentPreviewController(){
        //Id recordId = ApexPages.CurrentPage().getParameters().get('id');
        //String contentVersionId = ApexPages.currentPage().getParameters().get('contentVersionId');
        
    }
    public void callPDF(){
        Blob fileData;
        System.debug(' call pdf ');
        String contentVersionId = apexPages.currentPage().getParameters().get('conVirId');
        System.debug('###contentVersionId : '+ contentVersionId);
        if(contentVersionId != Null  && contentVersionId != 'undefined'){
            System.debug('not null @@@ ');
            List<ContentVersion> conVirLst1 = new List<ContentVersion>([select id, title, VersionData, PathOnClient, FirstPublishLocationId,IsMajorVersion, ContentDocumentId from ContentVersion Where Id =: contentVersionId Order By CreatedDate Desc limit 1]);
            //List<ContentVersion> conVirLst1 = new List<ContentVersion>([select id, title, VersionData, PathOnClient, FirstPublishLocationId,IsMajorVersion, ContentDocumentId from ContentVersion Where Id =: contentVersionId]);
            fileData = conVirLst1[0].VersionData;
            pdfURL = fileData != null ? fileData.toString() : '';
            System.debug('pdfURL : '+ pdfURL);       
            
            /*String base64ImagePattern = '<img[^>]+src=["\'](data:image\\/[^"\']+)["\'][^>]*>';
            
            // Find all base64-encoded images and add them to the list
            System.Pattern pattern = System.Pattern.compile(base64ImagePattern);
            System.Matcher matcher = pattern.matcher(pdfURL);
            
            if(matcher != null){
                System.debug('matcher not null');
                // Use a list to store the extracted base64-encoded images
                List<String> base64Images = new List<String>();
                List<Document_Template__c> docTempLst = [Select id from Document_Template__c Order by CreatedDate Desc Limit 1];
                while (matcher.find()) {
                    String base64Image = matcher.group(1);
                    base64Image = base64Image.substringAfter(',');
                    
                    Blob imageBlob = EncodingUtil.base64Decode(base64Image);
                    ContentVersion contentVersion = new ContentVersion();
                    contentVersion.VersionData = imageBlob;
                    contentVersion.Title = 'PDF Image';
                    contentVersion.PathOnClient = 'PDF Image.png';
                    insert contentVersion;
                    
                    ContentVersion insertedContentVersion = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id LIMIT 1];
                    ContentDocumentLink contentLink = new ContentDocumentLink();
                    contentLink.ContentDocumentId = insertedContentVersion.ContentDocumentId;
                    contentLink.LinkedEntityId = docTempLst[0].Id;//conVirLst1[0].FirstPublishLocationId;
                    contentLink.ShareType = 'I'; 
                    insert contentLink;
                    //System.debug('contentLink' + contentLink.id);
                    String fileURL = URL.getSalesforceBaseUrl().toExternalForm() + '/sfc/servlet.shepherd/version/download/' + contentVersion.Id;
                    String originalImg = '<img src="'+fileURL+'"/>';
                    base64Images.add(originalImg);
                }
                System.debug('base64Images : '+ base64Images);
                if(!base64Images.isEmpty()){
                    for (Integer i = 0; i < base64Images.size(); i++) {
                        pdfURL = pdfURL.replaceFirst(base64ImagePattern, base64Images[i]);
                    }
                }  
            }*/
        }
        else{
            //System.debug('helo no preview');
            //String vfPage = '<img src="https://3dboost2--dev2.sandbox.my.salesforce.com/sfc/servlet.shepherd/version/download/0681m000000E2boAAC" style="width: 95%; height: 948.4px;"/><br/><div width="100%" style="width:100% !important"><table cellspacing="0" style="border-collapse:collapse; width:100%"> <tbody> <tr> <td colspan="9" style="border-color:#000000; border-style:solid; border-width:1px"> <p style="text-align:center"><strong>Quote</strong></p> </td> </tr> <tr> <td colspan="7" rowspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Exporter :<strong>&nbsp;TRUECALLER PRIVATE LIMITED</strong></p> <p>KALAWAD ROAD, VAJDI (VAD), TALUKA: LODHIKA,</p> <p>DISTRICT)</p> <p>RAJKOT RAJKOT- 360021 GUJARAT,INDIA</p> <p>TEL NO. +91-281-2783755/56</p> <p>TEL NO. 491. 9624771143</p> <p>EMAIL:piyushvala@truecaller.com</p> </td> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>Invoice NO: PI/18-10</p> <p>Date :&nbsp;2023-11-08</p> </td> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>IEC NO:88399399 GST No :</p> </td> </tr> <tr> <td colspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Buyer Order NO and Date : PI/12 OCT</p> </td> </tr> <tr> <td colspan="7" rowspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Consignee :&nbsp; <strong>Truecaller&nbsp;Limited</strong></p> <p>Jaipur,Rajasthan,India</p> <p>Pin Code 302012</p> <p>Phone No. 9638527410</p> <p>Email :&nbsp;rohit.sethi@crmlanding.in</p> </td> <td colspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Buyer : <strong>Truecaller&nbsp;Limited</strong></p> </td> </tr> <tr> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>Country of Origine</p> <p><strong>India</strong></p> </td> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>Country of Final Destination India</p> </td> </tr> <tr> <td colspan="4" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Pre-Carriage by : 100.0</p> </td> <td colspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Place of Receipt by :</p> </td> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>Container No. 5635</p> </td> <td colspan="2" rowspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Terms of Delivery And Payment :</p> <p><strong>FOB MUNDRA PORT 100% ADVANCE PAYMENT</strong></p> </td> </tr> <tr> <td colspan="4" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Vassel/Voyage No :</p> </td> <td colspan="2" style="border-color:#000000; border-style:solid; border-width:1px"> <p>Port Of Loading :</p> <p><strong>Mundra Port</strong></p> </td> <td style="border-color:#000000; border-style:solid; border-width:1px"> <p>Line Seal No. UBD678HU</p> </td> </tr> <tr> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td colspan="2" style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> <td style="border-color:#000000; border-style:solid; border-width:1px">&nbsp;</td> </tr> <tr> <td colspan="9" style="border-color:#000000; border-style:solid; border-width:1px"> <p><strong>TERMS :</strong></p> <ol> <li>IGST STATUS: EXPORT UNDER LUT WITHOUT PAYMENT OF IGST, LUT (ARN) No. AD240323008037N, LUT (ARN) VALID UP TO 31-03-2024</li> <li>ENDUSE CODE:- FSH200-FOOD-FOR MANUFACTURE/COMMERCIAL PROCESSING (MANUFACTURE/ACTUAL USE)</li> <li>THE STATE OF ORIGIN OF GOODS: GUJARAT(24), THE DISTRICTS OF ORIGIN OF GOODS: RAJKOT(457), TRADE AGREEMENT: NCPTI</li> </ol> <p>For,<strong>Truecaller&nbsp;Limited&nbsp;</strong></p> <p><strong>Description</strong> The Goods shipped are of Indian Origin. We declare that this invoice shows actually price of the goods described and that all particulars are true and correct.</p> <p>AUTHORISED SIGNATORY</p> </td> </tr> </tbody> </table> <p>&nbsp;</p> <p><span style="font-size:14px"><strong>Here is the Quote Line Item below :&nbsp;</strong></span></p> <p><table cellspacing="0" border="2" width="100%"><tbody><tr style="border:1px solid black;><tr style="border:1px solid black;><th>LineNumber</th><th>parent_name__c</th><th>ListPrice</th><th>UnitPrice</th><th>Quantity</th><th>TotalPrice</th></tr><tr><td>00000136</td><td>CPM by 100</td><td>40000.00</td><td>40000.00</td><td>1000.00</td><td>40000000.00</td></tr><tr><td>00000137</td><td>CPM by 200</td><td>5000.00</td><td>5000.00</td><td>1000.00</td><td>5000000.00</td></tr><tr><td>00000138</td><td>Roadblock</td><td>80000.00</td><td>80000.00</td><td>1000.00</td><td>80000000.00</td></tr></tbody></table></p> <p>&nbsp;</p> <table border="0" cellpadding="0" cellspacing="0" style="width:100%"> <tbody> <tr> <td><strong>TrueCaller</strong></td> <td style="text-align:right">&nbsp; <strong>Rajesh Enterprise</strong></td> </tr> <tr> <td><img src="https://3dboost2--dev2.sandbox.my.salesforce.com/sfc/servlet.shepherd/version/download/0681m000000E2bpAAC"/>&nbsp<img src="https://3dboost2--dev2.sandbox.my.salesforce.com/sfc/servlet.shepherd/version/download/0681m000000E2bqAAC"/></td> <td style="text-align:right">&nbsp; &nbsp; <span classSie=color:white> {{Customer_Sign}} </span></td> </tr> </tbody> </table> </div><br/><br/><br/><br/><br/><br/><div class="Additional-Text"></div>';
            //pdfURL += vfPage;
            pdfURL = ' No Preview Page asdhvs !! ';
            
        }
    }
}