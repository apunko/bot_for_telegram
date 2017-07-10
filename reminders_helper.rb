require './bot_instructions'
require './reminder'

class ReminderHelper
  attr_reader :last_chat_commands

  def initialize
    @reminders = Hash.new([])
    @last_chat_commands = Hash.new(BotInstructions.commands['help'])
  end

  def update_chat_reminders(message)
    @reminders[message.chat.id] << Reminder.new(message)
    BotInstructions.replies['reminder_saved']
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
    BotInstructions.replies['reminder_removed']
  end

  def remove_first_reminder(message)
    @reminders[message.chat.id].shift
    BotInstructions.replies['reminder_removed']
  end

  def remove_all_reminders(message)
    @reminders[message.chat.id] = []
    BotInstructions.replies['reminders_clear']
  end
end
