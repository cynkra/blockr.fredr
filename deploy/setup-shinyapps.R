# Setup script for shinyapps.io deployment
#
# Follow these steps:
#
# 1. Log in to https://www.shinyapps.io/
# 2. Click on your name (top right) -> Tokens
# 3. Click "Show" next to your token, or create a new token
# 4. Copy the token and secret
# 5. Run the command below with your credentials:

# Replace these values with your actual credentials:
# rsconnect::setAccountInfo(
#   name = "YOUR_ACCOUNT_NAME",
#   token = "YOUR_TOKEN",
#   secret = "YOUR_SECRET"
# )

# After running the above command, verify it worked:
rsconnect::accounts()

# If you see your account listed, you're ready to deploy!
