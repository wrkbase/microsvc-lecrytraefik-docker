from flask import Flask, make_response, jsonify

app = Flask(__name__)


@app.route("/user")
def payment_service_hello():
    data = "<br> Hello from User Service!"
    return data

#    return make_response(jsonify(
#        {
#            "msg": "Hello from User Service!<br>"
#        }
#    ), 200)

#    data = jsonify({"user_msg": "Hello from User Service!"})
#    data = {"user_msg": "Hello from User Service!"}



if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)
