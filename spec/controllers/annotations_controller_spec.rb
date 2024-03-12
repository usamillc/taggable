require 'rails_helper'

RSpec.describe AnnotationsController, type: :controller do
  let(:annotator) { skip("Fix the controller spec") }
  let(:annotation_attribute) { create(:annotation_attribute) }

  describe 'POST /annotations' do
    let!(:tp) { create(:task_paragraph) }
    let(:p) { tp.paragraph }
    let(:params) { { page_id: p.page_id, text: 'hello', annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, start_offset: 4, end_offset: 10, value: 'example', paragraph_id: tp.id } }

    subject { post :create, params: { annotation: params } }

    before do
      allow_any_instance_of(Paragraph).to receive(:match).and_return [1, 7]
    end

    it 'returns success http code' do
      subject
      expect(response).to have_http_status(:created)
    end

    it 'creates new annotation' do
      expect { subject }.to change(Annotation, :count).from(0).to(1)
      a = Annotation.first
      expect(a.reflected).to be false
      expect(a.deleted).to be false
    end

    context 'with deleted annotations' do
      before do
        Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: p.id, deleted: true)
        Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: p.id, deleted: true)
      end

      it 'deletes all deleted annotations' do
        expect { subject }.to change(Annotation, :count).from(2).to(1)
      end
    end
  end

  describe 'DELETE /annotations/undo' do
    let(:category) { Category.create(name: 'test') }
    let(:page) { Page.create(title: 'test', category: category) }
    let(:paragraph) { Paragraph.create(page_id: page.id) }
    let!(:a1) { Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: paragraph.id, value: 'a1') }
    let!(:a2) { Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: paragraph.id, value: 'a2', deleted: false, reflected: true) }

    subject { delete :undo, params: { page_id: page.id } }

    it 'marks the last annotation as deleted' do
      subject
      expect(a2.reload.deleted).to eq true
      expect(a2.reload.reflected).to eq false
    end

    context 'with already deleted annotation' do
      let!(:a3) { Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: paragraph.id, value: 'a3', deleted: true) }

      it 'marks the last non deleted annotation as deleted' do
        subject
        expect(a2.reload.deleted).to eq true
      end
    end
  end

  describe 'PUT /annotations/redo' do
    let(:paragraph) { Paragraph.create(page_id: page.id) }
    let!(:a1) { Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: paragraph.id, value: 'a1', deleted: true) }
    let!(:a2) { Annotation.create(annotator_id: annotator.id, annotation_attribute_id: annotation_attribute.id, paragraph_id: paragraph.id, value: 'a2', deleted: true) }

    subject { put :redo, params: { page_id: page.id } }

    it 'marks the oldest deleted annotation as not deleted' do
      subject
      expect(a1.reload.deleted).to eq false
    end
  end
end
