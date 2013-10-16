Rails.configuration.stripe = {
  :publishable_key => ENV['PUBLISHABLE_KEY'] || "pk_test_hnVIdVRGRqFRKl5VvCO8VbAW",
  :secret_key      => ENV['SECRET_KEY'] || "sk_test_NS9J8JySIXG3XPk2ZQeX74ei"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]