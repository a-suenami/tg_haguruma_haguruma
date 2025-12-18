# typed: false
# frozen_string_literal: true

describe ContentEntry::Version do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:content_type) { create(:content_type, tenant_id: tenant.id) }
  let(:content_entry) { create(:content_entry, tenant_id: tenant.id, content_type: content_type) }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#field_validation_errors' do
    context 'when all required fields have values' do
      let!(:required_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title', api_identifier: 'title')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      before do
        text = create(:content_entry_field_text, value: 'Test Title')
        create(
          :content_entry_field,
          content_type_field: required_field,
          content_entry_version: version,
          text: text,
        )
      end

      it 'returns empty hash' do
        expect(version.field_validation_errors).to be_empty
      end
    end

    context 'when required field is missing value' do
      let!(:required_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title', api_identifier: 'title')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      before do
        create(
          :content_entry_field,
          content_type_field: required_field,
          content_entry_version: version,
          text: nil,
        )
      end

      it 'returns errors grouped by api_identifier' do
        errors = version.field_validation_errors
        expect(errors['title']).to include('Titleは必須です')
      end
    end

    context 'when required field does not exist' do
      let!(:required_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Body', api_identifier: 'body')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns error for missing field' do
        errors = version.field_validation_errors
        expect(errors['body']).to include('Bodyは必須です')
      end
    end

    context 'when optional field is blank' do
      let!(:optional_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: false, label: 'Description', api_identifier: 'description')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns no errors' do
        errors = version.field_validation_errors
        expect(errors['description']).to be_nil
      end
    end
  end

  describe '#publishable?' do
    context 'when all required fields are valid' do
      let!(:required_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title', api_identifier: 'title')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      before do
        text = create(:content_entry_field_text, value: 'Valid Title')
        create(
          :content_entry_field,
          content_type_field: required_field,
          content_entry_version: version,
          text: text,
        )
      end

      it 'returns true' do
        expect(version.publishable?).to be true
      end
    end

    context 'when required field is invalid' do
      let!(:required_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title', api_identifier: 'title')
      end

      let(:version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns false' do
        expect(version.publishable?).to be false
      end
    end
  end

  describe '#all_validation_errors' do
    let!(:field1) do
      create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title', api_identifier: 'title')
    end

    let!(:field2) do
      create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Body', api_identifier: 'body', position: 1)
    end

    let(:version) do
      create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
    end

    it 'returns all errors as flat array' do
      errors = version.all_validation_errors
      expect(errors).to include('Titleは必須です')
      expect(errors).to include('Bodyは必須です')
    end
  end
end
