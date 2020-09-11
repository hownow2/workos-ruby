# frozen_string_literal: true
# typed: true

require 'net/http'

module WorkOS
  # The Portal module provides resource methods for working with the Admin
  # Portal product
  module Portal
    class << self
      extend T::Sig
      include Base
      include Client

      # Create an organization
      #
      # @param [Array<String>] domains List of domains that belong to the
      #  organization
      # @param [String] name A unique, descriptive name for the organization
      sig do
        params(
          domains: T::Array[String],
          name: String,
        ).returns(WorkOS::Organization)
      end
      def create_organization(domains:, name:)
        request = post_request(
          auth: true,
          body: { domains: domains, name: name },
          path: '/organizations',
        )

        response = execute_request(request: request)
        check_and_raise_organization_error(response: response)

        WorkOS::Organization.new(response.body)
      end

      # Retrieve a list of organizations that have connections configured
      # within your WorkOS dashboard.
      #
      # @param [String] domain Filter organizations to only return those that
      #  are associated with the provided domain.
      # @param [String] before A pagination argument used to request
      #  organizations before the provided Organization ID.
      # @param [String] after A pagination argument used to request
      #  organizations after the provided Organization ID.
      # @param [Integer] limit A pagination argument used to limit the number
      #  of listed Organizations that are returned.
      sig do
        params(
          options: T::Hash[Symbol, String],
        ).returns(WorkOS::Types::ListStruct)
      end
      # rubocop:disable Metrics/MethodLength
      def list_organizations(options = {})
        response = execute_request(
          request: get_request(
            path: '/organizations',
            auth: true,
            params: options,
          ),
        )

        parsed_response = JSON.parse(response.body)

        WorkOS::Types::ListStruct.new(
          data: parsed_response['data'],
          list_metadata: parsed_response['listMetadata'],
        )
      end
      # rubocop:enable Metrics/MethodLength

      private

      sig { params(response: Net::HTTPResponse).void }
      # rubocop:disable Metrics/MethodLength
      def check_and_raise_organization_error(response:)
        begin
          body = JSON.parse(response.body)
          return unless body['message']

          message = body['message']
          request_id = response['x-request-id']
        rescue StandardError
          message = 'Something went wrong'
        end

        raise APIError.new(
          message: message,
          http_status: nil,
          request_id: request_id,
        )
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end