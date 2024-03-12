require 'rails_helper'

RSpec.describe MergeTagsController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:mt) { create(:merge_tag) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'PUT approve' do
    let(:params) { { id: mt.id } }

    subject { put :approve, params: params }

    it { is_expected.to be_success }

    it 'approves the merge tag' do
      subject
      expect(assigns(:merge_tag).approved?).to eq(true)
    end
  end

  describe 'PUT delete' do
    let(:params) { { id: mt.id } }

    before { request.env["HTTP_REFERER"] = 'http://example.com' }

    subject { put :delete, params: params }

    it 'deletes the merge tag' do
      subject
      expect(assigns(:merge_tag).deleted?).to eq(true)
    end

    it 'redirects back' do
      is_expected.to redirect_to('http://example.com')
    end
  end

  describe 'POST create' do
    let(:p) { create(:paragraph) }
    let!(:ma) { create(:merge_attribute) }
    let!(:mv) { create(:merge_value, merge_attribute: ma, value: 'アメリカ合衆国' ) }
    let(:params) { { merge_tag: { paragraph_id: p.id, start_offset: 31, end_offset: 38, value: mv.value, text: p.no_tag }, merge_attribute_id: ma.id } }

    subject { post :create, params: params }

    it 'creates approved merge tag' do
      expect { subject }.to change(MergeTag, :count).by(1)
      expect(MergeTag.last.approved?).to eq(true)
    end

    it 'creates merge tag with appropriate merge value' do
      subject
      expect(MergeTag.last.merge_value).to eq(mv)
    end

    it 'redirects to the merge value' do
      is_expected.to redirect_to mv
    end

    context 'without matching merge value' do
      let(:params) { { merge_tag: { paragraph_id: p.id, start_offset: 3, end_offset: 13, value: '1936-10-03', text: p.no_tag }, merge_attribute_id: ma.id } }

      it 'creates merge value as well' do
        expect { subject }.to change(MergeValue, :count).by(1)
        expect(MergeTag.last.merge_value).to eq(MergeValue.last)
      end
    end

    context 'with paragraph match returns different offsets' do
      before { allow_any_instance_of(Paragraph).to receive(:match).and_return([41, 48]) }

      it 'creates merge tag with modified offsets' do
        subject
        expect(MergeTag.last.start_offset).to eq(41)
        expect(MergeTag.last.end_offset).to eq(48)
      end
    end

    context 'without valid paragraph' do
      let(:params) { { merge_tag: { paragraph_id: 0, start_offset: 0, end_offset: 10, value: 'asdf'}, merge_attribute_id: ma.id } }
      it { expect { subject }.to raise_error(ActiveRecord::RecordNotFound) }
    end

    context 'when paragraph match returns offsets not aligned with the text' do
      before do
        allow_any_instance_of(Paragraph).to receive(:match).and_return([20, 31])
        request.env["HTTP_REFERER"] = 'http://example.com'
      end

      it { expect { subject }.not_to change(MergeTag, :count) }

      it 'shows flash alert message' do
        subject
        expect(flash[:danger]).not_to be_nil
      end

      it 'redirects back' do
        is_expected.to redirect_to('http://example.com')
      end

      context 'with bad value' do
        before { allow_any_instance_of(Paragraph).to receive(:match).and_return([20, nil]) }

        it 'shows flash alert message' do
          subject
          expect(flash[:danger]).not_to be_nil
        end

        it 'redirects back' do
          is_expected.to redirect_to('http://example.com')
        end
      end
    end

    context 'when MergeTag#create! raised ActiveRecord::RecordInvalid error' do
      before { allow_any_instance_of(MergeTag).to receive(:valid?).and_return(false) }

      it 'does not create MergeValue' do
        expect { subject }.not_to change(MergeValue, :count)
      end
    end
  end
end
