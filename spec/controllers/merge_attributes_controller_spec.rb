require 'rails_helper'

RSpec.describe MergeAttributesController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:ma) { create(:merge_attribute) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET show' do
    let(:params) { { id: ma.id } }

    subject { get :show, params: params }

    it { is_expected.to be_success }
    it { is_expected.to render_template(:show) }

    it 'assigns @merge_attribute' do
      subject
      expect(assigns(:merge_attribute)).to eq(ma)
    end

    context 'with merge values' do
      let!(:mv) { create(:merge_value, merge_attribute: ma) }

      it { is_expected.to redirect_to(mv) }
    end
  end

  describe 'PUT complete' do
    let(:params) { { id: ma.id } }

    subject { put :complete, params: params }

    it { is_expected.to redirect_to(ma.merge_task) }

    it 'completes the merge attribute' do
      subject
      expect(assigns(:merge_attribute).completed?).to eq(true)
    end
  end
end
