Penulis: [0xraia](https://x.com/0xraia)

# Pengenalan
Bab ini berisi pengenalan mengenai Allora Network

## Allora Network
**Allora Network adalah L1 dimana semua orang bisa kontribusi resources untuk memecahkan masalah menggunakan model machine learning**

### Investor
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/46a1c968-3355-41d0-9013-e7ee93967a7b)


# Tutorial Allora Worker Node
Bab ini berisi tutorial cara menjalankan Allora Worker node

## Requirement
Syarat menjalankan Allora Worker Node:
- VPS ataupun Local dengan spesifikasi:
  
| ✅ Linux | ✅ macOS | ✅ Windows (Native / WSL) |
| ------------- | ------------- | ------------- |

| Part | Minimum | Recommended |
| ------------- | ------------- | ------------- |
| CPU | 1 Core | 2 Core |
| RAM | 2 GB | 4 GB |
| SSD | 50 GB | 100 GB |
  
> [!NOTE]
> Tutorial ini dibuat menggunakan sistem operasi Linux (Ubuntu), untuk sistem operasi lainnya mungkin akan sedikit berbeda
## Dependencies
Hal yang diperlukan sebelum menjalankan worker node:
### Docker
#### Update APT
```
# Masuk ke root
su root

# Update APT
sudo apt-get update && sudo apt-get install -y make gcc

# Install package yang diperlukan untuk instalasi docker
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y
```
#### Install Docker
```
# Download dan tambahkan GPG key Docker ke APT
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Tambah repository Docker ke APT
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Check versi yang tersedia pada Docker yang ingin di-install
apt-cache policy docker-ce

# Install Docker
sudo apt install docker-ce -y
```
### GoLang
#### Install GoLang
```
# Menghapus direktori /usr/local/go
sudo rm -rf /usr/local/go

# Download dan ekstraksi file tarball Go 
curl -L https://go.dev/dl/go1.22.4.linux-amd64.tar.gz | sudo tar -xzf - -C /usr/local

# Tambah perintah export ke dalam file .bash_profile
echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> $HOME/.bash_profile && echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> $HOME/.bash_profile

# Memuat ulang file .bash_profile ke dalam sesi shell saat ini
source .bash_profile
```
### Python
> [!NOTE]
> Beberapa sistem operasi sudah terinstall Python secara default, check terlebih dahulu menggunakan `python3 --version` atau `python --version`, jika terdapat output versi dari Python maka Python sudah terinstall di sistem operasi anda dan dapat skip tahap ini
#### Install Python
```
# Install Python3
sudo apt install python3

# Check versi Python untuk memastikan kalau sudah terinstall
python3 --version
```
### PIP
#### Install PIP
```
# Install PIP
sudo apt install python3-pip

# Check versi PIP untuk memastikan kalau sudah terinstall
pip3 --version
```
### Allora Appchain CLI
#### Install Allora Appchain CLI
```
# Clone repository Allora Appchain CLI
git clone -b v0.2.7 https://github.com/allora-network/allora-chain.git

# Install Allora Appchain CLI
cd allora-chain && make all

# Keluar dari folder repository Allora Appchain CLI
cd

# Check versi dari Allora Appchain CLI
allorad version
```
## Menjalankan Allora Worker Node
Ada dua campaign worker node yang dapat dikerjakan sekarang
- [Run A Model Predicting Prices In The Next 24 Hours](https://github.com/ZuperHunt/Allora-Worker-Node#allora-worker-node-for-run-a-model-predicting-prices-in-the-next-10-minutes-campaign)
- [Run A Model Predicting Prices In The Next 10 minutes](https://github.com/ZuperHunt/Allora-Worker-Node#allora-worker-node-for-run-a-model-predicting-prices-in-the-next-24-hours-campaign)

> [!NOTE]
> Tutorial ini akan melingkupi cara mengerjakan dua campaign tersebut, tetapi tidak disarankan untuk dijalankan pada VPS/Local yang sama sekaligus, gunakan 1 VPS untuk 1 campaign

### Allora Worker Node for Run A Model Predicting Prices In The Next 24 Hours Campaign
#### Tambah Wallet ke Allora Appchain CLI
- Recover wallet kalau kalian punya phrasenya
```
allorad keys add --recover IsiPakeNamaWalletElo
```
- Buat baru kalau tidak punya phrasenya
```
allorad keys add IsiPakeNamaWalletElo
```
#### Ambil Faucet
- Check address kamu dengan menjalankan command ini
```
allorad keys list
```
- Pergi ke [sini](https://faucet.edgenet.allora.network/) untuk faucet token
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/f71f5c54-3556-4ca8-91e8-1f4fa5546bad)

#### Install Worker Node
- Clone repository yang akan menjadi basis node kita
```
cd $HOME && git clone https://github.com/allora-network/basic-coin-prediction-node
```
- Buat direktori untuk node worker
```
cd basic-coin-prediction-node && mkdir worker-data && mkdir head-data
```
- Buat head dan worker keys
```
# Membuat Head Keys
sudo docker run -it --entrypoint=bash -v ./head-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

# Membuat Worker Keys
sudo docker run -it --entrypoint=bash -v ./worker-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"
```
- Lihat Head Keys ID
```
cat head-data/keys/identity
```
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/3e6be37f-21d9-4c62-8c83-22fd79483b8a)

Simpan keys ID tersebut, karena akan digunakan untuk tahap selanjutnya

#### Deploy Worker Node
- Hapus existing docker compose lalu buat kembali
```
rm -rf docker-compose.yml && nano docker-compose.yml
```
- Setup Docker Compose

Isi docker compose dengan kode di bawah. Perhatikan pada section worker ganti `head-id` dengan ID yang disimpan tadi dan `WALLET_SEED_PHRASE` dengan phrase wallet kalian

![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/3b64f691-3695-409d-9823-8906403b0440)

```
version: '3'

services:
  inference:
    container_name: inference-basic-eth-pred
    build:
      context: .
    command: python -u /app/app.py
    ports:
      - "8000:8000"
    networks:
      eth-model-local:
        aliases:
          - inference
        ipv4_address: 172.22.0.4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/inference/ETH"]
      interval: 10s
      timeout: 5s
      retries: 12
    volumes:
      - ./inference-data:/app/data

  updater:
    container_name: updater-basic-eth-pred
    build: .
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
    command: >
      sh -c "
      while true; do
        python -u /app/update_app.py;
        sleep 24h;
      done
      "
    depends_on:
      inference:
        condition: service_healthy
    networks:
      eth-model-local:
        aliases:
          - updater
        ipv4_address: 172.22.0.5

  worker:
    container_name: worker-basic-eth-pred
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9011 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/head-id \
          --topic=1 \
          --allora-chain-key-name=testkey \
          --allora-chain-restore-mnemonic='WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=https://allora-rpc.edgenet.allora.network/ --allora-chain-topic-id=1
    volumes:
      - ./worker-data:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      eth-model-local:
        aliases:
          - worker
        ipv4_address: 172.22.0.10

  head:
    container_name: head-basic-eth-pred
    image: alloranetwork/allora-inference-base-head:latest
    environment:
      - HOME=/data
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=head --peer-db=/data/peerdb --function-db=/data/function-db  \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9010 --rest-api=:6000
    ports:
      - "6000:6000"
    volumes:
      - ./head-data:/data
    working_dir: /data
    networks:
      eth-model-local:
        aliases:
          - head
        ipv4_address: 172.22.0.100


networks:
  eth-model-local:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/24

volumes:
  inference-data:
  worker-data:
  head-data:
```
Simpan dengan memencet CTRL + X lalu pencet Y dan kemudian ENTER 
- Run Worker node

Build worker node
```
docker compose build
```
Jalankan worker node
```
docker compose up -d
```

#### Monitoring Worker Node
- Check docker container yang berjalan
```
docker ps
```
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/0ef3fde5-c5cf-4af1-983e-18af2fb8fbba)
Ambil Container ID yang worker node
- Check logs worker node

