class GeneralManagersController < ApplicationController
  before_action :is_owner, only: :create
  before_action :is_user, only: :destroy

  def create
    @gm = GeneralManager.new(general_manager_params)
    @gm.league_id = params[:league_id].to_i
    if @gm.save
      flash[:success] = "Team added!"
      @gm.update_attributes(name: @gm.user.name)
    end
    redirect_to league_path(League.find(@gm.league_id))
  end

  def destroy
    @gm = GeneralManager.find(params[:id])
    league = @gm.league
    flash[:success] = "Team deleted!"
    @gm.destroy
    redirect_to league_path(league)
  end

  def show
    @gm = GeneralManager.find(params[:id].to_i)
    @league = @gm.league

    @r1_forwards = @gm.roster_players.where(round: 1, position: "F").order(round_total: :desc)
    @r1_defensemen = @gm.roster_players.where(round: 1, position: "D").order(round_total: :desc)
    @r1_goalies = @gm.roster_players.where(round: 1, position: "G")

    @r2_forwards = @gm.roster_players.where(round: 2, position: "F").order(round_total: :desc)
    @r2_defensemen = @gm.roster_players.where(round: 2, position: "D").order(round_total: :desc)
    @r2_goalies = @gm.roster_players.where(round: 2, position: "G")

    @r3_forwards = @gm.roster_players.where(round: 3, position: "F").order(round_total: :desc)
    @r3_defensemen = @gm.roster_players.where(round: 3, position: "D").order(round_total: :desc)
    @r3_goalies = @gm.roster_players.where(round: 3, position: "G")

    @r4_forwards = @gm.roster_players.where(round: 4, position: "F").order(round_total: :desc)
    @r4_defensemen = @gm.roster_players.where(round: 4, position: "D").order(round_total: :desc)
    @r4_goalies = @gm.roster_players.where(round: 4, position: "G")

    @r1 = @r2 = @r3 = @r4 = ""
    round = params[:round_number].nil? ? Round.current_round : params[:round_number].to_i

    if round == 4
      @r4 = "active"
    elsif round == 2
      @r2 = "active"
    elsif round == 3
      @r3 = "active"
    else
      @r1 = "active"
    end
  end

  def edit
    @gm = GeneralManager.find(params[:id])
  end

  def update
    @gm = GeneralManager.find(params[:id])
    @gm.update_attributes(general_manager_params)
    if @gm.save
      flash[:success] = "Team updated!"
      redirect_to user_general_manager_path(@gm)
    else
      render 'edit'
    end
  end

  private
    def general_manager_params
      params.require(:general_manager).permit(:user_id, :name, :league_id)
    end

    def is_owner
      @league = current_user.leagues.find(params[:league_id].to_i)
      redirect_to root_url if @league.nil?
    end

    def is_user
      @gm = GeneralManager.find(params[:id])
      redirect_to root_url if current_user == @gm.user
    end
end
