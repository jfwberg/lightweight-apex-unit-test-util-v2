/**
 * @description Class to demonstrate how to use the utl.Mck Utility
 */
public with sharing class MckDemo {

    /**
     * @description A method that executes a single HTTP Callout
     * @return      The response of the HTTP Callout
     */
    public static String singleHttpCallout(){
       
        // Create a request
        HttpRequest request = new HttpRequest();
        request.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data');
        
        // Execute the request
        return new HTTP().send(request).getBody();
    }


    /**
     * @description A method that executes multiple callouts and returns
     *              the response bodies in a list
     * @return      A String list containing the response bodies
     */
    public static String[] multipleHttpCallouts(){

        // Create a list for storing our multiple responses
        String[] responses = new String[]{};

        /**
         * FIRST REQUEST
         */
        HttpRequest request1 = new HttpRequest();
        request1.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/');
        
        // Set the mock response we want to use in the test class
        // --> FIRST_RESPONSE
        utl.Mck.setResponseIdentifier('FIRST_RESPONSE');

        // Execute the request and add request to the list
        responses.add(new HTTP().send(request1).getBody());


        /**
         * SECOND REQUEST
         */
        HttpRequest request2 = new HttpRequest();
        request2.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/');
        
        // Set the mock response we want to use in the test class
        // --> SECOND_RESPONSE
        utl.Mck.setResponseIdentifier('SECOND_RESPONSE');

        // Execute the request and add request to the list
        responses.add(new HTTP().send(request2).getBody());


        /**
         * THIRD REQUEST
         */
        HttpRequest request3 = new HttpRequest();
        request3.setEndPoint(URL.getSalesforceBaseUrl().toExternalForm() + '/services/data/');
          
        // Set the mock response we want to use in the apex unit test class
        // --> THIRD_RESPONSE
        utl.Mck.setResponseIdentifier('THIRD_RESPONSE');
  
        // Execute the request and add request to the list
        responses.add(new HTTP().send(request3).getBody());

        // Returnt he list with response bodies
        return responses;
    }
}