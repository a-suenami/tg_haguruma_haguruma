# typed: false

require 'rails_helper'

RSpec.describe 'AdminArea::Contents routing', type: :routing do
  describe 'root and mobile routes' do
    it 'routes GET /admin/contents to contents/root#index' do
      expect(get: '/admin/contents').to route_to(
        controller: 'admin_area/contents/root',
        action: 'index',
      )
    end

    it 'routes GET /admin/contents/mobile to contents/root#mobile' do
      expect(get: '/admin/contents/mobile').to route_to(
        controller: 'admin_area/contents/root',
        action: 'mobile',
      )
    end
  end

  describe 'list routes' do
    it 'routes GET /admin/contents/all to list#all' do
      expect(get: '/admin/contents/all').to route_to(
        controller: 'admin_area/contents/list',
        action: 'all',
      )
    end

    it 'routes GET /admin/contents/types/:content_type_id to list#by_content_type' do
      expect(get: '/admin/contents/types/abc-123').to route_to(
        controller: 'admin_area/contents/list',
        action: 'by_content_type',
        content_type_id: 'abc-123',
      )
    end
  end

  describe 'collection routes' do
    let(:content_type_id) { 'content-type-123' }
    let(:entry_id) { 'entry-456' }

    describe 'show' do
      it 'routes GET /admin/contents/types/:content_type_id/entries/:id to collection/entries/show#show' do
        expect(get: "/admin/contents/types/#{content_type_id}/entries/#{entry_id}").to route_to(
          controller: 'admin_area/contents/collection/entries/show',
          action: 'show',
          content_type_id: content_type_id,
          id: entry_id,
        )
      end
    end

    describe 'edit' do
      it 'routes GET /admin/contents/types/:content_type_id/entries/new to collection/entries/edit#new' do
        expect(get: "/admin/contents/types/#{content_type_id}/entries/new").to route_to(
          controller: 'admin_area/contents/collection/entries/edit',
          action: 'new',
          content_type_id: content_type_id,
        )
      end

      it 'routes POST /admin/contents/types/:content_type_id/entries to collection/entries/edit#create' do
        expect(post: "/admin/contents/types/#{content_type_id}/entries").to route_to(
          controller: 'admin_area/contents/collection/entries/edit',
          action: 'create',
          content_type_id: content_type_id,
        )
      end

      it 'routes GET /admin/contents/types/:content_type_id/entries/:id/edit to collection/entries/edit#edit' do
        expect(get: "/admin/contents/types/#{content_type_id}/entries/#{entry_id}/edit").to route_to(
          controller: 'admin_area/contents/collection/entries/edit',
          action: 'edit',
          content_type_id: content_type_id,
          id: entry_id,
        )
      end

      it 'routes PATCH /admin/contents/types/:content_type_id/entries/:id to collection/entries/edit#update' do
        expect(patch: "/admin/contents/types/#{content_type_id}/entries/#{entry_id}").to route_to(
          controller: 'admin_area/contents/collection/entries/edit',
          action: 'update',
          content_type_id: content_type_id,
          id: entry_id,
        )
      end

      it 'routes PUT /admin/contents/types/:content_type_id/entries/:id to collection/entries/edit#update' do
        expect(put: "/admin/contents/types/#{content_type_id}/entries/#{entry_id}").to route_to(
          controller: 'admin_area/contents/collection/entries/edit',
          action: 'update',
          content_type_id: content_type_id,
          id: entry_id,
        )
      end
    end

    describe 'publication' do
      it 'routes POST /admin/contents/types/:content_type_id/entries/:content_entry_id/publication to collection/publications#create' do
        expect(post: "/admin/contents/types/#{content_type_id}/entries/#{entry_id}/publication").to route_to(
          controller: 'admin_area/contents/collection/publications',
          action: 'create',
          content_type_id: content_type_id,
          content_entry_id: entry_id,
        )
      end
    end
  end

  describe 'singleton routes' do
    let(:content_type_id) { 'content-type-789' }

    describe 'show' do
      it 'routes GET /admin/contents/types/:content_type_id/entry to singleton/entries/show#show' do
        expect(get: "/admin/contents/types/#{content_type_id}/entry").to route_to(
          controller: 'admin_area/contents/singleton/entries/show',
          action: 'show',
          content_type_id: content_type_id,
        )
      end
    end

    describe 'edit' do
      it 'routes GET /admin/contents/types/:content_type_id/entry/edit to singleton/entries/edit#edit' do
        expect(get: "/admin/contents/types/#{content_type_id}/entry/edit").to route_to(
          controller: 'admin_area/contents/singleton/entries/edit',
          action: 'edit',
          content_type_id: content_type_id,
        )
      end

      it 'routes PATCH /admin/contents/types/:content_type_id/entry to singleton/entries/edit#update' do
        expect(patch: "/admin/contents/types/#{content_type_id}/entry").to route_to(
          controller: 'admin_area/contents/singleton/entries/edit',
          action: 'update',
          content_type_id: content_type_id,
        )
      end

      it 'routes PUT /admin/contents/types/:content_type_id/entry to singleton/entries/edit#update' do
        expect(put: "/admin/contents/types/#{content_type_id}/entry").to route_to(
          controller: 'admin_area/contents/singleton/entries/edit',
          action: 'update',
          content_type_id: content_type_id,
        )
      end
    end

    describe 'publication' do
      it 'routes POST /admin/contents/types/:content_type_id/entry/publication to singleton/publications#create' do
        expect(post: "/admin/contents/types/#{content_type_id}/entry/publication").to route_to(
          controller: 'admin_area/contents/singleton/publications',
          action: 'create',
          content_type_id: content_type_id,
        )
      end
    end
  end
end
