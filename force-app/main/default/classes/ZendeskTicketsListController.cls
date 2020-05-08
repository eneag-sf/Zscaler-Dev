public class ZendeskTicketsListController {
    public Id accountId { get; set; }
    public String retUrl { get; set; }
    public Integer limitValue { get; set; }
    public Integer recordCount { get; set; }

    public ZendeskTicketsListController() {
        limitValue = 5;
        recordCount = 0;
    }

    public List<ZendeskTicketsWrapper> getTickets() {
        List<ZendeskTicketsWrapper> ticketsList = new List<ZendeskTicketsWrapper>();
        if (accountId != null) {
            for (Zendesk__Zendesk_Ticket__c ticket : [SELECT Id, Name, Zendesk__Status__c, Zendesk__Priority__c, Sub_Area__c, 
            Zendesk__Date_Time_created__c, Zendesk__Date_Time_solved__c,
            Zendesk__Type__c, Zendesk__Subject__c, Management_Notes__c
            FROM Zendesk__Zendesk_Ticket__c WHERE (Sub_Area__c = 'ZMCA' or (Area__c = 'TAM' and Sub_Area__c = 'weekly_project_meeting')) and Zendesk__Status__c = 'Open' and Zendesk__Organization__c = :accountId
            ORDER BY Sub_Area__c DESC NULLS LAST LIMIT :limitValue]) {
                ticketsList.add(new ZendeskTicketsWrapper(
                    ticket.Id,
                    ticket.Name,
                    ticket.Zendesk__Status__c,
                    ticket.Zendesk__Priority__c,
                    ticket.Sub_Area__c,
                    ticket.Zendesk__Date_Time_created__c,
                    ticket.Zendesk__Date_Time_solved__c,
                    ticket.Zendesk__Type__c,
                    ticket.Zendesk__Subject__c,
                    ticket.Management_Notes__c
                ));
                recordCount = recordCount + 1;
            }

            return ticketsList;
        } else {
            return new List<ZendeskTicketsWrapper>();
        }
    }

    public PageReference showMore() {
        limitValue += limitValue;

        return null;
    }

    public class ZendeskTicketsWrapper {
        public Id ticketId { get; set; }
        public String ticketName { get; set; }
        public String status { get; set; }
        public String priority { get; set; }
        public String subarea{ get; set; }
        public Datetime datetimeCreated { get; set; }
        public Datetime datetimeSolved { get; set; }
        public String type { get; set; }
        public String subject { get; set; }
        public String managementNotes { get; set; }

        public ZendeskTicketsWrapper(Id ticketId, String ticketName, String status, String priority, String subarea, Datetime datetimeCreated,
            Datetime datetimeSolved, String type, String subject, String managementNotes) {
            this.ticketId = ticketId;
            this.ticketName = ticketName;
            this.status = status;
            this.priority = priority;
            this.subarea = subarea;
            this.datetimeCreated = datetimeCreated;
            this.datetimeSolved = datetimeSolved;
            this.type = type;
            this.subject = subject;
            this.managementNotes = managementNotes;
        }
    }
}