Ganti `CONTAINER_ID` menjadi Container ID dari worker node
```
docker logs -f CONTAINER_ID
```
Akan muncul tampilan seperti berikut, kalian bisa monitoring worker node seperti ada yang error pada node ataupun hanya sekedar mengecek kalau node masih berjalan
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/8b17609d-7958-425e-8171-d272ddfbf9c7)

#### Testing Request Worker Node
- Jalankan request messages dibawah ini
```
curl --location 'http://localhost:6000/api/v1/functions/execute' \
--header 'Content-Type: application/json' \
--data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "1",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "ETH"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```
Jika mendapat output seperti gambar di bawah ini, selamat, node sudah berjalan dan terhubung ke Allora Network Chain
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/066bc481-e939-4261-8d73-343707976d27)


### Allora Worker Node for Run A Model Predicting Prices In The Next 10 minutes Campaign
#### Tambah Wallet ke Allora Appchain CLI
- Recover wallet kalau kalian punya phrasenya
```
allorad keys add --recover IsiPakeNamaWalletElo
```
- Buat baru kalau tidak punya phrasenya
```
allorad keys add IsiPakeNamaWalletElo
```
#### Ambil Faucet
- Check address kamu dengan menjalankan command ini
```
allorad keys list
```
- Pergi ke [sini](https://faucet.edgenet.allora.network/) untuk faucet token
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/f71f5c54-3556-4ca8-91e8-1f4fa5546bad)

