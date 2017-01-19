Rails.application.routes.draw do
  get "/api/v1/machines/index"
  get "/api/v1/machines/get"
  post "/api/v1/machines/save"
  get "/api/v1/machines/status_list"
  get "/api/v1/machines/ansible_hosts"
  post "/api/v1/machines/toggle_service"
  post   "/api/v1/machines/save_network_card"
  delete "/api/v1/machines/delete_network_card"

  get "/api/v1/networks/index"
  get "/api/v1/networks/get"
  post "/api/v1/networks/save"
  post '/test/reset', to: 'api/tests#reset'
  get "/api/v1/networks/status_list"

  get "/api/v1/services/index"
  get "/api/v1/services/get"
  post "/api/v1/services/save"
  get "/api/v1/services/status_list"
  
  put "/api/v1/services/add_to_network"
  delete "/api/v1/services/remove_from_network"
  put "/api/v1/services/add_to_machine"
  delete "/api/v1/services/remove_from_machine"
  
  get "/api/v1/tags/index"
  post "/api/v1/tags/save"

  get    "/api/v1/environments/index"
  post   "/api/v1/environments/save"
  delete "/api/v1/environments/delete"
  get    "/api/v1/environments/get"
  put    "/api/v1/environments/add_to_network"
  put    "/api/v1/environments/add_to_service"
  delete "/api/v1/environments/remove_from_service"
  post   "/api/v1/environments/toggle_network_environment"
  
end


