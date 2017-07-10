require './bot_commands'
require './bot_replies'
require './reminder'

class ReminderHelper
  attr_reader :last_chat_commands

  def initialize
    @reminders = Hash.new([])
    @last_chat_commands = Hash.new(BotCommands::HELP)
  end

  def update_chat_reminders(message)
    @reminders[message.chat.id] << Reminder.new(message)
    BotReplies::REMINDER_SAVED
  end

  def update_last_chat_command(message)
    last_chat_commands[message.chat.id] = message.text
  end

  def reminders_list(message)
    @reminders[message.chat.id]
  end

  def first_reminder(message)
    @reminders[message.chat.id].first
  end

  def last_reminder(message)
    @reminders[message.chat.id].last
  end

  def remove_last_reminder(message)
    @reminders[message.chat.id].pop
    BotReplies::REMINDER_REMOVED
  end

  def remove_first_reminder(message)
    @reminders[message.chat.id].shift
    BotReplies::REMINDER_REMOVED
  end

  def remove_all_reminders(message)
    @reminders[message.chat.id] = []
    BotReplies::REMINDERS_CLEAR
  end
end
