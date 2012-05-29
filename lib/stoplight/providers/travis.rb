#
# Stoplight Provider for Travis CI (http://travis-ci.org)
#
# Travis does not conform to the multi-project reporting spec, so
# we need to define our own provider
#

module Stoplight::Providers
  class Travis < Provider
    def provider
      'travis'
    end

    def projects
      @projects ||= @response.parsed_response.collect do |project|
        Stoplight::Project.new({
          :name => project['slug'].split(/\//).last,
          :build_url => "http://travis-ci.org/#{project['slug']}",
          :last_build_id => project['last_build_number'].to_s,
          :last_build_time => project['last_build_finished_at'],
          :last_build_status => status_to_int(project['last_build_status']),
          :current_status => current_status_to_int(project['last_build_finished_at'])
        })
      end
    end

    private
    def status_to_int(status)
      status || -1
    end

    def current_status_to_int(status)
      return 1 if status.nil? # building
      begin
        DateTime.parse(status)
        0
      rescue ArgumentError
        -1
      end
    end
  end
end