class BotInstructions
  @@instructions = YAML.load_file('instructions.yml')

  def self.replies
    @@instructions['replies']
  end

  def self.commands
    @@instructions['commands']
  end
end
