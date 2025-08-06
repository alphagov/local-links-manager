module GoogleAnalytics
  class AnalyticsImportService
    def client
      @client ||= Client.new.build
    end

    def activity
      request = ClicksRequest.new.build

      response = client.batch_get_reports(request)
      ClicksResponse.new.parse(response)
    end
  end
end
