# Add following to your ActionMailer configuration
# (in Rails projects located in `config/environments/$ENVIRONMENT.rb`)
config.action_mailer.delivery_method = :mailtrap
config.action_mailer.mailtrap_settings = {
  api_key: '<YOUR_API_TOKEN>',
}

# Then send your email from a mailer action
mail(
  to: 'webapp4@outlook.com',
  reply_to: 'Mailtrap Reply-To <support@example.com>',
  subject: 'You are awesome!',
  category: 'Integration Test',
  custom_variables: { test_variable: 'abc' }
)
