class CfmeBzClient
  class Response
    attr_reader   :status, :code, :result, :message
    attr_accessor :status, :code, :result, :message

    def initialize(status, code, result = {}, message = "")
      assign(status, code, result, message)
    end

    def assign(status, code, result, message)
      @status   = status
      @code     = code
      @result   = result
      @message  = message
    end
  end
end
