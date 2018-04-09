class SkaterGameStatline < ApplicationRecord
  belongs_to :skater, optional: true
  validates :skater_id, uniqueness: { scope: [:game_id, :game_date] }

  require 'open-uri'

  def self.scrape_all_games
    rounds = Round.get_rounds_hash

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%222017-04-09%22%20and%20gameDate%3C=%222018-04-03%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      SkaterGameStatline.scrape_game(game, round_number)
    end

    Skater.all.each do |skater|
      skater.update_statline
    end
  end

  def self.scrape_todays_games(date)
    rounds = Round.get_rounds_hash

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%22#{date}%22%20and%20gameDate%3C=%22#{date}%2023:59:59%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      SkaterGameStatline.scrape_game(game, round_number)
    end

    SkaterGameStatline.where(game_date: date.to_date).each do |sk|
      sk.skater.update_statline
    end
  end

  def self.update_todays_games
  end

  def self.scrape_game(game, round_number)
    sgs = SkaterGameStatline.new

    sgs.update_attributes(skater_id: game["playerId"].to_i,
                          position: game["playerPositionCode"],
                          team: game["teamAbbrev"],
                          opposition: game["opponentTeamAbbrev"],
                          game_date: game["gameDate"].to_date,
                          game_id: game["gameId"].to_i,
                          goals: game["goals"],
                          assists: game["assists"],
                          points: game["points"],
                          game_winning_goals: game["gameWinningGoals"],
                          round: round_number
                        )
    sgs.save
  end

  def self.scrape_round(r)
    rounds = Round.get_rounds_hash
    round = Round.find_by(round_number: r)

    games_url = "http://www.nhl.com/stats/rest/skaters?isAggregate=false&reportType=basic&isGame=true&reportName=skatersummary&cayenneExp=gameDate%3E=%22#{round.start_date.strftime("%Y-%m-%d")}%22%20and%20gameDate%3C=%22#{round.end_date.strftime("%Y-%m-%d")}%22%20and%20gameTypeId=3"
    games = JSON.parse(Nokogiri::HTML(open(games_url)))
    games["data"].each do |game|
      round_number = rounds[game["teamAbbrev"].to_sym][game["opponentTeamAbbrev"].to_sym].to_i
      SkaterGameStatline.scrape_game(game, round_number)
    end

    Skater.all.each do |skater|
      skater.update_statline
    end
  end
end
