ActiveAdmin.register Category do
  index do
    column :name
    column :updated_at
    actions
  end

  controller do
    def permitted_params
      params.permit!
    end
  end

end
