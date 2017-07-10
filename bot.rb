require 'telegram/bot'
require 'yaml'
require './bot_commands'
require './bot_replies'
require './reminders_helper'
require './reminder'

def send_reminder(bot, reminder, chat_id)
  if !reminder.nil?
    if reminder.text_reminder?
      send_text_message(bot, reminder.text, chat_id)
    else
      send_photo_message(bot, reminder.file_id, reminder.caption, chat_id)
    end
  else
    send_text_message(bot, BotReplies::NO_REMINDERS, chat_id)
  end
end

def send_text_message(bot, text, chat_id)
  bot.api.send_message(
    chat_id: chat_id,
    text: text
  )
end

def send_photo_message(bot, file_id, caption, chat_id)
  bot.api.send_photo(
    chat_id: chat_id,
    photo: file_id,
    caption: caption
  )
end

secrets = YAML.load_file('secrets.yml')
token = secrets['token']

reminders_helper = ReminderHelper.new

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case reminders_helper.last_chat_commands[message.chat.id]
    when BotCommands::SAVE
      message_text = reminders_helper.update_chat_reminders(message)
      send_text_message(bot, message_text, message.chat.id)
    else
      case message.text
      when BotCommands::LIST
        reminders_list = reminders_helper.reminders_list(message)
        if reminders_list.count > 0
          reminders_list.each do |reminder|
            send_reminder(bot, reminder, message.chat.id)
          end
        else
          send_text_message(bot, BotReplies::NO_REMINDERS, chat_id)
        end
      when BotCommands::SHOW_FIRST
        reminder = reminders_helper.first_reminder(message)
        send_reminder(bot, reminder, message.chat.id)
      when BotCommands::SHOW_LAST
        reminder = reminders_helper.last_reminder(message)
        send_reminder(bot, reminder, message.chat.id)
      when BotCommands::FIRST_DONE
        message_text = reminders_helper.remove_first_reminder(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotCommands::LAST_DONE
        message_text = reminders_helper.remove_last_reminder(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotCommands::CLEAR
        message_text = reminders_helper.remove_all_reminders(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotCommands::SAVE
        send_text_message(bot, BotReplies::REMINDER_ASK, message.chat.id)
      when BotCommands::HELP
        send_text_message(bot, BotReplies::HELP, message.chat.id)
      end
    end

    reminders_helper.update_last_chat_command(message)
  end
end
