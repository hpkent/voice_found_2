module ClientsHelper

  def display_name

    @client = Client.find(@client_id)

    if @client.last_name != nil
      @client.first_name.capitalize + " " + @client.last_name.capitalize
    else
      @client.first_name
    end

  end

  # def client_category

  #   if client.category_name != nil
  #       (client.category_name[0,1])
  #   end

  # end

end
