public inherited sharing class CalendarificAPIResponseWrapper {

    public cls_meta meta {get;set;}
	public cls_response response {get;set;}

	public class cls_meta {
		public Integer code {get;set;}
		public String error_type {get;set;}
		public String error_detail {get;set;}
	}
	public class cls_response {
		public cls_holidays[] holidays {get;set;}
	}
	public class cls_holidays {
		public String name {get;set;}
		public String description {get;set;}
		public cls_date dateVar {get;set;}
		public List<String> type {get;set;}
	}
	public class cls_date {
		public String iso {get;set;}
		public cls_datetime datetimeVar {get;set;}
	}
	public class cls_datetime {
		public Integer year {get;set;}
		public Integer month {get;set;}
		public Integer day {get;set;}
	}
	
	public static CalendarificAPIResponseWrapper parse(String json){
		return (CalendarificAPIResponseWrapper) System.JSON.deserialize(json, CalendarificAPIResponseWrapper.class);
	}
}