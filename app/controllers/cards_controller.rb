 class CardsController < ApplicationController
   require "payjp"
   before_action :set_card, only:[:new,:show,:delete]

   def index

   end
  
   def new
     redirect_to action: "show" if @card.present?
   end

   def pay #payjpとCardのデータベース作成を実施します。
     Payjp.api_key = Rails.application.credentials[:pay_jp][:PAYJP_PRIVATE_KEY]
     if params['payjp-token'].blank?
       redirect_to action: "new"
     else
       customer = Payjp::Customer.create(
       description: '登録テスト',  
       card: params['payjp-token'],
       metadata: {user_id: current_user.id}
       ) 
       @card = Card.new(user_id: current_user.id, customer_id: customer.id, card_id: customer.default_card)
       if @card.save
         redirect_to action: "show"
       else
         redirect_to action: "pay"
       end
     end
   end

   def delete #PayjpとCardデータベースを削除します
     if @card.blank?
     else
       Payjp.api_key = Rails.application.credentials[:pay_jp][:PAYJP_PRIVATE_KEY]
       customer = Payjp::Customer.retrieve(@card.customer_id)
       customer.delete
       @card.delete
     end
       redirect_to action: "new"
   end

   def show #Cardのデータpayjpに送り情報を取り出します
     if @card.blank?
       redirect_to action: "new" 
     else
       Payjp.api_key = Rails.application.credentials[:pay_jp][:PAYJP_PRIVATE_KEY]
       customer = Payjp::Customer.retrieve(@card.customer_id)
       @default_card_information = customer.cards.retrieve(@card.card_id)
     end
   end

   def edit
   end
  
   private

   def set_card
     @card = Card.find_by(user_id: current_user.id) 
   end

 end
