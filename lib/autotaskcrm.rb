require 'savon'
require 'httpclient'

class AutoTaskCrm
  def initialize(username = nil, password = nil)
    @client = nil

    Savon.configure do |config|
      config.raise_errors = true
      config.soap_version = 2
      config.log = false
      config.log_level = :fatal
    end

    HTTPI.log = false

    @client = Savon::Client.new do
      wsdl.document = "https://webservices3.autotask.net/atservices/1.5/atws.wsdl"
    end

    if !username.blank? and !password.blank?
      @client.http.auth.basic username, password
    elsif !AUTOTASK_CONFIG['username'].blank? and !AUTOTASK_CONFIG['password'].blank?
      @client.http.auth.basic AUTOTASK_CONFIG['username'], AUTOTASK_CONFIG['password']
    else
      return false
    end
  end

  def send_xml(xml)
    resp = @client.request :query do
      soap.body = { :sXML => "<queryxml>#{xml}</queryxml>" } 
    end

    resp.body[:query_response][:query_result][:entity_results].is_a?(Hash) ? resp : false
  end

  def get_ticket_id(ticket_name)
      return nil unless ticket_name.match(Regexp.new(/^T[0-9]{8}\.[0-9]{4}$/))

      resp = send_xml("<entity>ticket</entity><query><field>ticketnumber<expression op='equals'>#{ticket_name.strip}</expression></field></query>") 
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:id] : nil
  end

  def get_task_id(task_name)
      return nil unless task_name.match(Regexp.new(/^T[0-9]{8}\.[0-9]{4}$/))

      resp = send_xml("<entity>task</entity><query><field>tasknumber<expression op='equals'>#{task_name.strip}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:id] : nil
  end

  def get_project_by_task(task_name)
      return nil unless task_name.match(Regexp.new(/^T[0-9]{8}\.[0-9]{4}$/))

      resp = send_xml("<entity>task</entity><query><field>tasknumber<expression op='equals'>#{task_name.strip}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:project_id] : nil
  end

  def get_account_by_project(project_id)
      resp = send_xml("<entity>project</entity><query><field>id<expression op='equals'>#{project_id.strip}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:account_id] : nil
  end

  def get_accounts
    Rails.cache.fetch("accounts", :expires_in => 1.days) do
      resp = send_xml("<entity>account</entity><query><field>accountname<expression op='IsNotNull'></expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity].sort_by { |k,v| k[:account_name] } : nil
    end
  end

  def get_account_name(account_id)
    Rails.cache.fetch("account_name_#{account_id}", :expires_in => 1.weeks) do
      resp = send_xml("<entity>account</entity><query><field>id<expression op='equals'>#{account_id}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:account_name].strip : nil
    end
  end

  def get_contacts(account_id)
      resp = send_xml("<entity>contact</entity><query><field>AccountID<expression op='equals'>#{account_id}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity] : nil
  end

  def get_contact(contact_id)
    Rails.cache.fetch("contact_name_#{contact_id}", :expires_in => 1.weeks) do
      resp = send_xml("<entity>contact</entity><query><field>id<expression op='equals'>#{contact_id}</expression></field></query>")
      resp != false ? "#{resp.body[:query_response][:query_result][:entity_results][:entity][:first_name]} #{resp.body[:query_response][:query_result][:entity_results][:entity][:last_name]}" : nil
    end
  end

  def get_account_by_contact(contact_id)
    Rails.cache.fetch("account_by_contact_#{contact_id}", :expires_in => 4.weeks) do
      resp = send_xml("<entity>contact</entity><query><field>id<expression op='equals'>#{contact_id}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:account_id] : nil
    end
  end

  def get_account_by_ticket(ticket_id)
    Rails.cache.fetch("account_by_ticket_#{ticket_id}", :expires_in => 4.weeks) do
      resp = send_xml("<entity>ticket</entity><query><field>id<expression op='equals'>#{ticket_id}</expression></field></query>")
      resp != false ? resp.body[:query_response][:query_result][:entity_results][:entity][:account_id] : nil
    end
  end

  def get_account_udf(account_id, field)
    response = send_xml("<entity>account</entity><query><field>id<expression op='equals'>#{account_id}</expression></field></query>")
    hash = response != false ? response.body[:query_response][:query_result][:entity_results][:entity][:user_defined_fields] : ""
    if hash.is_a?(Hash)
      hash[:user_defined_field].each do |udf|
        return udf[:value] if udf[:name] == field
      end
        return ""
    else
      return ""
    end
  end

end
