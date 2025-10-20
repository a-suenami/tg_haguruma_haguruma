namespace :admin_area, path: :admin do
  root to: 'contents/root#index'
  # root to: 'dashboard#index'
  # get 'dashboard', to: 'dashboard#index'

  resources :content_entries, only: [:index, :show, :new, :create, :edit, :update] do
    collection do
      get :content_types
    end
  end

  namespace :contents do
    root to: 'root#index'
    get :mobile, to: 'root#mobile', as: :mobile

    get 'all', to: 'list#all', as: :all
    scope 'types/:content_type_id' do
      root to: 'list#by_content_type', as: :by_content_type

      scope module: :collection, as: :collection do
        resources :entries, only: [:new, :create, :edit, :update], controller: 'entries/edit'
        resources :entries, only: :show, controller: 'entries/show'

        post 'entries/:content_entry_id/publication', to: 'publications#create', as: :entry_publication
      end

      scope module: :singleton, as: :singleton do
        resource :entry, only: [:edit, :update], controller: 'entries/edit'
        resource :entry, only: :show, controller: 'entries/show'

        post 'entry/publication', to: 'publications#create', as: :entry_publication
      end
    end
  end

  resources :media, only: [:index]
  resources :categories, only: [:index]
end
