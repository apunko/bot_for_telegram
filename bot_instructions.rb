module BotInstructions
  extend self

  def instructions
    @instructions ||= YAML.load_file('instructions.yml')
  end

  def replies
    instructions['replies']
  end

  def commands
    instructions['commands']
  end
end