#### Install Worker Node
- Clone repository yang akan menjadi basis node kita
```
cd $HOME && git clone https://github.com/allora-network/basic-coin-prediction-node
```
- Buat direktori untuk node worker
```
cd basic-coin-prediction-node && mkdir worker-data && mkdir head-data
```
- Buat head dan worker keys
```
# Membuat Head Keys
sudo docker run -it --entrypoint=bash -v ./head-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"

# Membuat Worker Keys
sudo docker run -it --entrypoint=bash -v ./worker-data:/data alloranetwork/allora-inference-base:latest -c "mkdir -p /data/keys && (cd /data/keys && allora-keys)"
```
- Hapus existing app.py lalu buat kembali
```
sudo rm -rf app.py && sudo nano app.py
```
- Isi app.py dengan kode berikut
```
from flask import Flask, Response
import requests
import json
import pandas as pd
import torch
from chronos import ChronosPipeline
 
# create our Flask app
app = Flask(__name__)
 
# define the Hugging Face model we will use
model_name = "amazon/chronos-t5-tiny"
 
# define our endpoint
@app.route("/inference/<string:token>")
def get_inference(token):
    """Generate inference for given token."""
    if not token or token != "BTC":
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
 
    # get the data from Coingecko
    # here we'll use last 30 days of BTC/USD
    url = "https://api.coingecko.com/api/v3/coins/bitcoin/market_chart?vs_currency=usd&days=30&interval=daily"
 
    headers = {
        "accept": "application/json",
    }
 
    response = requests.get(url, headers=headers)
    if response.status_code == 200:
        data = response.json()
        df = pd.DataFrame(data["prices"])
        df.columns = ["date", "price"]
        df["date"] = pd.to_datetime(df["date"], unit = "ms")
        df = df[:-1] # removing today's price
        print(df.tail(5))
    else:
        return Response(json.dumps({"Failed to retrieve data from the API": str(response.text)}), 
                        status=response.status_code, 
                        mimetype='application/json')
 
    # define the context and the prediction length
    context = torch.tensor(df["price"])
    prediction_length = 1
 
    try:
        forecast = pipeline.predict(context, prediction_length)  # shape [num_series, num_samples, prediction_length]
        print(forecast[0].mean().item()) # taking the mean of the forecasted prediction
        return Response(str(forecast[0].mean().item()), status=200)
    except Exception as e:
        return Response(json.dumps({"error": str(e)}), status=500, mimetype='application/json')

# run our Flask app
if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8000, debug=True)
```
- Hapus existing main.py lalu buat kembali
```
sudo rm -rf main.py && sudo nano main.py
```
- Isi main.py dengan kode berikut
```
import requests
import sys
import json
 
def process(argument):
    headers = {'Content-Type': 'application/json'}
    url = f"http://inference:8000/inference/{argument}"
    response = requests.get(url, headers=headers)
    return response.text
 
if __name__ == "__main__":
    # Your code logic with the parsed argument goes here
    try:
        if len(sys.argv) < 5:
            value = json.dumps({"error": f"Not enough arguments provided: {len(sys.argv)}, expected 4 arguments: topic_id, blockHeight, blockHeightEval, default_arg"})
        else:
            topic_id = sys.argv[1]
            blockHeight = sys.argv[2]
            blockHeightEval = sys.argv[3]
            default_arg = sys.argv[4]

            response_inference = process(argument=default_arg)
            response_dict = {"infererValue": response_inference}
            value = json.dumps(response_dict)
    except Exception as e:
        value = json.dumps({"error": {str(e)}})
    print(value)
```
- Hapus existing requirements.txt lalu buat kembali
```
sudo rm -rf requirements.txt && sudo nano requirements.txt
```
- Isi requirements.txt dengan kode berikut
```
flask[async]
gunicorn[gthread]
numpy==1.26.2
pandas
Requests==2.32.0
transformers[torch]
werkzeug>=3.0.3 # not directly required, pinned by Snyk to avoid a vulnerability
git+https://github.com/amazon-science/chronos-forecasting.git
python-dotenv
```
- Lihat Head Keys ID
```
cat head-data/keys/identity
```
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/3e6be37f-21d9-4c62-8c83-22fd79483b8a)

Simpan keys ID tersebut, karena akan digunakan untuk tahap selanjutnya

#### Deploy Worker Node
- Hapus existing docker compose lalu buat kembali
```
rm -rf docker-compose.yml && nano docker-compose.yml
```
- Setup Docker Compose

Isi docker compose dengan kode di bawah. Perhatikan pada section worker ganti `head-id` dengan ID yang disimpan tadi dan `WALLET_SEED_PHRASE` dengan phrase wallet kalian

![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/3b64f691-3695-409d-9823-8906403b0440)

