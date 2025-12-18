# typed: false
# frozen_string_literal: true

describe ContentEntry::Field do
  let(:tenant) { create(:tenant, id: 'sample') }
  let(:content_type) { create(:content_type, tenant_id: tenant.id) }
  let(:content_entry) { create(:content_entry, tenant_id: tenant.id, content_type: content_type) }

  before do
    Tenant.current_id = tenant.id
  end

  describe '#validation_errors' do
    context 'when field is required and value is blank' do
      let(:content_type_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title')
      end

      let(:content_entry_version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns error for text field with no value' do
        field = create(
          :content_entry_field,
          content_type_field: content_type_field,
          content_entry_version: content_entry_version,
          text: nil,
        )
        expect(field.validation_errors).to include('Titleは必須です')
      end

      it 'returns error for text field with blank value' do
        text = create(:content_entry_field_text, value: '')
        field = create(
          :content_entry_field,
          content_type_field: content_type_field,
          content_entry_version: content_entry_version,
          text: text,
        )
        expect(field.validation_errors).to include('Titleは必須です')
      end
    end

    context 'when field is required and value is present' do
      let(:content_type_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title')
      end

      let(:content_entry_version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns no errors for text field with value' do
        text = create(:content_entry_field_text, value: 'Hello World')
        field = create(
          :content_entry_field,
          content_type_field: content_type_field,
          content_entry_version: content_entry_version,
          text: text,
        )
        expect(field.validation_errors).to be_empty
      end
    end

    context 'when field is optional' do
      let(:content_type_field) do
        create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: false, label: 'Description')
      end

      let(:content_entry_version) do
        create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
      end

      it 'returns no errors even if value is blank' do
        field = create(
          :content_entry_field,
          content_type_field: content_type_field,
          content_entry_version: content_entry_version,
          text: nil,
        )
        expect(field.validation_errors).to be_empty
      end
    end
  end

  describe '#valid_for_publish?' do
    let(:content_type_field) do
      create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: true, label: 'Title')
    end

    let(:content_entry_version) do
      create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
    end

    it 'returns true when no validation errors' do
      text = create(:content_entry_field_text, value: 'Valid content')
      field = create(
        :content_entry_field,
        content_type_field: content_type_field,
        content_entry_version: content_entry_version,
        text: text,
      )
      expect(field.valid_for_publish?).to be true
    end

    it 'returns false when there are validation errors' do
      field = create(
        :content_entry_field,
        content_type_field: content_type_field,
        content_entry_version: content_entry_version,
        text: nil,
      )
      expect(field.valid_for_publish?).to be false
    end
  end

  describe '#field_value' do
    let(:content_type_field) do
      create(:content_type_field, tenant_id: tenant.id, content_type: content_type, required: false)
    end

    let(:content_entry_version) do
      create(:content_entry_version, tenant_id: tenant.id, content_type: content_type, content_entry: content_entry)
    end

    it 'returns text value for text field' do
      text = create(:content_entry_field_text, value: 'Hello World')
      field = create(
        :content_entry_field,
        content_type_field: content_type_field,
        content_entry_version: content_entry_version,
        text: text,
      )
      expect(field.field_value).to eq('Hello World')
    end

    it 'returns nil when text is nil' do
      field = create(
        :content_entry_field,
        content_type_field: content_type_field,
        content_entry_version: content_entry_version,
        text: nil,
      )
      expect(field.field_value).to be_nil
    end
  end
end
