Found
=====

Found is the app for founders to help each other.

To get started with development locally,

1. Install Postgres
2. [Get an AngelList API Key](https://angel.co/api/oauth/clients)
  * Redirect URL: http://localhost:3000/auth/angellist/callback
  * Main URL: http://localhost:3000/
3. Duplicate `env.sample` and rename it `.env`. Set the required environment variables.
4. Duplicate `database.yml.sample` in `config` and rename it `database.yml`. Set your database username and password.
5. Run `rake db:create db:migrate`
6. Make sure you have Java 7+ JDK installed (Check version with `java -version`)
6. Run `bundle exec rake sunspot:solr:start` to start Solr ([see more details](https://github.com/sunspot/sunspot))
7. Run `foreman start -p 3000`
8. Visit [http://localhost:3000/](http://localhost:3000/) to see site
