require 'rails_helper'

RSpec.describe MergeValuesController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:mv) { create(:merge_value) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET show' do
    let(:params) { { id: mv.id } }

    subject { get :show, params: params }

    it { is_expected.to be_success }

    it { is_expected.to render_template(:show) }

    it 'assigns @merge_value' do
      subject
      expect(assigns(:merge_value)).to eq(mv)
    end

    context 'with merge tags' do
      let!(:mt) { create(:merge_tag, merge_value: mv) }

      it 'assigns @tags_by_pid' do
        subject
        expect(assigns(:tags_by_pid)).to include( mt.paragraph.id => [mt] )
      end
    end
  end
end
