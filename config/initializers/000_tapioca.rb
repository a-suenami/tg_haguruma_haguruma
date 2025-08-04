# ==============================================================================
# config - initializers - 000 tapioca
# ==============================================================================
if ENV['FORCE_TEST_DATABASE'] == 'true'
  # DB の接続先を test にする
  ActiveRecord::Base.establish_connection(:test)
end
