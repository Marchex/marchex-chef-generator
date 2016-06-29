def launch_screen
  quotes =  [
    'The least likely can be the most dangerous',
    'To know others you must know yourself first',
    'Data is power',
    ]

  quote_block_length = 50
  quote_block = "/".ljust(quote_block_length-2, '─') << "\n" \
              <<  "/   #{quotes.sample}".ljust(quote_block_length, ' ') << " \\\n" \
              << "\\".ljust(quote_block_length, ' ') << " \/\n" \
              << " \\".ljust(quote_block_length, '─')

  launch_screen = <<-eos
  #{quote_block}
    \\
     \\
    _                              _
   / \\          ________          / \\
  |   \\       _/ /    \\ \\_       /   |
  |    \\_ ___/  /      \\  \\___ _/    |
  |      | \\ \\ /        \\ / / |      |
  |      | |  |          |  | |      |
   \\     | |  |__________|  | |     /
    \\    | |   \\________/   | |    /
     \\__/ /     \\______/     \\ \\__/
      \\__/   ____\\____/____   \\__/
       |    /\\___/\\__/\\___/\\    |
      /    / |    |  |    | \\    \\
     /    /  |    |__|    |  \\    \\
    |     |  |    |__|    |  |     |
    |     | _|   ______   |_ |     |
    |_____|/ |   \\____/   | \\|_____|
    |     |  |     __     |  |     |
     \\    |   \\          /   |    /
      \\_   \\   \\________/   /   _/
        \\_  \\   /      \\   /  _/
          \\_ \\_/________\\_/ _/
            \\_/__________\\_/
  eos

  puts launch_screen
end
