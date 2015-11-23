#!/usr/bin/ruby
# coding: utf-8

require 'csv'
require 'mechanize'

bad = '%'
bad2 = ' '

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base_url = "http://collegiatewaterpolo.org/varsity/mwaterpolo/scores"
#http://collegiatewaterpolo.org/club/mwaterpolo/scores/2015

#game_path = "//*[@id="mainbody"]/div/div/div/table/tbody/tr[2]
#game_path = '//*[@id="mainbody"]/div/div/div/table/tr'
game_path = '//tr'

first_year = 2015
last_year = 2015

#games_header = ["year","team_name","team_id","opponent_name","opponent_id",
#                "game_date","team_score","opponent_score","location",
#                "neutral_site_location","game_length","attendance"]

(first_year..last_year).each do |year|

  games = CSV.open("csv/games_#{year}.csv","w")

  #games << games_header

  tries = 0
  url = "#{base_url}/#{year}?dec=/printer-decorator&"
  begin
    page = agent.get(url)
  rescue
    print "error, retrying\n"
    tries += 1
    if tries<3
      sleep 3
      retry
    else
      next
    end
  end

  page.parser.xpath(game_path).each do |tr|

    row = []
    tr.xpath("td").each do |td|
      text = td.inner_text.strip
      text = text.gsub(bad,"").strip
      text = text.gsub(bad2,"").strip
      text = text.gsub('"','').strip
      text = text.gsub("'","").strip
      text = text.gsub('-',' ').strip
      text = text.gsub('. ','.').strip
      if (text=='')
        text = nil
      end
      row += [text]
    end

    if (row[1]==nil)
      next
    end

    if not(row[6]==nil) and (row[6].include?('Forfeit'))
      next
    end
    
    #game_count += 1
    games << [year]+row
      
  end

  games.close

end

