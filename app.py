from flask import Flask, Response
import requests
import json
import pandas as pd
from datetime import datetime
import torch
from chronos import ChronosPipeline

# create our Flask app
app = Flask(__name__)

# define the Hugging Face model we will use
model_name = 'amazon/chronos-t5-tiny'


# define our endpoint
@app.route("/inference/<string:token>")
def get_inference(token):
    """Generate inference for given token."""
    if not token or token != 'BTC':
        error_msg = "Token is required" if not token else "Token not supported"
        return Response(json.dumps({"error": error_msg}), status=400, mimetype='application/json')
    try:
        # use a pipeline as a high-level helper
        pipeline = ChronosPipeline.from_pretrained(
            model_name,
            device_map="auto",
            torch_dtype=torch.bfloat16,
        )
    except Exception as e:
        return Response(json.dumps({"pipeline error": str(e)}), status=500, mimetype='application/json')

    current_date = datetime.now().date()

    try:
        df = pd.read_csv('bitcoin_prices.csv')
        last_date = pd.to_datetime(df['date'].iloc[-1]).date()
        if last_date == current_date:
            print("Data for today already exists. Skipping API call.")
            print(df.head(5))
        else:
            raise FileNotFoundError

    except FileNotFoundError:
        url = 'https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30&interval=daily'

        headers = {
            "accept": "application/json",
        }

        response = requests.get(url, headers=headers)
        if response.status_code == 200:
            data = response.json()
            df = pd.DataFrame(data["prices"])
            df.columns = ["date", "price"]
            df["date"] = pd.to_datetime(df["date"], unit="ms")
            df.to_csv('prices.csv', index=False)
            print(df.tail(5))
        else:
            return Response(json.dumps({"Failed to retrieve data from the API": str(response.text)}),
                            status=response.status_code,
                            mimetype='application/json')

    df = df[:-1]  # removing today's price
    
    # define the context and the prediction length
    context = torch.tensor(df["price"])
    prediction_length = 1

    try:
        forecast = pipeline.predict(context, prediction_length)  # shape [num_series, num_samples, prediction_length]
        print(forecast[0].mean().item())  # taking the mean of the forecasted prediction
        return Response(str(forecast[0].mean().item()), status=200)
    except Exception as e:
        return Response(json.dumps({"error": str(e)}), status=500, mimetype='application/json')


# run our Flask app
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)