
/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           October 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of Apex Unit Test Utilities to create a generic,
 *                 reusable Callable Mock that allows for testing responses from classes
 *                 that might not be part of your org. In practice this is mainly for test
 *                 coverage as your callable logic should be tested in the implementing class.
 * 
 * @note           This class optimised for use outside of a namespaced package and all global references have been
 *                 removed in favour of @TestVisible annotations
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
public class CallableMockUtil implements Callable{

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Map holding the action name and the mock response the class will return
    private Map<String,Object> actionResponseMap = new Map<String,Object>();
    
    
    /** **************************************************************************************************** **
     **                                       PRIVATE STATIC VARIABLES                                       **
     ** **************************************************************************************************** **/
    // Class instance of the mock response
    private static CallableMockUtil instance;


    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Messages
    @TestVisible private static final String INVALID_ACTION_MSG = 'Invalid Callable action: "{0}". Please make sure the action is added using the setActionResponse() method';


    /** **************************************************************************************************** **
     **                                             CONSTRUCTORS                                             **
     ** **************************************************************************************************** **/
    /**
     * @description Main constructor to be private as it's a singleton
     */
    @SuppressWarnings('PMD.EmptyStatementBlock')
    private CallableMockUtil(){}


    /** **************************************************************************************************** **
     **                                        TEST CLASS SETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @Description Method to add an action with matching response to the mock
     *              This method should be imlemented in TEST methods only
     */
    @TestVisible
    private static void setActionResponse(String action, Object response){
        getInstance().actionResponseMap.put(action,response);
    }


    /** **************************************************************************************************** **
     **                                    NORMAL APEX CLASS SETTERS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to return the Mock Instance of the Callable
     *              Implement this in your "Normal" apex classes
     * @example     if(Test.isRunningTest()){return (Callable) utl.CallableMockUtil.getInstance();}
     */
    public static CallableMockUtil getInstance(){
        if(instance == null){
            instance = new CallableMockUtil();
        }
        return instance;
    }


    /** **************************************************************************************************** **
     **                                          INTERFACE METHODS                                           **
     ** **************************************************************************************************** **/
    /**
     * @description Method to call and action based on a string. In this mock implementation
     *              the call method will return the action
     * @param action The method name
     * @param args   Normally this would contain the action method arguments, but in the case
     *               of the mock implementation this can be an empty map or blank as it is ignored.
     * @return       the action that has been set through the setActionResponse() method
     */
    public Object call(String action, Map<String, Object> args){
        
        // Throw an error if the selected response does not exist
        if(!this.actionResponseMap.containsKey(action)){
            throw new MockCallableException(String.format(CallableMockUtil.INVALID_ACTION_MSG,new String[]{action}));
        }

        // Return the user defined object, the args are simply ignored
        return this.actionResponseMap.get(action);
    }


    /** **************************************************************************************************** **
     **                                       GLOBAL EXCEPTION CLASSES                                       **
     ** **************************************************************************************************** **/
    /**
     * @description Custom exception that is thrown when the Mck Class throws an exception
     */
    public class MockCallableException extends Exception{}
}