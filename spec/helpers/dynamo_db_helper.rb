# ==============================================================================
# spec - request dynamo db helper
# ==============================================================================
module DynamoDBHelper
  module_function

  def migrate_dynamodb
    client_options = options

    cfg = Aws::Record::TableConfig.define do |t|
      t.client_options(client_options)
      t.model_class(AppConstant)
      t.read_capacity_units(25)
      t.write_capacity_units(25)
    end
    cfg.migrate!
  rescue Aws::DynamoDB::Errors::ResourceInUseException
    Rails.logger.error 'Failed to migrate table'
  end

  def seed_dynamodb(tenant_id)
    data = {
      komoju_secret_key: 'sk_test_komoju_',
      komoju_public_key: 'pk_test_komoju_',
      komoju_webhook_secret_token: 'komoju_webhook_secret_token',
    }

    data.each do |key, value|
      begin
        AppConstant.create(key:, value:, tenant_id: tenant_id.to_s)
      rescue Exceptions::AppConstant::KeyAlreadyExists
        next
      end
    end
  end

  def delete_dynamodb_table
    Aws::Record::TableMigration.new(AppConstant).delete! if AppConstant.table_exists?
  end

  def client
    Aws::DynamoDB::Client.new(options)
  end

  def options
    {
      region: 'ap-northeast-1',
      endpoint: 'http://dynamodb:8000',
      credentials: Aws::Credentials.new('access_key_id_test', 'secret_access_key_test'),
    }
  end
end
