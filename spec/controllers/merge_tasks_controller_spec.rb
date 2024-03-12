require 'rails_helper'

shared_examples 'a merge task page' do
  it 'assigns @merge_task' do
    subject
    expect(assigns(:merge_task)).to eq(m)
  end
end

RSpec.describe MergeTasksController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:m) { create(:merge_task) }
  let(:params) { {} }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET index' do
    subject { get :index, params: params }

    before { subject }

    it 'assigns @merge_tasks' do
      expect(assigns(:merge_tasks)).to match_array([m])
    end

    it 'assigns @all_state_tasks' do
      expect(assigns(:all_state_tasks)).to match_array([m])
    end

    it 'assigns @categories' do
      expect(assigns(:categories)).to match_array([[m.category.id, m.category.screenname]])
    end

    context 'with status param' do
      let!(:in_progress) { create(:merge_task, :in_progress) }
      let(:params) { { status: 'in_progress' } }

      it 'assigns @merge_tasks with specified state' do
        expect(assigns(:merge_tasks)).to match_array([in_progress])
      end

      it 'assigns @all_state_tasks' do
        expect(assigns(:all_state_tasks)).to match_array([m, in_progress])
      end
    end

    context 'with category param' do
      let(:c) { create(:category) }
      let!(:m2) { create(:merge_task, category: c) }
      let(:params) { { category_id: m2.category.id } }

      it 'assigns @merge_tasks with specified category' do
        expect(assigns(:merge_tasks)).to match_array([m2])
      end

      it 'assigns @all_state_tasks with specified category' do
        expect(assigns(:all_state_tasks)).to match_array([m2])
      end

      context 'with status param' do
        let!(:m3) { create(:merge_task, :in_progress, category: c) }
        let(:params) { { category_id: m3.category.id, status: 'in_progress' } }

        it 'assigns @merge_tasks with specified category and status' do
          expect(assigns(:merge_tasks)).to match_array([m3])
        end

        it 'assigns @all_state_tasks with specified category' do
          expect(assigns(:all_state_tasks)).to match_array([m2, m3])
        end
      end
    end
  end

  describe 'GET show' do
    let(:params) { { id: m.id } }
    subject { get :show, params: params }

    it { is_expected.to redirect_to(merge_tasks_url(category_id: m.category.id)) }

    context 'with merge attributes' do
      let!(:ma) { create(:merge_attribute, merge_task: m) }

      it { is_expected.to redirect_to(ma) }
    end

    context 'with completed attributes' do
      let!(:ma1) { create(:merge_attribute, :completed, merge_task: m) }
      context 'and some non completed attributes' do
        let!(:ma2) { create(:merge_attribute, merge_task: m) }
        let!(:ma3) { create(:merge_attribute, :completed, merge_task: m) }

        it { is_expected.to redirect_to(ma2) }
      end

      context 'only' do
        let!(:ma2) { create(:merge_attribute, :completed, merge_task: m) }
        let!(:ma3) { create(:merge_attribute, :completed, merge_task: m) }
        let!(:mv) { create(:merge_value, merge_attribute: ma1) }
        let!(:mt) { create(:merge_tag, :approved, merge_value: mv) }

        it { is_expected.to render_template(:show) }

        it 'assigns @tags_by_pid' do
          subject
          expect(assigns(:tags_by_pid)).to include( mt.paragraph.id => [mt] )
        end
      end
    end

    it_behaves_like 'a merge task page'
  end

  describe 'GET start' do
    let(:params) { { id: m.id } }
    subject { get :start, params: params }

    it 'makes merge task to be in progress' do
      subject
      expect(assigns(:merge_task).status).to eq('in_progress')
    end

    it { is_expected.to redirect_to(assigns(:merge_task)) }

    it_behaves_like 'a merge task page'
  end

  describe 'PUT finish' do
    let(:params) { { id: m.id } }
    subject { put :finish, params: params }

    it 'makes merge task to be completed' do
      subject
      expect(assigns(:merge_task).status).to eq('completed')
    end

    it { is_expected.to redirect_to(merge_tasks_url(category_id: m.category.id, status: 'not_started')) }

    it_behaves_like 'a merge task page'
  end
end
