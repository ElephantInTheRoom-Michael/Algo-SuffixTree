# frozen_string_literal: true

require_relative "edge"
require_relative "node"
require_relative "active_point"
require_relative "searcher"

module ElephantInTheRoom
  module UkkonenSuffixTree
    class UkkonenSuffixTree
      include Searcher

      attr_accessor :logger
      attr_accessor :logger_redact_text

      def initialize
        @letters = []

        @root = Node.new(@letters)
        @active_point = ActivePoint.new(@root, @letters)
        @remainder = 0
      end

      def to_s
        @root.print_tree
      end

      def add(text)
        @logger&.warn { "Add text to tree#{": #{text}" unless @logger_redact_text}" }
        text.each_char { add_letter(_1) }
        @logger&.info { "Tree built for cumulative text#{": #{@letters.join}" unless @logger_redact_text}" }
        @logger&.warn("Tree is not ready for suffix search") if @remainder > 0
      end

      def finalize
        @logger&.info("Start finalizing tree")

        while @remainder > 0
          @logger&.info { "#{@remainder} remaining suffixes to insert#{" at active point #{@active_point}" unless logger_redact_text}" }

          node_to_replace = if @active_point.length > 0
            @logger&.debug("Split active edge and insert end node")
            @active_point.split_active_edge
          else
            @logger&.debug("Replace active node with end node")
            @active_point.node
          end
          raise "Root node must not be replaced with end node" unless node_to_replace.is_a?(InnerNode)
          node_to_replace.replace_with_end_node

          @remainder -= 1
          @active_point.move_after_suffix_inserted
        end

        @logger&.warn("Tree is ready for suffix search")
      end

      def contains?(text)
        result = search(text, @root, false)
        logger&.warn("Text#{result ? "" : " not"} found in tree#{": #{text}" unless logger_redact_text}")
        result
      end

      def ends_with?(text)
        result = search(text, @root, true)
        logger&.warn("Text suffix#{result ? "" : " not"} found in tree#{": #{text}" unless logger_redact_text}")
        result
      end

      private

      def add_letter(letter)
        @logger&.debug { "Add letter#{": #{letter}" unless @logger_redact_text}" }

        @letters << letter

        @remainder += 1
        process_remainder
      end

      def process_remainder
        continue = true
        last_new_node = nil # : Node?
        while @remainder > 0 && continue
          @logger&.info { "#{@remainder} remaining suffixes to insert#{" at active point #{@active_point}" unless logger_redact_text}" }
          @logger&.debug { "Try to insert suffix#{": #{@letters[-@remainder..]&.join}" unless @logger_redact_text}" }
          continue, new_node = step
          if continue
            @logger&.debug("Inserted suffix")
            @remainder -= 1
            @active_point.move_after_suffix_inserted
          end
          if !last_new_node.nil? && !new_node.nil?
            @logger&.debug { "Add suffix link#{" from #{last_new_node} to #{new_node}" unless logger_redact_text}" }
            last_new_node.suffix_link = new_node
          end
          last_new_node = new_node
        end
        @logger&.info { "#{@remainder} remaining suffixes can not be inserted yet" } if @remainder > 0
      end

      def step
        letter = @letters[-1]

        new_node = nil
        add_edge = false

        unless @active_point.advance_active_point(letter)
          if @active_point.length == 0
            @logger&.debug("Create new edge")
            add_edge = true
          else
            new_node = @active_point.split_active_edge
            add_edge = true
          end
          (new_node || @active_point.node).add_edge(@letters.length - 1)
        end

        @logger&.debug("Suffix not completely inserted") unless add_edge
        [ add_edge, new_node ]
      end
    end
  end
end
