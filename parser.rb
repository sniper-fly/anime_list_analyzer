require 'pry-byebug'
require 'csv'

def main
  no_date_fmt_filename = './anime_list/no_date.txt'
  old_date_fmt_filename = './anime_list/old_date.txt'
  current_fmt_filename = './anime_list/current.txt'

  output_filename = 'result.csv'
  # output_filename = 'test.csv'

  CSV.open(output_filename, 'w') do |csv|
    csv << %w[title start_date end_date status dropped_episode other]

    File.open(no_date_fmt_filename, 'r') do |f|
      pattern = %r|^(?<title>.*?)\s*(?<start_date>\d{1,4}/\d)?$|
      f.each do |line|
        info = pattern.match(line)
        csv << [info[:title], info[:start_date]]
      end
    end

    File.open(old_date_fmt_filename, 'r') do |f|
      f.each do |line|
        csv << convert_old_date_fmt2csv(line)
      end
    end

    File.open(current_fmt_filename, 'r') do |f|
      f.each do |line|
        csv << convert_current_fmt2csv(line)
      end
    end
  end
end

def convert_old_date_fmt2csv(line)
  date_pattern = %r|\d{2}/\d{1,2}/\d{1,2}|
  basic_pattern = /^(?<title>.*?)\s*(?<start_date>#{date_pattern})/

  # タイトル 20/9/12 ~ 20/10/1
  range_pattern = /#{basic_pattern}\s?~\s?(?<end_date>#{date_pattern})$/

  # タイトル 20/9/12;
  oneday_pattern = /#{basic_pattern};$/

  # タイトル 20/9/12
  start_only_pattern = /#{basic_pattern}$/

  if (info = range_pattern.match(line))
    [info[:title], info[:start_date], info[:end_date], 'complete', nil, nil]
  elsif (info = oneday_pattern.match(line))
    [info[:title], info[:start_date], info[:start_date], 'complete', nil, nil]
  elsif (info = start_only_pattern.match(line))
    [info[:title], info[:start_date], nil, 'complete', nil, nil]
  else
    [nil, nil, nil, nil, nil, line]
  end
end

def convert_current_fmt2csv(line)
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

main
