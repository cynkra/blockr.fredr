#!/usr/bin/env Rscript
# Interactive setup for shinyapps.io deployment

cat("\n=== shinyapps.io Setup ===\n\n")

cat("Please follow these steps:\n\n")
cat("1. Open https://www.shinyapps.io/ in your browser\n")
cat("2. Log in (or create a free account if you don't have one)\n")
cat("3. Click on your name in the top right corner\n")
cat("4. Select 'Tokens' from the dropdown menu\n")
cat("5. Click 'Show' next to your token (or 'Add Token' if you don't have one)\n")
cat("6. You'll see a command like:\n")
cat("   rsconnect::setAccountInfo(name='yourname', token='ABC123', secret='xyz789')\n\n")

cat("Press Enter when you're ready to continue...\n")
readline()

cat("\nNow please enter your credentials:\n\n")

account_name <- readline("Account name: ")
token <- readline("Token: ")
secret <- readline("Secret: ")

if (nchar(account_name) == 0 || nchar(token) == 0 || nchar(secret) == 0) {
  stop("All fields are required!")
}

cat("\nSetting up account...\n")
rsconnect::setAccountInfo(
  name = account_name,
  token = token,
  secret = secret
)

cat("\n✓ Success! Your shinyapps.io account is configured.\n")
cat("\nConfigured accounts:\n")
print(rsconnect::accounts())

cat("\nYou're ready to deploy! Run: source('deploy.R')\n")
