@isTest
public class ProfileControllerTest {
	
    @isTest
    static void testGetAllProfiles() {
        Test.startTest();
        List<Profile> resultProfiles = ProfileController.getAllProfiles();
        Test.stopTest();
        system.assert(resultProfiles.size()>0);
    }
}