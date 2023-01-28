# 作品名 <space><tab> 開始日 ~ 終了日
# /^.*[\s\S]*\d{2}\/\d{1,2}\/\d{1,2}\s?~\s?\d{2}\/\d{1,2}\/\d{1,2}$/

# とりあえずいくつか正規表現パターンを作って、拾いきれてないパターンはそう多くなさそうなので
# 手動でなおせるものは手動で

# normal_pattern = %r|^.*?[\s\S]*\d{2}/\d{1,2}/\d{1,2}\s?~\s?\d{2}/\d{1,2}/\d{1,2}$|

date_pattern = %r|\d{2}/\d{1,2}/\d{1,2}|
basic_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern})/

# タイトル 20/9/12 ~ 20/10/1
# normal_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern})\s?~\s?(?<end_date>#{date_pattern})$/
normal_pattern = /#{basic_pattern}\s?~\s?(?<end_date>#{date_pattern})$/

# タイトル 20/9/12;
oneday_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern});$/

# タイトル 20/9/12 ~
ongoing_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern})\s?~\s?$/

# タイトル 20/9/12 ~ dropped on epi 10 10/3
drop_pattern =
  /^(?<title>.*?)\s*(?<start_date>#{date_pattern})\s?~\s?(?<status>drop|suspend|stop).*epi\s?(?<dropped_episode>\d{1,2})?.*?(?<dropped_date>#{date_pattern})?$/

filename = './anime_list/current.txt'

File.open(filename, 'r') do |f|
  count = 0
  f.each_with_index do |line, _i|
    matched = (
      normal_pattern.match(line) ||
      oneday_pattern.match(line) ||
      ongoing_pattern.match(line)
      # /(?:drop|suspend|stop)/.match(line)
    )
    if matched.nil?
      # drop, suspend, stop のstatusを取得する
      # どのepisodeまで見たかを取得する
      matched = drop_pattern.match(line)
      # if !matched.nil?
      #   p matched
      # end
      # count += 1
    end
    p matched
  end
  # p('', "### count = #{count}")
end
