/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of Apex Unit Test Utilities to create a generic,
 *                 reusable HTTP Callout Mock that:
 *                 - Allows for a single response in a method
 *                 - Allows for multiple responses in the same method
 *                 - Is fully reusable
 * @false-positive PMD.AvoidGlobalModifier This is a utility that is designed to be called from a
 *                                         managed package. It can be used for a user's own custom
 *                                         Implementation, so global is the way to open up this
 *                                         utility for global use.
 * @note           This class is to be used in a managed package and contains Global methods that
 *                 should be made public or private in org based implementations or unlocked
 *                 packages
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class Mck implements HttpCalloutMock{

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Set a web service response Id for testing methods with multiple call-outs
    // It's nothing more than an identifier of what mock response to fetch from a map
    private String responseIdentifier;

    // Map a response Id to a specific response, use this when you have multiple chained http calls in
    // the same execution context
    private Map<String, Response> responseMap = new Map<String, Response>();


    /** **************************************************************************************************** **
     **                                       PRIVATE STATIC VARIABLES                                       **
     ** **************************************************************************************************** **/
    // Class instance of the mock response
    private static Mck instance;


    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Messages
    @TestVisible private static final String MSG_NO_REPONSE_ID      = 'No Response Identifier found: Please set a valid Mock response Identifier (i.e. Mck.setResponseIdentifier(\'MOCK_ID_NAME\');) before executing the http callout. Either in the test class or in the main code.';
    @TestVisible private static final String MSG_INVALID_REPONSE_ID = 'Invalid Response Id: Supplied Response Id "{0}" does not exist in the response map. Please set a valid response (i.e. Mck.addResponse([id], [status code],[body],[headerMap]);), before executing the http callout. Needs to be set in the test class.';


    /** **************************************************************************************************** **
     **                                             CONSTRUCTORS                                             **
     ** **************************************************************************************************** **/
    /**
     * @description Main constructor to be private as it's a singleton
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private Mck(){}


    /** **************************************************************************************************** **
     **                                    NORMAL APEX CLASS SETTERS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to set the response Id, this is an integer you define yourself
     * @param responseIdentifier The String that is used to match the response in the test class
     */
    global static void setResponseIdentifier(String responseIdentifier){
        getInstance().responseIdentifier = responseIdentifier;
    }


    /** **************************************************************************************************** **
     **                                        TEST CLASS GETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Method to get the Mck Class instance
     * @return The single instance of the Mck class
     */
    global static Mck getInstance(){
        if(instance == null){
            instance = new Mck();
        }
        return instance;
    }


    /** **************************************************************************************************** **
     **                                        TEST CLASS SETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description OVERLOAD Method to combine the adding and setting of the response Id in a single method
     *              This should be used when there is only a single HTTP Call in the test
     * @param responseBody The content body of the expected webservice reponse
     */
    global static void setResponse(String responseBody){
        setResponse(null, responseBody, null);
    }


    /**
     * @description OVERLOAD Method to combine the adding and setting of the response Id in a single method
     *              This should be used when there is only a single HTTP Call in the test
     * @param responseStatusCode The status code of the expected webservice reponse (default 200)
     * @param responseBody       The content body of the expected webservice reponse
     */
    global static void setResponse(Integer responseStatusCode, String responseBody){
        setResponse(responseStatusCode, responseBody, null);
    }


    /**
     * @description Method to combine the adding and setting of the response Id in a single method
     *              This should be used when there is only a single HTTP Call in the test
     * @param responseStatusCode The status code of the expected webservice reponse (default 200)
     * @param responseBody       The content body of the expected webservice reponse
     * @param responseHeaders    The headers of the expected webservice reponse
     */
    global static void setResponse(Integer responseStatusCode, String responseBody, Map<String,String> responseHeaders){
        setResponseIdentifier('default');
        addResponse('default', responseStatusCode, responseBody, responseHeaders);
    }


    /**
     * @description OVERLOAD Method to add a test response to the response map
     * @param responseIdentifier The ID of the Mck
     * @param responseStatusCode The status code of the expected webservice reponse (default 200)
     * @param responseBody       The content body of the expected webservice reponse
     */
    global static void addResponse(String responseIdentifier, Integer responseStatusCode, String responseBody){
        addResponse(responseIdentifier, responseStatusCode, responseBody, null);
    }


    /**
     * @description Method to add a test response to the response map
     *              Overload method in order to add custom headers
     * @param responseIdentifier The ID of the Mck
     * @param responseStatusCode The status code of the expected webservice reponse (default 200)
     * @param responseBody       The content body of the expected webservice reponse
     * @param responseHeaders    The headers of the expected webservice reponse
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    global static void addResponse(String responseIdentifier, Integer responseStatusCode, String responseBody, Map<String,String> responseHeaders){
        getInstance().responseMap.put(
            responseIdentifier,
            new Response(
                responseStatusCode,
                responseBody,
                responseHeaders
            )
        );
    }


    /** **************************************************************************************************** **
     **                                          INTERFACE METHODS                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Interface method representing the mock response
     * @param req The HTTP request object
     * @return      The mocked HttpResponse
     */
    public HttpResponse respond(HttpRequest req){

        // Validate a response Id is set, if not throw an error
        if(this.responseIdentifier == null){
            throw new MockResponseException(Mck.MSG_NO_REPONSE_ID);
        }

        // Validate a response object exists for the response Id
        if(!this.responseMap.containsKey(responseIdentifier)){
            throw new MockResponseException(String.format(Mck.MSG_INVALID_REPONSE_ID, new String[]{String.valueOf(responseIdentifier)}));
        }

        // Create the mock response object
        HttpResponse res = new HttpResponse();

        // Set the response status code
        res.setStatusCode(this.responseMap.get(responseIdentifier).getStatusCode());

        // Set the response body
        res.setBody(this.responseMap.get(responseIdentifier).getBody());

        // Set reponse headers
        for(String key : responseMap.get(responseIdentifier).getHeaders().keySet()){
            res.setHeader(key, responseMap.get(responseIdentifier).headers.get(key));
        }

        // Return the created mock response
        return res;
    }


    /** **************************************************************************************************** **
     **                                    PRIVATE DATA STRUCTURE CLASSES                                    **
     ** **************************************************************************************************** **/
    /**
     * @description A Class representing a Mock Http response data stucture
     */
    @TestVisible
    @JsonAccess(serializable='never' deserializable='never')
    private class Response{

        // Private variables in the response
        @TestVisible private Integer statusCode;
        @TestVisible private String  body;
        @TestVisible private Map<String,String> headers;


        /**
         * @description Constructor for the use of custom headers in the mock response
         * @param statusCode The HTTP Status code used in the reponse
         * @param body       The response body content
         * @param headers    Custom headers for the response 
         */
        private Response(Integer statusCode, String body, Map<String,String> headers){
            this.statusCode = (statusCode !=null) ? statusCode : 200;
            this.body       = (body       !=null) ? body       : '';
            this.headers    = (headers    !=null) ? headers    : new Map<String,String>{'Content-Type' => 'application/json; charset=UTF-8;'};
        }


        /**
         * @description Method to return the body
         * @return     The response body
         */
        private String getBody(){
            return this.body;
        }


        /**
         * @description Method to return the status code
         * @return     The response status code
         */
        private Integer getStatusCode(){
            return this.statusCode;
        }

        
        /**
         * @description Method to return the headers
         * @return     The response headers
         */
        private Map<String,String> getHeaders(){
            return this.headers;
        }
    }


    /** **************************************************************************************************** **
     **                                       GLOBAL EXCEPTION CLASSES                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Custom exception that is thrown when the Mck Class throws an exception
     */
    global class MockResponseException extends Exception{}
}