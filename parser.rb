require 'pry-byebug'
require 'csv'

# 作品名 <space><tab> 開始日 ~ 終了日
# /^.*[\s\S]*\d{2}\/\d{1,2}\/\d{1,2}\s?~\s?\d{2}\/\d{1,2}\/\d{1,2}$/

# とりあえずいくつか正規表現パターンを作って、拾いきれてないパターンはそう多くなさそうなので
# 手動でなおせるものは手動で

# normal_pattern = %r|^.*?[\s\S]*\d{2}/\d{1,2}/\d{1,2}\s?~\s?\d{2}/\d{1,2}/\d{1,2}$|

date_pattern = %r|\d{2}/\d{1,2}/\d{1,2}|
basic_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern})/

# タイトル 20/9/12 ~ 20/10/1
normal_pattern = /#{basic_pattern}\s?~\s?(?<end_date>#{date_pattern})$/

# タイトル 20/9/12;
oneday_pattern = /#{basic_pattern};$/

# タイトル 20/9/12 ~
ongoing_pattern = /#{basic_pattern}\s?~\s?$/

# タイトル 20/9/12 ~ dropped on epi 10 10/3
drop_pattern =
  /#{basic_pattern}\s?~\s?(?<status>drop|suspend|stop).*epi\s?(?<dropped_episode>\d{1,2})?.*?(?<dropped_date>#{date_pattern})?$/

filename = './anime_list/current.txt'

CSV.open('result.csv', 'w') do |csv|
  csv << %w[title start_date end_date status dropped_episode other]
  File.open(filename, 'r') do |f|
    f.each_with_index do |line, _i|
      csv <<
        if (info = normal_pattern.match(line))
          [info[:title], info[:start_date], info[:end_date], 'complete', nil, nil]
        elsif (info = oneday_pattern.match(line))
          [info[:title], info[:start_date], info[:start_date], 'complete', nil, nil]
        elsif (info = ongoing_pattern.match(line))
          [info[:title], info[:start_date], nil, 'ongoing', nil, nil]
        elsif (info = drop_pattern.match(line))
          [info[:title], info[:start_date], info[:dropped_date], info[:status], info[:dropped_episode]]
        else
          [nil, nil, nil, nil, nil, line]
        end
    end
  end
end
