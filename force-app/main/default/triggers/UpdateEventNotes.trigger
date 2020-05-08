trigger UpdateEventNotes on ContentVersion (after insert,after update) {
    system.debug('inside UpdateEventNotes    ');
    ContentVersionTriggerHelper.UpdateEventNotes(trigger.new);
}