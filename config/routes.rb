Rails.application.routes.draw do
  Healthcheck.routes(self)
  get 'annotators/new'
  root 'tasks#index'
  resources :tasks, only: [:index, :show]
  get '/tasks/:id/start', to: 'tasks#start', as: 'task_start'
  get '/tasks/:id/finish', to: 'tasks#finish', as: 'task_finish'
  resources :annotations, only: [:create]
  delete '/annotations', to: 'annotations#destroy'
  delete '/annotations/undo', to: 'annotations#undo'
  put '/annotations/redo', to: 'annotations#redo'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  resources :annotators, only: [:edit, :update]
  get 'tasks/:id/attributes', to: 'tasks#attributes'
  get 'tasks/:id/values_for/:attribute_id', to: 'tasks#values_for'

  scope '/admin' do
    root 'categories#index', as: 'admin_root'

    resources :annotations, only: [:index]

    # annotators view
    resources :annotators, except: [:edit, :update]
    delete 'annotators/:id', to: 'annotators#destroy', as: 'destroy_annotator'
    patch 'annotators/:id/toggle_admin', to: 'annotators#toggle_admin', as: 'toggle_admin'

    # categories view
    resources :categories, only: [:index, :edit, :create, :update]
    get 'categories/:id/enqueue_prepare_merge', to: 'categories#enqueue_prepare_merge', as: 'enqueue_prepare_merge'
    get 'categories/:id/enqueue_prepare_link', to: 'categories#enqueue_prepare_link', as: 'enqueue_prepare_link'
    get 'categories/:id/enqueue_prepare_link_merge', to: 'categories#enqueue_prepare_link_merge', as: 'enqueue_prepare_link_merge'
    get 'categories/:id/mergeable_count', to: 'categories#mergeable_count', as: 'category_mergeable_count'
    get 'categories/:id/linkable_count', to: 'categories#linkable_count', as: 'category_linkable_count'
    get 'categories/:id/link_mergeable_count', to: 'categories#link_mergeable_count', as: 'category_link_mergeable_count'
    patch 'categories/:id/activate', to: 'categories#activate', as: 'activate_category'
    patch 'categories/:id/hide', to: 'categories#hide', as: 'hide_category'
    post 'categories/:id/imports', to: 'imports#create'
    get 'categories/:id/imports', to: 'imports#index', as: 'imports'
    get 'categories/:id/attributes', to: 'categories#attributes', as: 'category_attributes'

    get 'imports/:id/errors', to: 'import_errors#index', as: 'import_errors'

    # annotations view under category
    resources :annotation_attributes, except: [:index, :new]
    get 'categories/:category_id/annotation_attributes', to: 'annotation_attributes#index', as: 'attributes_index'
    patch 'annotation_attributes/:id/up', to: 'annotation_attributes#up_ord', as: 'up_attribute'
    patch 'annotation_attributes/:id/down', to: 'annotation_attributes#down_ord', as: 'down_attribute'
    patch 'annotation_attributes/:id/toggle_linkable', to: 'annotation_attributes#toggle_linkable', as: 'toggle_linkable'
  end

  # Mergeable
  resources :merge_tasks, only: [:index, :show] do
    resources :merge_attributes, shallow: true, only: [:show] do
      resources :merge_values, shallow: true, only: [:show]
      resources :merge_tags, shallow: true, only: [:create]
    end
  end

  get '/merge_tasks/:id/start', to: 'merge_tasks#start', as: 'merge_task_start'
  put '/merge_tasks/:id/finish', to: 'merge_tasks#finish', as: 'merge_task_finish'
  put '/merge_attributes/:id/complete', to: 'merge_attributes#complete', as: 'complete_merge_attribute'
  put '/merge_tags/:id/approve', to: 'merge_tags#approve', as: 'approve_merge_tag'
  put '/merge_tags/:id/delete', to: 'merge_tags#delete', as: 'delete_merge_tag'

  # Linkable
  resources :link_tasks, only: [:index, :show]
  put '/link_tasks/:id/start', to: 'link_tasks#start', as: 'link_task_start'
  put '/link_tasks/:id/finish', to: 'link_tasks#finish', as: 'link_task_finish'

  resources :link_annotations, only: [:show, :update]

  # Link Mergeable
  resources :link_merge_tasks, only: [:index, :show]
  put '/link_merge_tasks/:id/start', to: 'link_merge_tasks#start', as: 'link_merge_task_start'
  put '/link_merge_tasks/:id/finish', to: 'link_merge_tasks#finish', as: 'link_merge_task_finish'

  resources :link_merge_annotations, only: [:show, :update]
end
