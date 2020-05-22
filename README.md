# Hubtrics

Metrics and reporting using GitHub

[![Maintainability](https://api.codeclimate.com/v1/badges/c4a8fc97828bbe6b3f5e/maintainability)](https://codeclimate.com/github/joshminnie/hubtrics/maintainability)

# Setup

Run `bin/setup`.

After you have run `bin/setup`, you will need to fill out the `.hubtrics.yml` configuration file that was created for you in the project root. Specifically, you will want to populate the client configuration.

If you decide to use the [.netrc implementation](https://ec.haxx.se/usingcurl/usingcurl-netrc), follow the steps GitHub provides for ["Creating a personal access token for the command line"](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) and use the token created as your password in the `.netrc` file.
