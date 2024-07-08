public class NBAGoogleAnalyticsWrapper {

public class ColumnHeader {
		public List<String> dimensions;
		public MetricHeader metricHeader;
	}

	public class Metrics {
		public List<String> values;
	}

	public List<Reports> reports;

	public class MetricHeaderEntries {
		public String name;
		public String type;
	}

	public class MetricHeader {
		public List<MetricHeaderEntries> metricHeaderEntries;
	}

	public class Reports {
		public ColumnHeader columnHeader;
		public Data data;
		public String nextPageToken;
	}

	public class Data {
		public List<Rows> rows;
		public List<Metrics> totals;
		public Integer rowCount;
		public List<Metrics> minimums;
		public List<Metrics> maximums;
	}

	public class Rows {
		public List<String> dimensions;
		public List<Metrics> metrics;
	}

	
	public static NBAGoogleAnalyticsWrapper parse(String json) {
		return (NBAGoogleAnalyticsWrapper) System.JSON.deserialize(json, NBAGoogleAnalyticsWrapper.class);
	}

}