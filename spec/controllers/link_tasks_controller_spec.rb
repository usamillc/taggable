require 'rails_helper'

RSpec.describe LinkTasksController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:t) { create(:link_task) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET index' do
    before { get :index }

    it { expect(response).to be_successful }
    it { expect(response).to render_template(:index) }

    it 'assigns @tasks' do
      expect(assigns(:tasks)).to match_array([t])
    end

    it 'assigns @all_state_tasks' do
      expect(assigns(:tasks)).to match_array([t])
    end
  end

  describe 'GET show' do
    before { get :show, params: {id: t.id} }

    it { expect(response).to be_successful }
    it { expect(response).to render_template(:show) }

    it 'assigns @task' do
      expect(assigns(:task)).to eq(t)
    end

    context 'with incomplete annotations' do
      let!(:t) { create(:link_task, :with_annotations) }
      let(:la) { t.incomplete_annotations.first }

      it { expect(response).to redirect_to(link_annotation_url(la)) }
    end
  end

  describe 'PUT start' do
    before { put :start, params: {id: t.id} }

    it { expect(response).to redirect_to(link_task_url(t)) }

    it 'assigns @task' do
      expect(assigns(:task)).to eq(t)
    end

    it 'starts @task' do
      expect(assigns(:task)).to be_in_progress
    end
  end

  describe 'PUT finish' do
    before { put :finish, params: {id: t.id} }

    it { expect(response).to redirect_to(link_tasks_url(category_id: t.category.id)) }

    it 'assigns @task' do
      expect(assigns(:task)).to eq(t)
    end

    it 'finishes @task' do
      expect(assigns(:task)).to be_completed
    end
  end
end
