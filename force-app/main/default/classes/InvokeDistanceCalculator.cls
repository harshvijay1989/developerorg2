public class InvokeDistanceCalculator {
    @InvocableMethod(label='distance approval calculator' description='distance approval calculator')
    public static void invokeCreateOrderAPI(list<Account> lstAccount) {
        id AccountId=lstAccount[0].id;
       // CalculateDistancePolicyController.calculateDistance(AccountId);
        
    }
}