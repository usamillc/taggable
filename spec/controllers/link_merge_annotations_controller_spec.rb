require 'rails_helper'

shared_examples 'a successful completion' do
  it 'should complete the link merge annotation' do
    expect(lma.reload).to be_completed
  end

  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to(link_merge_annotation_url(lma_next, anchor: 'current')) }
end

shared_examples 'a successful completion to task end' do
  context 'without next annotation' do
    let(:resource) { lma_next }

    it 'should complete the link merge annotation' do
      expect(lma_next.reload).to be_completed
    end

    it { expect(response).to have_http_status(:redirect) }
    it { expect(response).to redirect_to(link_merge_task_url(lma_next.link_merge_task)) }
  end
end

shared_examples 'an error' do
  it 'should not complete the link merge annotation' do
    expect(lma.reload).to be_incomplete
  end

  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to(link_merge_annotation_url(lma, anchor: 'current')) }

  it 'should keep all entity link states' do
    lma.annotated_entity_links.each do |e|
      expect(e.reload).to be_conflicted
    end
  end
end

RSpec.describe LinkMergeAnnotationsController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:lma) { create(:link_merge_annotation) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET show' do

    before { get :show, params: { id: lma.id } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:show) }
    it 'should assign @annotation' do
      expect(@controller.instance_variable_get(:@annotation)).to eq(lma)
    end
  end

  describe 'PUT update' do
    let!(:lma) { create(:link_merge_annotation, entity_links) }
    let!(:lma_next) { create(:link_merge_annotation, entity_links, link_merge_task: lma.link_merge_task) }

    let(:params) { { id: resource.id, link_merge_annotation: annotation_params } }
    let(:resource) { lma }
    let(:annotation_params) { { annotated_entity_links: links_param, new_link: new_link_param, no_link: no_link_param } }
    let(:links_param) { {} }
    let(:new_link_param) { { url: "", status: :rejected } }
    let(:entity_links) { nil }
    let(:no_link_param) { false }

    before { put :update, params: params }

    context 'without entity links' do

      context 'with no link true' do
        let(:no_link_param) { true }

        it_behaves_like 'a successful completion'
        it_behaves_like 'a successful completion to task end'
      end

      context 'with no link false' do
        let(:no_link_param) { false }

        it_behaves_like 'an error'
      end
    end

    context 'with annotated entity links' do
      let(:entity_links) { :with_conflicted_links }

      context 'with no link true' do
        let(:no_link_param) { true }

        it 'should reject all entity links' do
          lma.annotated_entity_links.each do |e|
            expect(e.reload).to be_rejected
          end
        end

        it_behaves_like 'a successful completion'
        it_behaves_like 'a successful completion to task end'
      end

      context 'with no link false' do
        let(:no_link_param) { false }

        it_behaves_like 'an error'
      end

      context 'with valid entity links params' do
        let(:e1) { resource.annotated_entity_links.first }
        let(:e2) { resource.annotated_entity_links.second }
        let(:e3) { resource.annotated_entity_links.last }
        let(:links_param) do
          {
            "#{e1.id}": { id: e1.id, match: true, status: :approved },
            "#{e2.id}": { id: e2.id, part_of: true, status: :approved },
            "#{e3.id}": { id: e3.id, status: :rejected }
          }
        end

        context 'with no link true' do
          let(:no_link_param) { true }

          it_behaves_like 'an error'
        end

        context 'with no link false' do
          let(:no_link_param) { false }

          it 'should update entity link states as passed' do
            expect(e1.reload).to be_approved
            expect(e1.reload).to be_match
            expect(e2.reload).to be_approved
            expect(e2.reload).to be_part_of
            expect(e3.reload).to be_rejected
          end

          it_behaves_like 'a successful completion'
          it_behaves_like 'a successful completion to task end'
        end
      end

      context 'with invalid entity links param' do
        let(:e1) { resource.annotated_entity_links.first }
        let(:e2) { resource.annotated_entity_links.second }
        let(:e3) { resource.annotated_entity_links.last }
        let(:links_param) do
          {
            "#{e1.id}": { id: e1.id, match: true, derivation_of: true, status: :approved },
            "#{e2.id}": { id: e2.id, part_of: true, status: :approved },
            "#{e3.id}": { id: e3.id, status: :rejected }
          }
        end

        it_behaves_like 'an error'
      end
    end

    context 'with valid new link param' do
      let(:new_link_param) { { url: url, match: true, status: :approved } }
      let(:url) { "https://ja.mediawiki.usami.llc/wiki/カザフスタン" }

      context 'with no link true' do
        let(:no_link_param) { true }

        it_behaves_like 'an error'
      end

      context 'with no link false' do
        let(:no_link_param) { false }
        let(:ael) { lma.reload.annotated_entity_links.first }

        it 'should assign @new_link' do
          expect(@controller.instance_variable_get(:@new_link)).to be_a(AnnotatedEntityLink)
        end

        it 'should create a new annotated entity link' do
          expect(ael.title).to eq('カザフスタン')
          expect(ael).to be_match
          expect(ael).to be_approved
        end

        it_behaves_like 'a successful completion'
        it_behaves_like 'a successful completion to task end'
      end
    end

    context 'with invalid new link param' do
      context 'with invalid link type' do
        let(:new_link_param) { { url: url, match: true, part_of: true, status: :approved } }
        let(:url) { "https://ja.mediawiki.usami.llc/wiki/カザフスタン" }

        it_behaves_like 'an error'
      end

      context 'with invalid url' do
        let(:new_link_param) { { url: url, match: true, status: :approved } }
        let(:url) { "https://example.com/カザフスタン" }

        it_behaves_like 'an error'
      end
    end
  end
end
