# rtx3080-alert

💰 価格.com に RTX 3080 の価格情報が掲載されたら Discord Webhook に通知するツール

次のイベントを通知します。
- 新製品が登録されたとき
- 価格が変動したとき (値上がり / 値下がり)
- 在庫がなくなったとき, 復活したとき

[![Kotlin](https://img.shields.io/badge/Kotlin-1.4.30-blue)](https://kotlinlang.org)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/SlashNephy/rtx3080-alert)](https://github.com/SlashNephy/rtx3080-alert/releases)
[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/SlashNephy/rtx3080-alert/Docker)](https://hub.docker.com/r/slashnephy/rtxalert)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/slashnephy/rtxalert/latest)](https://hub.docker.com/r/slashnephy/rtxalert)
[![Docker Pulls](https://img.shields.io/docker/pulls/slashnephy/rtxalert)](https://hub.docker.com/r/slashnephy/rtxalert)
[![license](https://img.shields.io/github/license/SlashNephy/rtx3080-alert)](https://github.com/SlashNephy/rtx3080-alert/blob/master/LICENSE)
[![issues](https://img.shields.io/github/issues/SlashNephy/rtx3080-alert)](https://github.com/SlashNephy/rtx3080-alert/issues)
[![pull requests](https://img.shields.io/github/issues-pr/SlashNephy/rtx3080-alert)](https://github.com/SlashNephy/rtx3080-alert/pulls)

## Requirements

- Java 8 or later

## Get Started

### Docker

There are some image tags.

- `slashnephy/rtxalert:latest`  
  Automatically published every push to `master` branch.
- `slashnephy/rtxalert:dev`  
  Automatically published every push to `dev` branch.
- `slashnephy/rtxalert:<version>`  
  Coresponding to release tags on GitHub.

`docker-compose.yml`

```yaml
version: '3.8'

services:
  rtxalert:
    container_name: rtxalert
    image: slashnephy/rtxalert:latest
    restart: always
    environment:
      # Discord Webhook URL (必須)
      DISCORD_WEBHOOK_URL: https://xxx
      # 価格.com の「画像表示」のページの URL
      # パラメータを変えることで RTX 3080 以外の製品をウォッチすることもできます
      PRICE_LIST_URL: https://kakaku.com/pc/videocard/itemlist.aspx?pdf_Spec103=480&pdf_Spec104=12&pdf_ob=0&pdf_vi=c
      # チェック間隔 (秒)
      # 過剰なリクエストを送らないようにご注意ください
      INTERVAL_SECONDS: 180
```
