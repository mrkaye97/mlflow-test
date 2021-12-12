heroku login
heroku container:login

heroku config:set $(confcrypt aws read env.econf --format="%n=%v" | tr '\n' ' ') --app mk-mlflow-test >> /dev/null

heroku container:push web --app mk-mlflow-test
heroku container:release web --app mk-mlflow-test
