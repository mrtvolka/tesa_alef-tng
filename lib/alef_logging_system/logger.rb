module AlefLoggingSystem
  class Logger

      TAG = {
        UNKNOWN: "\e[34m[UNKNOWN]:\e[0m ",
        FATAL: "\e[31m[FATAL]:\e[0m ",
        ERROR: "\e[31m[ERROR]:\e[0m ",
        WARN: "\e[33m[WARN]:\e[0m ",
        INFO: "\e[32m[INFO]:\e[0m ",
        DEBUG: "\e[35m[DEBUG]:\e[0m "
      }

      LEVEL = {
          UNKNOWN: 5,
          FATAL: 4,
          ERROR: 3,
          WARN: 2,
          INFO: 1,
          DEBUG: 0
      }

      def self.send(message, level = nil, *params)
        if LEVEL[level].nil?
            Rails.logger.add 5,"[ALEF \| #{Time.current} \| #{params} ] \e[34m[UNKNOWN]:\e[0m " + message
        else
            Rails.logger.add LEVEL[level],"[ALEF \| #{Time.current} \|#{params} ] " + TAG[level] + message
        end

      end

      def self.unknown(message, *params)
        send(message, :UNKNOWN, params)
      end

      def self.fatal(message, *params)
        send(message, :FATAL, params)
      end

      def self.error(message, *params)
        send(message, :ERROR, params)
      end

      def self.warn(message, *params)
        send(message, :WARN, params)
      end

      def self.info(message, *params)
        send(message, :INFO, params)
      end

      def self.debug(message, *params)
        send(message, :DEBUG, params)
      end

  end
end