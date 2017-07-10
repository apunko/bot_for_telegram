require 'telegram/bot'
require 'yaml'
require './bot_instructions'
require './reminders_helper'
require './reminder'

def send_reminder(bot, reminder, chat_id)
  return send_text_message(bot, BotInstructions.replies['no_reminders'], chat_id) if reminder.nil?

  if reminder.text_reminder?
    send_text_message(bot, reminder.text, chat_id)
  else
    send_photo_message(bot, reminder.file_id, reminder.caption, chat_id)
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
    when BotInstructions.commands['save']
      message_text = reminders_helper.update_chat_reminders(message)
      send_text_message(bot, message_text, message.chat.id)
    else
      case message.text
      when BotInstructions.commands['list']
        reminders_list = reminders_helper.reminders_list(message)
        if reminders_list.count > 0
          reminders_list.each do |reminder|
            send_reminder(bot, reminder, message.chat.id)
          end
        else
          send_text_message(bot, BotInstructions.replies['no_reminders'], message.chat.id)
        end
      when BotInstructions.commands['show_first']
        reminder = reminders_helper.first_reminder(message)
        send_reminder(bot, reminder, message.chat.id)
      when BotInstructions.commands['show_last']
        reminder = reminders_helper.last_reminder(message)
        send_reminder(bot, reminder, message.chat.id)
      when BotInstructions.commands['first_done']
        message_text = reminders_helper.remove_first_reminder(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotInstructions.commands['last_done']
        message_text = reminders_helper.remove_last_reminder(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotInstructions.commands['clear']
        message_text = reminders_helper.remove_all_reminders(message)
        send_text_message(bot, message_text, message.chat.id)
      when BotInstructions.commands['save']
        send_text_message(bot, BotInstructions.replies['reminder_ask'], message.chat.id)
      when BotInstructions.commands['help']
        send_text_message(bot, BotInstructions.replies['help'], message.chat.id)
      end
    end

    reminders_helper.update_last_chat_command(message)
  end
end
