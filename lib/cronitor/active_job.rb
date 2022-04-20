# frozen_string_literal: true

require_relative "active_job/version"
require "cronitor"

module Cronitor
  # Notify Cronitor of ActiveJob progress around perform
  module ActiveJob
    extend ActiveSupport::Concern

    included do
      around_perform :cronitor_instrumentation

      def self.cronitor_disabled(disabled)
        @cronitor_disabled = !!disabled
      end

      def self.cronitor_disabled?
        @cronitor_disabled || false
      end

      def self.cronitor_key(key)
        @cronitor_key = key
      end

      def self.cronitor_job_key
        @cronitor_key || name
      end
    end

    private

    def cronitor_instrumentation(&block)
      if should_ping?
        Cronitor.job(self.class.cronitor_job_key, &block)
      else
        yield
      end
    end

    def should_ping?
      Cronitor.api_key.present? && !self.class.cronitor_disabled?
    end
  end
end
