/**
 * @author         Justus van den Berg (jfwberg@gmail.com)
 * @date           August 2023
 * @copyright      (c) 2023 Justus van den Berg
 * @license        MIT (See LICENSE file in the project root)
 * @description    Class that contains a set of Apex Unit Test Utilities:
 *                 - Test Run As User Creation Utils
 *                 - Force Exceptions / Conditions Utils
 *                 - Exception message assertion Utils
 *                 - Static Resource Utils
 * @false-positive PMD.AvoidGlobalModifier  This is a utility that is designed to be called from a
 *                                          managed package. It can be used for a user's own custom
 *                                          Implementation, so global is the way to open up this
 *                                          utility for global use.
 * @false-positive PMD.CyclomaticComplexity The class has a lot of methods, those combined makes it
 *                                          OK for this one
 * @note           This class is to be used in a managed package and contains Global methods that
 *                 should be made public or private in org based implementations or unlocked
 *                 packages
 */
@SuppressWarnings('PMD.AvoidGlobalModifier, PMD.CyclomaticComplexity')
global with sharing class Tst {

    /** **************************************************************************************************** **
     **                                          PRIVATE VARIABLES                                           **
     ** **************************************************************************************************** **/
    // Switch to override the safety message for testing purposes
    @TestVisible private static Boolean safetyOverride        = false;
    @TestVisible private static Boolean isRunningTestOverride = false;
    
    // Variable to hold any exception identifiers
    private static Set<String> forcedExceptionIdentifiers = new Set<String>{};

    // Variable to hold any condition identifiers
    private static Set<String> forcedConditionIdentifiers = new Set<String>{};


    /** **************************************************************************************************** **
     **                                           GLOBAL CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Test related constant
    global static final String TEST_SR_NAME = 'Lightweight_Apex_Unit_Test_Util_v2';
    global static final String TEST_SR_BODY = 'The quick brown fox jumps over the lazy dog';

    // The name of the permission set for this package
    global static final String PERMISSION_SET_NAME = 'Lightweight_Apex_Unit_Test_Util_v2';

    // User related variables
    global static final String STANDARD_USER_PROFILE  = 'Standard User';
    global static final String ADMINISTRATOR_PROFILE  = 'System Administrator';
    global static final String MINIMUM_ACCESS_PROFILE = 'Minimum Access - Salesforce';


    /** **************************************************************************************************** **
     **                                          PRIVATE CONSTANTS                                           **
     ** **************************************************************************************************** **/
    // Exception related messages
    @TestVisible private static final String FORCED_EXCEPTION_MESSAGE     = 'FORCED EXCEPTION MESSAGE';
    @TestVisible private static final String UNEXPECTED_EXCEPTION_MESSAGE = 'Unexpected exception message';
    @TestVisible private static final String SAFETY_MESSAGE               = 'An Exception should have been thrown. This part of the code should not have been reached.';

    // (Error) messages
    @TestVisible private static final String STATIC_RESOURCE_ERROR         = 'No static resource with the name "{0}" found in the metadata';
    @TestVisible private static final String PROFILE_DOES_NOT_EXIST_ERROR  = 'No profile with the name "{0}" found in the metadata';
    @TestVisible private static final String PERM_SET_DOES_NOT_EXIST_ERROR = 'Not all permission sets were found in the metadata: {0} provided but {1} found.';
    @TestVisible private static final String TEST_METHOD_ONLY_ERROR        = 'This method can ONLY be invoked through a test method.';
    @TestVisible private final static String INVALID_FIELD_VALUE_MAP_FIELD = 'Error when creating the run as user. The field "{0}" does not exist on sObject "{1}"';


    /** **************************************************************************************************** **
     **                                    NORMAL APEX CLASS SETTERS                                         **
     ** **************************************************************************************************** **/
    /**
     * @description Method to force an exception for specific identifier
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     */
    global static void forceException(String identifier){

        // Make sure this logic only run during tests as a safety measure
        // Throw a ForcedException when the forced exception identifier set contains the input identifier
        if(Test.isRunningTest() && forcedExceptionIdentifiers.contains(identifier)){
            throw new ForcedException(FORCED_EXCEPTION_MESSAGE);
        }
    }


    /**
     * @description Method to return TRUE for a  specific condition identifier
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     * @return TRUE if the specific identifier value has been added by the test method
     */
    global static Boolean forceCondition(String identifier){

        // Make sure this logic only run during tests as a safety measure
        // Return TRUE when the forced exception identifier set contains the input identifier
        return (Test.isRunningTest() && forcedConditionIdentifiers.contains(identifier));
    }


    /** **************************************************************************************************** **
     **                                        TEST CLASS GETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Method to that returns the default forced exception message
     */
    global static String getForcedExceptionMessage(){
        
        // Validate the method can only be invoked through a test-method
        checkTestStatus();
        
        // Return the default value
        return FORCED_EXCEPTION_MESSAGE;
    }


    /** **************************************************************************************************** **
     **                                        TEST CLASS SETTERS                                            **
     ** **************************************************************************************************** **/
    /**
     * @description Method to add an exception identifier from a test
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     */
    global static void addForcedException(String identifier){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Make sure the null values cannot be added
        if(String.isNotBlank(identifier)){
            forcedExceptionIdentifiers.add(identifier);
        }
    }


    /**
     * @description Method to remove an exception identifier from a test
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     */
    global static void removeForcedException(String identifier){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Make sure the null value cannot be removed
        if(String.isNotBlank(identifier)){
            forcedExceptionIdentifiers.remove(identifier);
        }
    }


    /**
     * @description Method to add a condition identifier from a test
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     */
    global static void addForcedCondition(String identifier){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Make sure the null values cannot be added
        if(String.isNotBlank(identifier)){
            forcedConditionIdentifiers.add(identifier);
        }
    }


    /**
     * @description Method to remove a condition identifier from a test
     * @param       identifier The exception or condition identifier.
     *                         When specified the code will throw an exception or return true.
     */
    global static void removeForcedCondition(String identifier){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Make sure the null value cannot be removed
        if(String.isNotBlank(identifier)){
            forcedConditionIdentifiers.remove(identifier);
        }
    }


    /** **************************************************************************************************** **
     **                                       GLOBAL ASSERTION METHODS                                       **
     ** **************************************************************************************************** **/
    /**
     * @description If you test an exception and for some reason it does not throw an exception you
     *              expect your test might become invalid
     *              To make sure your exception is actually thrown you can but in a safety assertion so
     *              your test will fail
     */
    global static void assertExceptionHasBeenThrow(){
        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Throw a safety message
        Assert.areEqual(true, safetyOverride, SAFETY_MESSAGE);
    }


    /**
     * @description Method to assert the default forced exception message
     * @param e The exception to assert
     */
    global static void assertForcedExceptionMessage(Exception e){
        Assert.areEqual(
            getForcedExceptionMessage(),
            e.getMessage()
        );
    }


    /**
     * @description Method to validate our exception messages with no additional details in the
     *              exception message
     * @param       expectedMessage The expected exception message
     * @param       actualMessage   The actual message to validate against
     */
    global static void assertExceptionMessage(String expectedMessage, String actualMessage){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        Assert.areEqual(
            expectedMessage,
            actualMessage,
            UNEXPECTED_EXCEPTION_MESSAGE
        );
    }


    /**
     * @description Method to validate our exception messages with no additional details
     * @param       expectedMessage The expected exception message
     * @param       e               The exception that has been thrown and whose message we want to assert against the expected message
     */
    global static void assertExceptionMessage(String expectedMessage, Exception e){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        assertExceptionMessage(expectedMessage, e.getMessage());
    }


    /**
     * @description Method to validate our exception messages with a single detail (i.e. My message
     *              with one {0} variable)
     * @param       expectedMessage The expected exception message
     * @param       firstDetail     The detailed error details of the exception message {0}
     * @param       actualMessage   The actual message we want to assert against the expected message
     */
    global static void assertExceptionMessage(String expectedMessage, String firstDetail, String actualMessage){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        assertExceptionMessage(String.format(expectedMessage, new String[]{firstDetail}), actualMessage);
    }


    /**
     * @description Method to validate our exception messages with a single detail (i.e. My message
     *              with one {0} variable)
     * @param expectedMessage The expected exception message
     * @param firstDetail     The detailed error details of the exception message {0}
     * @param e               The exception that has been thrown and whose message we want to assert against the expected message
     */
    global static void assertExceptionMessage(String expectedMessage, String firstDetail, Exception e){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        assertExceptionMessage(expectedMessage, firstDetail, e.getMessage());
    }


    /**
     * @description Method to validate our exception messages with a two detailed message (i.e. My message
     *              with a first {0} and a second {1} variable)
     * @param expectedMessage The expected exception message
     * @param firstDetail     The detailed error details of the exception message {0}
     * @param secondDetail    The second level of error details {1}
     * @param actualMessage   The actual message we want to assert against the expected message
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    global static void assertExceptionMessage(String expectedMessage, String firstDetail, String secondDetail, String actualMessage){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        assertExceptionMessage(String.format(expectedMessage, new String[]{firstDetail, secondDetail}), actualMessage);
    }


    /**
     * @description Method to validate our exception messages with a two detailed message (i.e. My message
     *              with a first {0} and a second {1} variable)
     * @param expectedMessage The expected exception message
     * @param firstDetail     The detailed error details of the exception message {0}
     * @param secondDetail    The second level of error details {1}
     * @param e               The exception that has been thrown and whose message we want to assert against the expected message
     */
    @SuppressWarnings('PMD.ExcessiveParameterList')
    global static void assertExceptionMessage(String expectedMessage, String firstDetail, String secondDetail, Exception e){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Assert the exception message
        assertExceptionMessage(expectedMessage, firstDetail, secondDetail, e.getMessage());
    }


    /** **************************************************************************************************** **
     **                                     GLOBAL USER UTILIY METHODS                                       **
     ** **************************************************************************************************** **/
     /**
     * @description Method to create a run as user without any permission sets
     * @param       profileName        The (api) name of the Profile
     * @return      A User record that can be used with the runAs() function
     */
    global static User createRunAsUser(String profileName){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Create the run as user
        return createRunAsUser(profileName, null, null);
    }


    /**
     * @description Method to create a run as user with a single permission set
     * @param       profileName        The (api) name of the Profile
     * @param       permissionSetName  The (api) name of the Permission Set
     * @return      A User record that can be used with the runAs() function
     */
    global static User createRunAsUser(String profileName, String permissionSetName){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Create the run as user
        return createRunAsUser(profileName, new String[]{permissionSetName});
    }


    /**
     * @description Method to create a run as user with multiple permission sets
     * @param       profileName        The (api) name of the Profile
     * @param       permissionSetNames The (api) names of the Permission Sets
     * @return      A User record that can be used with the runAs() function
     */
    global static User createRunAsUser(String profileName, String[] permissionSetNames){
        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Create the run as user
        return createRunAsUser(profileName, permissionSetNames, null);
    }


    /**
     * @description Method to create a run as user with  permission sets and field overrides
     * @param       profileName        The (api) name of the Profile
     * @param       permissionSetNames The (api) names of the Permission Sets
     * @param       fieldOverrides     A map that contains custom field values for the user
     * @return      A User record that can be used with the runAs() function
     */
    global static User createRunAsUser(String profileName, String[] permissionSetNames, Map<String,Object> fieldOverrides){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Create a new user
        User runAsUser = new User();

        // Query profile Id
        String profileId = [SELECT Id FROM Profile WHERE Name = :profileName WITH SYSTEM_MODE LIMIT 1]?.Id;

        // Throw an exception when the profile does not exists
        if(profileId == null){
            throw new InvalidDataException(String.format(PROFILE_DOES_NOT_EXIST_ERROR, new String[]{profileName}));
        }

        // Create a random username
        String username = EncodingUtil.convertToHex(Crypto.generateAESKey(128)) + '@' + EncodingUtil.convertToHex(Crypto.generateAESKey(128)) +'.com.invalid';

        // Setup a user, so you can run the test code for a specific profile / permission set
        runAsUser.Alias             = userName.subString(0,8);
        runAsUser.UserName          = userName;
        runAsUser.Email             = userName;
        runAsUser.FirstName         = 'Apex Unit Test';
        runAsUser.LastName          = 'Temporary User';
        runAsUser.EmailEncodingKey  = 'UTF-8';
        runAsUser.LanguageLocaleKey = 'en_US';
        runAsUser.LocaleSidKey      = 'en_US';
        runAsUser.TimeZoneSidKey    = 'Europe/London';
        runAsUser.ProfileId         = profileId;
        runAsUser.IsActive          = true;

        // If there are any default field values that need to be overwritten do it here
        populateSObjectValuesFromMapData(runAsUser,fieldOverrides);

        // Insert the user
        insert as system runAsUser;

        // If there are no permission sets simply return the user
        if(permissionSetNames == null || permissionSetNames.isEmpty()){
            return runAsUser;
        }

        // Create permission set assignments
        createPermissionSetAssignments(runAsUser,permissionSetNames);

        // Return the newly created user
        return runAsUser;
    }


    /**
     * @description Method to get a User Object for the currently logged in User
     *              Used for support with the run as methods
     * @return      The User object for the current running user
     */
    global static User getRunningUser(){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        // Query the current user
        return [SELECT Id FROM User WHERE Id=:UserInfo.getUserId() WITH SYSTEM_MODE LIMIT 1];
    }


    /** **************************************************************************************************** **
     **                                     GLOBAL TEST UTILITY METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method to get a text body from a static resource
     *              Ideal if you have stored cert data (temporarily) in a static resource or during
     *              apex tests
     * @param       staticResourceName   The developer name of the static resource you want the body
     *                                   value from
     * @return      Static resource body
     * @throws      InvalidDataException There is an issue with the static resource
     */
    global static String getStaticResourceBody(String staticResourceName){

        // Validate the method can only be invoked through a test-method
        checkTestStatus();

        try{
            return ([SELECT Body FROM StaticResource WHERE Name = :staticResourceName LIMIT 1].Body).toString();
        }catch(System.QueryException e){
            throw new InvalidDataException(String.format(STATIC_RESOURCE_ERROR, new String[]{staticResourceName}));
        }
    }


    /** **************************************************************************************************** **
     **                                     PRIVATE TEST UTILITY METHODS                                     **
     ** **************************************************************************************************** **/
    /**
     * @description Method to validate a method is running in a test context only
     */
    @TestVisible
    private static void checkTestStatus(){
        if(!Test.isRunningTest() || isRunningTestOverride){
            throw new TestContextException(TEST_METHOD_ONLY_ERROR);
        }
    }


    /**
     * @description Method to create permission set assignments for a specified user
     * @param runAsUser          The User to assign the permission sets to
     * @param permissionSetNames The (api) names of the Permission Sets
     */
    private static void createPermissionSetAssignments(User runAsUser, String[] permissionSetNames){

        // Create a list to hold the permission set(s) that are to be applied to the running as
        PermissionSetAssignment[] permissionSetAssignments = new PermissionSetAssignment[]{};

        // Query permission sets and, if permission set value equals null do not query but just get a new list
        for (PermissionSet permissionSet : [SELECT Id FROM PermissionSet WHERE Name IN :permissionSetNames WITH SYSTEM_MODE LIMIT 100 ]){
            permissionSetAssignments.add(
                new PermissionSetAssignment(
                    AssigneeId      = runAsUser.Id,
                    PermissionSetId = permissionSet.Id
                )
            );
        }

        // Tell the user that not all permission sets were found
        if(permissionSetAssignments.size() != permissionSetNames.size()){
            throw new InvalidDataException(
                String.format(
                    PERM_SET_DOES_NOT_EXIST_ERROR,
                    new String[]{String.valueOf(permissionSetNames.size()),String.valueOf(permissionSetAssignments.size())}
                )
            );
        }

        // Insert the permission set assignments
        insert as system permissionSetAssignments;
    }


    /**
     * @description Method to populate data on an sObject from an Object Map
     * @param sObj                     The sObject to populate with data
     * @param fieldNameFieldValueMap The data to populate in the sObject
     */
    private static void populateSObjectValuesFromMapData(sObject sObj, Map<String,Object> fieldNameFieldValueMap){
        
        // Null check, do nothing if any of the values equals null
        if(sObj ==  null || fieldNameFieldValueMap == null){return;}

        // Fetch the fields from the metadata so we can check they exist
        Schema.SObjectType sObjectType = sObj.getSObjectType();

        // Create a set with all the valid field names
        Set<String> fieldApiNames = sObjectType.getDescribe(SObjectDescribeOptions.DEFERRED).fields.getMap().keySet();

        // Populate the data from the data map
        for(String fieldName : fieldNameFieldValueMap.keySet()){

            // Check the field exists on the sObject or throw an exception
            if(!fieldApiNames.contains(fieldName.toLowerCase())){
                throw new InvalidDataException(
                    String.format(
                        INVALID_FIELD_VALUE_MAP_FIELD,
                        new String[]{fieldName,String.valueOf(sObjectType)}
                    )
                );
            }

            // Populate the field
            sObj.put(fieldName,fieldNameFieldValueMap.get(fieldName));
        }
    }


    /** **************************************************************************************************** **
     **                                      GLOBAL EXCEPTION CLASSES                                        **
     ** **************************************************************************************************** **/
    /**
     * @description An exception that was forced for the sole purpose of testing a
     *              difficult / impossible to reach exception statement
     * @note        This class is private and test visible as it should only be ever caught
     *              when an Apex Unit Test is running and never from normal code
     */
    global with sharing class ForcedException extends Exception{}


    /** **************************************************************************************************** **
     **                                     PRIVATE EXCEPTION CLASSES                                        **
     ** **************************************************************************************************** **/
    /**
     * @description An exception that is thrown when something goes wrong retrieving
     *              any (meta) data
     * @note        This class is private and test visible as it should only be ever caught
     *              when an Apex Unit Test is running and never from normal code
     */
    @TestVisible
    private with sharing class InvalidDataException extends Exception{}


    /**
     * @description An exception that is thrown when code is not executed in a test context
     * @note        This class is private and test visible as it should only be ever caught
     *              when an Apex Unit Test is running and never from normal code
     */
    @TestVisible
    private with sharing class TestContextException extends Exception{}
}