from flask import Flask, make_response, jsonify
from werkzeug.exceptions import NotFound, ServiceUnavailable
import requests
import json

app = Flask(__name__)

URL_NATV_PAYMENT = "http://127.0.0.1:5002/payment" # Change to this when running as native app
URL_DOKR_PAYMENT = "http://payment-service:5002/payment" # Change to this when running as Docker app

@app.route("/report")
def report_service_hello():

    try:
        payment_service = requests.get(URL_DOKR_PAYMENT)
    except requests.exceptions.ConnectionError:
        raise ServiceUnavailable("The Report service is unavailable.")

    if payment_service.status_code == 404:
        raise NotFound("No Payments were found for {}")

    data = payment_service.text + "<br> Hello from Report Service!"
    return data

#    return make_response(jsonify(
#        {
#            "msg": "Hello from Report Service!"
#        }
#    ) , "\n<br>" , payment_servcie.json(), 200)

#    data = str(payment_service.json()) + "<br>\n" + str({"msg": "Hello from Report Service!"}) + "<br>\n"
#    data = jsonify(data)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003, debug=True)
