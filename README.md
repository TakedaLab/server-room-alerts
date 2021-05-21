# サーバ室の監視警察

## ondotori.sh
サーバ室内の温度計の情報を監視してしきい値を超えるとSLACKに通知するスクリプト  
以下の環境変数を設定して使用する  
- `ONDOTORI_API_KEY`: おんどとりのAPIキー
- `ONDOTORI_LOGIN_ID`: おんどとりのログインID
- `ONDOTORI_LOGIN_PASS`: おんどとりのログインパスワード
- `ONDOTORI_ALERT_THRESHOLD_TEMPERATURE`: 温度のしきい値
- `ONDOTORI_ALERT_THRESHOLD_HUMIDITY`: 湿度のしきい値
- `SLACK_WEBHOOK_URL`: Slack の webhook URL

