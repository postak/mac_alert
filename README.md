# mac_alert

This script starts a loop that continually checks if your Mac's charging cable get unplugged and/or the clamshell get closed. In case, it start to play continuously an alarm and send a Telegram notification

In order to send a Telegram notification you need to set set TOKEN_ID environment variable you get from Telegram when creating a bot

These are steps to create the Telegram bot

- open telegram and search for BotFather user
- Create a new bot by typing the command
`/newbot`
- Choose a name for your bot
es. mybot
- You will be asked to choose a username for your bot, which must end with "_bot" (maybe you find difficult to find a not used name, but could be a problem with Telegram API. In case, try later)
- Start the bot by typing the command
`/start`
- At this point you will be able to get the TOKEN_ID
- At any time you can get TOKEN_ID typing the command
`/mybots`
- clicking the bot and than clicking API Token, you get the TOKEN_ID




