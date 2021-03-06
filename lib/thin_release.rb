require 'rest-client'
require 'trello_configs/base'
require 'trello_configs/config'
require 'trello_configs/git_logger'
require 'trello_configs/trello_bot'

module ThinRelease
  CARD_URL_REG = /cid#[^\s]*/
  USER_NAME_REG = /un#[^\s]*/
  MENTION_BOARD_MEMBERS_TEXT = '@board'.freeze
  TEXT_DIVIDER = "\n____________\n".freeze

  def self.configure
    yield Base.config
  end

  # @param [Hash] options
  # @option opts [String] :repo_revision, path to git repo
  # @option opts [String] :revision, for git logs
  # @option opts [String] :application, name of application
  # @option opts [Array] :servers, servers to which release is deployed to
  def self.generate_release(options)
    target_list_name = "Releases - #{options[:application].capitalize}"
    trello_bot = TrelloBot.new
    list = trello_bot.find_list(target_list_name) || trello_bot.create_list(target_list_name)
    servers_text = "**Servers:**\n\n"
    revission_text = "**Revision:**\n\n #{options[:repo_revision]}/commit/#{options[:revission]}"

    options[:servers].each do |server_link|
      servers_text += server_line(server_link)
    end

    texts = []
    texts.push(servers_text) if options[:servers].any?
    texts.push(revission_text)

    card_name = Time.now.strftime('%Y-%m-%d %T%:z')
    release_card = trello_bot.create_card(list['id'], card_name, texts.join(TEXT_DIVIDER))

    release_card
  end

  def self.server_line(server_link)
    "- [#{server_link}](#{server_link})\n"
  end
end
