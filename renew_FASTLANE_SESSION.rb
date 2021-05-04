require "spaceship"

begin
    configPath = ARGV[0]
    if configPath == nil
        configPath = "./config/config.yaml"
    end
    if !File.exists?(configPath)
        raise "Config file not found in #{configPath}"
    end
    config = OpenStruct.new(YAML.load_file(configPath))

    if config.iOS == nil || config.iOS['appleID'] == nil
        raise "config.iOS['appleID'] parameter not found in #{configPath}"
    end
    fastlane_session = Spaceship::SpaceauthRunner.new(username: config.iOS['appleID']).run.session_string
    File.write("#{Pathname.new(configPath).dirname}/FASTLANE_SESSION", fastlane_session, mode: "w+")
rescue => error
    puts error
end

