# Interface to HylaFAX
class Print::HylafaxDriver
  attr_reader :print, :job_number

  class << self
    def statuses(printer)
      HylaFAX.faxstat(
        host: printer.host,
        port: printer.port,
        user: printer.user,
        password: printer.password).inject({}) do |memo, (job_number,status)|
          memo[job_number] = convert_status(status)
          memo
        end
    end

    private

    def convert_status(status)
      case status
        when :done   then :completed
        when :failed then :aborted
        else              :active
      end
    end
  end

  def initialize(print)
    @print = print
  end

  def run
    @job_number = HylaFAX.sendfax(
      host: printer.host,
      port: printer.port,
      user: printer.user,
      password: printer.password,
      dialstring: dialstring,
      document: print.path)
  end

  private

  def printer
    print.printer
  end

  def dialstring
    [printer.dialout_prefix, print.fax_number].join
  end
end
