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
    fastlane_session = Spaceship::SpaceauthRunner.new(username: ).run.session_string

    app = Spaceship::Tunes::login(config.iOS['appleID'], config.iOS['password'])
    itc_cookie_content = Spaceship::Tunes.client.store_cookie

    cookies = YAML.safe_load(
      itc_cookie_content,
      [HTTP::Cookie, Time], # classes allowlist
      [],                   # symbols allowlist
      true                  # allow YAML aliases
    )

    cookies.select! do |cookie|
      cookie.name.start_with?("myacinfo") || cookie.name == "dqsid" || cookie.name.start_with?("DES")
    end

    fastlane_session = cookies.to_yaml.gsub("\n", "\\n")
    File.write("#{Pathname.new(configPath).dirname}/FASTLANE_SESSION", fastlane_session, mode: "w+")
rescue => error
    puts error
end

