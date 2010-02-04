module Redish
  class Application

    COMMANDS = [
      "auth",
      "bgrewriteaof",
      "bgsave",
      "blpop",
      "brpop",
      "dbsize",
      "decr",
      "decrby",
      "del",
      "exists",
      "expire",
      "flushall",
      "flushdb",
      "get",
      "getset",
      "incr",
      "incrby",
      "info",
      "keys",
      "lastsave",
      "lindex",
      "llen",
      "lpop",
      "lpush",
      "lrange",
      "lrem",
      "lset",
      "ltrim",
      "mget",
      "monitor",
      "move",
      "mset",
      "msetnx",
      "quit",
      "randomkey",
      "rename",
      "renamenx",
      "rpop",
      "rpoplpush",
      "rpush",
      "sadd",
      "save",
      "scard",
      "sdiff",
      "sdiffstore",
      "select",
      "set",
      "setnx",
      "shutdown",
      "sinter",
      "sinterstore",
      "sismember",
      "slaveof",
      "smembers",
      "smove",
      "sort",
      "spop",
      "srandmember",
      "srem",
      "sunion",
      "sunionstore",
      "ttl",
      "type",
      "zadd",
      "zcard",
      "zincrby",
      "zrange",
      "zrangebyscore",
      "zrem",
      "zremrangebyscore",
      "zrevrange",
      "zscore"
    ].sort

    HELP = %Q{Usage:

db [num] - switch

help - displays this document

exit - quits redis-shell
quit - quits redis-shell

Available Redis commands:

#{Redish::Application::COMMANDS.join ", "}

    }

    def initialize(options)
      @redis = Redis.new options
    end

    def run
      info = @redis.info
      puts "Using Redis #{info[:redis_version]}-#{info[:arch_bits]}"

      setup_autocompletion

      loop do
        begin
          command = Readline.readline "redis> ", true
          command = command.chomp.split " "

          unless command[0].nil?
            if ["quit", "exit"].include?(command[0])
              break

            elsif command[0] == "help"
              puts Redish::Application::HELP

            elsif command[0] == "db"
              @redis = Redis.new :db => command[1]
              puts "Switched to database #{command[1]}."

            elsif ["test"].include?(command[0])
              puts "-ERR unknown command '#{command[0]}'"

            elsif command.length == 1
              pp @redis.send(command[0].to_sym)

            else
              pp @redis.send(command[0].to_sym, *command[1..command.length])
            end
          end

        rescue RuntimeError => e
          puts e.message

        rescue Interrupt => e
          break

        end
      end
    end


    private


    def setup_autocompletion
      comp = proc { |s| Redish::Application::COMMANDS.grep( /^#{Regexp.escape(s)}/ ) }

      Readline.completion_append_character = " "
      Readline.completion_proc = comp
    end

  end
end