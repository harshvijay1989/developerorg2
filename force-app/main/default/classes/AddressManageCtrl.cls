public class AddressManageCtrl {
    
    @AuraEnabled(cacheable=true)
    public static Organization  getDocumentTemplates() {
                   
        return [SELECT Id, IsSandbox, OrganizationType, Name, Division, Street, City, State, PostalCode, Country,Address, Phone FROM Organization LIMIT 1];
    }
}