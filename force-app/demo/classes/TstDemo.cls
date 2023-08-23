/**
 * @description A class that shows a number of scenarios on how to implement
 *              exception testing.
 *              The TstDemoTest Class gives the full demo of features. The methods
 *              in this class are to support the test class.
 */
@SuppressWarnings('PMD.AvoidDebugStatements, PMD.DebugsShouldUseLoggingLevel')
public with sharing class TstDemo {

    // Error messages should be in a label so it can be reused in the test class
    @TestVisible private final static String DELIMITER            = ' :: ';
    @TestVisible private final static String DEBUG_ABC_MESSAGE    = 'Unable to debug "abc"';
    @TestVisible private final static String SINGLE_PARAM_MESSAGE = 'The sObject "{0}" does not exist in the metadata';
    @TestVisible private final static String MULTI_PARAM_MESSAGE  = 'The field "{0}" does not exist on sObject "{1}"';


    /**
     * @description An example implementation of the utl.Tst.forceException() method
     *              that is used to force an exception at that point in the code.
     */
    public static void unreachableException(){
        // Force exception logic if a test is running and the DEBUG_ABC identifier has been added
        // The force exception method throws a default error that can be validated using the 
        // utl.Tst.getDefaultForcedExceptionMessage() method in the test class
        utl.Tst.forceException('DEBUG_ABC');

        // Execute method logic
        System.debug('abc');
    }


    /**
     * @description An example implementation of the utl.Tst.forceException() method
     *              that is used to force an exception at that point in the code.
     *              This example referenced the standard forced error message that can 
     *              be referenced by using the utl.Tst.getForcedExceptionMessage() method
     */
    public static void unreachableExceptionWithDetails(){
        try{
            // Force exception logic if a test is running and the DEBUG_ABC identifier has been added
            utl.Tst.forceException('DEBUG_ABC');

            // Execute method logic
            System.debug('abc');

        }catch(Exception e){
            // Now add some additional information into the error message
            throw new StringException(DEBUG_ABC_MESSAGE + DELIMITER + e.getMessage());
        }
    }


    /**
     * @description An example implementation of the utl.Tst.forceCondition() method
     *              that is used to force a TRUE condition in an if statement
     */
    public static void forcedCondition(){
        
        // Force a condition to be true (works only in tests)
        if(false || utl.Tst.forceCondition('DEBUG_ABC')){
            throw new StringException(DEBUG_ABC_MESSAGE);
        }
        
        // Execute method logic
        System.debug('abc');
    }


    /**
     * @description An example implementation of the assertExceptionMessage() method
     *              that has multiple parameters
     * @param param1 The first parameter in the exceptino message ({0})
     */
    public static void throwExceptionWithSingleParameter(String param1){
        throw new StringException(
            String.format(
                SINGLE_PARAM_MESSAGE,
                new String[]{param1}
            )
        );
    }

    
    /**
     * @description An example implementation of the assertExceptionMessage() method
     *              that has multiple parameters
     * @param param1 The first parameter in the exceptino message ({0})
     * @param param2 The second parameter in the exceptino message ({1})
     */
    public static void throwExceptionWithTwoParameters(String param1, String param2){
        throw new StringException(
            String.format(
                MULTI_PARAM_MESSAGE,
                new String[]{param1,param2}
            )
        );
    }

}