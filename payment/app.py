from flask import Flask, make_response, jsonify
from werkzeug.exceptions import NotFound, ServiceUnavailable
import requests
import json

app = Flask(__name__)

URL_NATV_USER = "http://127.0.0.1:5001/user" # Change to this when running as native app
URL_DOKR_USER = "http://user-service:5001/user" # Change to this when running as Docker app

@app.route("/payment")
def payment_service_hello():

    try:
        users_service = requests.get(URL_DOKR_USER)
    except requests.exceptions.ConnectionError:
        raise ServiceUnavailable("The User service is unavailable.")

    if users_service.status_code == 404:
        raise NotFound("No User were found for {}")

    data =  users_service.text + "<br> Hello from Payment Service!"
    return data

#    return make_response(jsonify(
#        {
#            "msg": "Hello from Payment Service!"
#        }
#    ) , "\n<br>" , users_service.json(), 200)

#     data = "<br>\n" + str(users_service.json()) + "<br>\n" + str({"msg": "Hello from Payment Service!"})
#     data = jsonify(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002, debug=True)