```
version: '3'

services:
  inference:
    container_name: inference-basic-btc-pred
    build:
      context: .
    command: python -u /app/app.py
    ports:
      - "8000:8000"
    networks:
      btc-model-local:
        aliases:
          - inference
        ipv4_address: 172.22.0.4
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/inference/btc"]
      interval: 10s
      timeout: 5s
      retries: 12
    volumes:
      - ./inference-data:/app/data

  worker:
    container_name: worker-basic-btc-pred
    environment:
      - INFERENCE_API_ADDRESS=http://inference:8000
      - HOME=/data
    build:
      context: .
      dockerfile: Dockerfile_b7s
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        # Change boot-nodes below to the key advertised by your head
        allora-node --role=worker --peer-db=/data/peerdb --function-db=/data/function-db \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9011 \
          --boot-nodes=/ip4/172.22.0.100/tcp/9010/p2p/head-id \
          --topic=4 \
          --allora-chain-key-name=testkey \
          --allora-chain-restore-mnemonic='WALLET_SEED_PHRASE' \
          --allora-node-rpc-address=https://allora-rpc.edgenet.allora.network/ --allora-chain-topic-id=4
    volumes:
      - ./worker-data:/data
    working_dir: /data
    depends_on:
      - inference
      - head
    networks:
      btc-model-local:
        aliases:
          - worker
        ipv4_address: 172.22.0.10

  head:
    container_name: head-basic-btc-pred
    image: alloranetwork/allora-inference-base-head:latest
    environment:
      - HOME=/data
    entrypoint:
      - "/bin/bash"
      - "-c"
      - |
        if [ ! -f /data/keys/priv.bin ]; then
          echo "Generating new private keys..."
          mkdir -p /data/keys
          cd /data/keys
          allora-keys
        fi
        allora-node --role=head --peer-db=/data/peerdb --function-db=/data/function-db  \
          --runtime-path=/app/runtime --runtime-cli=bls-runtime --workspace=/data/workspace \
          --private-key=/data/keys/priv.bin --log-level=debug --port=9010 --rest-api=:6000
    ports:
      - "6000:6000"
    volumes:
      - ./head-data:/data
    working_dir: /data
    networks:
      btc-model-local:
        aliases:
          - head
        ipv4_address: 172.22.0.100

networks:
  btc-model-local:
    driver: bridge
    ipam:
      config:
        - subnet: 172.22.0.0/24

volumes:
  inference-data:
  worker-data:
  head-data:
```
Simpan dengan memencet CTRL + X lalu pencet Y dan kemudian ENTER 
- Run Worker node

Build worker node
```
docker compose build
```
Jalankan worker node
```
docker compose up -d
```

#### Monitoring Worker Node
- Check docker container yang berjalan
```
docker ps
```
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/0ef3fde5-c5cf-4af1-983e-18af2fb8fbba)
Ambil Container ID yang worker node
- Check logs worker node

Ganti `CONTAINER_ID` menjadi Container ID dari worker node
```
docker logs -f CONTAINER_ID
```
Akan muncul tampilan seperti berikut, kalian bisa monitoring worker node seperti ada yang error pada node ataupun hanya sekedar mengecek kalau node masih berjalan
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/8b17609d-7958-425e-8171-d272ddfbf9c7)

#### Testing Request Worker Node
- Jalankan request messages dibawah ini
```
curl --location 'http://localhost:6000/api/v1/functions/execute' --header 'Content-Type: application/json' --data '{
    "function_id": "bafybeigpiwl3o73zvvl6dxdqu7zqcub5mhg65jiky2xqb4rdhfmikswzqm",
    "method": "allora-inference-function.wasm",
    "parameters": null,
    "topic": "4",
    "config": {
        "env_vars": [
            {
                "name": "BLS_REQUEST_PATH",
                "value": "/api"
            },
            {
                "name": "ALLORA_ARG_PARAMS",
                "value": "BTC"
            }
        ],
        "number_of_nodes": -1,
        "timeout": 2
    }
}'
```
Jika mendapat output seperti gambar di bawah ini, selamat, node sudah berjalan dan terhubung ke Allora Network Chain
![image](https://github.com/ZuperHunt/Allora-Worker-Node/assets/92942194/387a2881-3314-41cb-855d-fbb2f6c2d922)



## Help

Join komunitas [Discord ZuperHunt](https://t.co/n7TeWVlA48) jika kamu ada pertanyaan.

## Change Logs

* 0.0.1
    * Initial Release
* 0.0.2
    * Fix wrong embedded link
* 0.0.3
    * Fix switched heading title

## Acknowledgments

Referensi
* [allora-testnet by 0xmoei](https://github.com/0xmoei/allora-testnet?tab=readme-ov-file)
* [Official Allora Documentation](https://docs.allora.network/learn/cli)
* [Official Allora Web Campaign](https://app.allora.network/points/campaigns)
* [How To Worker Node on Allora Network By Allocmd by ReJump](https://rejump.dev/how-to-worker-node-on-allora-network/)
