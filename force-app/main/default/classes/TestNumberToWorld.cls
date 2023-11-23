@isTest
private class TestNumberToWorld {
    
    @isTest
    static void testConvert_nn() {
        System.assertEquals('zero', NumberToWord.convert_nn(0));
        System.assertEquals('one', NumberToWord.convert_nn(1));
        System.assertEquals('twenty', NumberToWord.convert_nn(20));
        System.assertEquals('twenty one', NumberToWord.convert_nn(21));
        System.assertEquals('ninety nine', NumberToWord.convert_nn(99));
        System.assertEquals('One Hundred', NumberToWord.convert_nn(100));
    }
    
    @isTest
    static void testConvert_nnn() {
        NumberToWord.convert_nnn(121);
    }
    
    @isTest
    static void testEnglish_number() {
     	NumberToWord.english_number(12345);
      
    }
}