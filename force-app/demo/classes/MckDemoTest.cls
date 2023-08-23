/**
 * @description Unit Tests for the MckDemo Class
 */
@IsTest
private with sharing class MckDemoTest {
    
    /**
     * @description Method to test a single callout
     */
    @IsTest
    static void testSingleHttpCallout(){
        
        // Because we only have a single response we set the response using the SET method
        utl.Mck.setResponse('{"data" : "test"}');

        // You can overload the method with a custom response code as well
        utl.Mck.setResponse(400, '{"data" : "test"}');
       
        // Set mock callout class to the instance of the utl.Mck Class
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run the SINGLE callout logic
        String actualResponse = MckDemo.singleHttpCallout();
        
        // Assert the expected response is the same as the actual response
        Assert.areEqual('{"data" : "test"}', actualResponse, 'Unexpected response for default response');
    }


    /**
     * @description Method to test multiple callouts
     */
    @IsTest
    static void testMultipleHttpCallouts(){
        
        // We add a response that matches the identifier of the method to the mock testing method
        // In this case we have three callouts in a single method we need to test
        utl.Mck.addResponse('FIRST_RESPONSE',  200, '{"data1" : "test1"}');
        utl.Mck.addResponse('SECOND_RESPONSE', 200, '{"data2" : "test2"}');
        utl.Mck.addResponse('THIRD_RESPONSE',  200, '{"data3" : "test3"}');
       
        // Set mock callout class to the instance of the utl.Mck Class
        Test.setMock(HttpCalloutMock.class, utl.Mck.getInstance());

        // Run the multiple callout logic
        String[] actualResponses = MckDemo.multipleHttpCallouts();
        
        // Assert the expected response is the same as the actual response
        Assert.areEqual('{"data1" : "test1"}', actualResponses[0], 'Unexpected response for FIRST_RESPONSE');
        Assert.areEqual('{"data2" : "test2"}', actualResponses[1], 'Unexpected response for SECOND_RESPONSE');
        Assert.areEqual('{"data3" : "test3"}', actualResponses[2], 'Unexpected response for THIRD_RESPONSE');
    }
}