require 'rails_helper'

shared_examples 'a successful completion' do
  it 'should complete the link annotation' do
    expect(resource.reload).to be_completed
  end
end

shared_examples 'an error response' do
  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to(link_annotation_url(resource, anchor: 'current')) }

  it 'should contain a error message in flash' do
    expect(flash[:danger]).not_to be_nil
  end

  it 'should not complete the link annotation' do
    expect(resource.reload).to be_incomplete
  end
end

shared_examples 'a redirect to next annotation' do
  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to(link_annotation_url(resource.next, anchor: 'current')) }
end

shared_examples 'a redirect to task page' do
  it { expect(response).to have_http_status(:redirect) }
  it { expect(response).to redirect_to(link_task_url(resource.link_task)) }
end

RSpec.describe LinkAnnotationsController, type: :controller do
  let(:a) { create(:annotator, :team_ando) }
  let!(:la) { create(:link_annotation, :with_entity_links) }

  before do
    allow_any_instance_of(SessionsHelper).to receive(:current_annotator).and_return(a)
  end

  describe 'GET show' do

    before { get :show, params: { id: la.id } }

    it { expect(response).to have_http_status(:success) }
    it { expect(response).to render_template(:show) }
    it 'should assign @annotation' do
      expect(@controller.instance_variable_get(:@annotation)).to eq(la)
    end
  end

  describe 'PUT update' do
    let!(:la2) { create(:link_annotation, :with_entity_links, link_task: la.link_task) }
    let(:params) { { id: resource.id, link_annotation: annotation_params } }
    let(:resource) { la }
    let(:annotation_params) { { entity_links: links_param, new_link: new_link_param, no_link: no_link } }
    let(:links_param) { {} }
    let(:new_link_param) { { url: "", status: :rejected } }
    let(:redirect_url) { link_annotation_url(la2) }

    before { put :update, params: params }

    context 'with no link true' do
      let(:no_link) { true }

      it_behaves_like 'a successful completion'
      it_behaves_like 'a redirect to next annotation'
      it 'should reject all suggested entity links' do
        expect(resource.reload.entity_links.all? { |e| e.rejected? }).to be(true)
      end

      context 'without next annotation' do
        let(:resource) { la2 }

        it_behaves_like 'a successful completion'
        it_behaves_like 'a redirect to task page'
      end

      context 'with an approved entity link' do
        # TODO: error case
      end
    end

    context 'with no link false' do
      let(:no_link) { false }

      context 'with an approved entity link' do
        let(:e) { resource.entity_links.first }
        let(:links_param) { { "#{e.id}": { id: e.id, match: true, status: :approved } } }

        it_behaves_like 'a successful completion'
        it_behaves_like 'a redirect to next annotation'
        it 'should save and approve the passed entity link' do
          expect(e.reload).to be_approved
          expect(e.reload).to be_match
        end

        context 'without next annotation' do
          let(:resource) { la2 }

          it_behaves_like 'a successful completion'
          it_behaves_like 'a redirect to task page'
        end

        context 'with invalid param' do
          let(:links_param) { { "#{e.id}": { id: e.id, match: true, part_of: true, status: :approved } } }

          it_behaves_like 'an error response'
          it 'should not approve the passed entity link' do
            expect(e.reload).not_to be_approved
          end
        end
      end

      context 'with multiple approved entity links' do
        let(:e1) { resource.entity_links.first }
        let(:e2) { resource.entity_links.second }
        let(:links_param) do
          { "#{e1.id}": { id: e1.id, match: true, status: :approved },
            "#{e2.id}": { id: e2.id, part_of: true, status: :approved } }
        end

        it_behaves_like 'a successful completion'
        it_behaves_like 'a redirect to next annotation'
        it 'approves the passed entity links' do
          expect(e1.reload).to be_approved
          expect(e1.reload).to be_match

          expect(e2.reload).to be_approved
          expect(e2.reload).to be_part_of
        end

        context 'without next annotation' do
          let(:resource) { la2 }

          it_behaves_like 'a successful completion'
          it_behaves_like 'a redirect to task page'
        end
      end

      context 'with new entity link' do
        let(:new_link_param) { { url: url, match: true, status: :approved } }
        let(:url) { "https://ja.mediawiki.usami.llc/wiki/カザフスタン" }

        subject { resource.reload.entity_links.approved.first }

        it_behaves_like 'a successful completion'
        it_behaves_like 'a redirect to next annotation'
        it 'creates a new entity link' do
          expect(subject).to be_approved
          expect(subject).to be_match
          expect(subject.title).to eq('カザフスタン')
        end

        context 'without next annotation' do
          let(:resource) { la2 }

          it_behaves_like 'a successful completion'
          it_behaves_like 'a redirect to task page'
        end

        context 'with invalid param' do
          let(:new_link_param) { { url: url, match: true, derivation_of: true, status: :approved } }

          it_behaves_like 'an error response'
          it 'does not save new entity link' do
            expect(EntityLink.find_by(title: 'カザフスタン')).to be_nil
          end
        end
      end

      context 'without an approved entity link' do
        let(:links_param) do
          resource.entity_links.inject({}) do |iter, el|
            iter["#{el.id}"] = { id: el.id, status: :rejected }
            iter
          end
        end

        it_behaves_like 'an error response'
      end
    end
  end
end
