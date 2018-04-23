module Sp2db
  class Client

    include Logging

    attr_accessor :credential, :session

    def initialize

    end

    def config
      Sp2db.config
    end

    def credential
      @credential ||= config.credential
    end

    def session
      logger.debug "Init session"
      unless credential = self.credential
        return @session = saved_session
      end

      key = OpenSSL::PKey::RSA.new(credential['private_key'])
      auth = Signet::OAuth2::Client.new(
        token_credential_uri: credential['token_uri'],
        audience: credential['token_uri'],
        scope: %w(
          https://www.googleapis.com/auth/drive
          https://spreadsheets.google.com/feeds/
        ),
        issuer: credential['client_email'],
        signing_key: key
      )

      auth.fetch_access_token!
      @session = GoogleDrive.login_with_oauth(auth.access_token)
    end


    def saved_session
      logger.debug "Use saved session"
      GoogleDrive.saved_session Sp2db.config.personal_credential,
                                nil,
                                client_id: config.client_id,
                                client_secret: config.client_secret
    end

    def spreadsheet sid
      Spreadsheet.new session.spreadsheet_by_key(sid)
    end

  end
end
