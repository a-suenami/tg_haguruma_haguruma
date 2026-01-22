import { Controller } from '@hotwired/stimulus';

interface SelectOption {
  id?: string;
  display_name: string;
  unique_name: string;
  position: number;
  status?: 'enabled' | 'disabled';
  deletable: boolean;
}

interface SelectData {
  display_format: string;
  options: SelectOption[];
}

interface FieldTypeInfo {
  label: string;
  desc: string;
  icon: string;
}

const FIELD_TYPE_LABELS: Record<string, FieldTypeInfo> = {
  text: {
    label: 'ショートテキスト',
    desc: 'タイトルや名前などの短いテキスト',
    icon: 'pencil',
  },
  richtext: {
    label: 'リッチテキスト',
    desc: 'スタイルや画像、動画などのメディアを含めたテキスト',
    icon: 'file-edit',
  },
  media_asset: {
    label: 'メディア',
    desc: '画像や動画、PDFなどのファイル用',
    icon: 'image',
  },
  select_field: {
    label: 'セレクト',
    desc: 'ドロップダウン、チェックボックス、ラジオボタン',
    icon: 'list',
  },
};

export default class ContentTypeFieldController extends Controller {
  static targets = [
    'hiddenFieldsContainer',
    'fieldsTableBody',
    'emptyFieldsMessage',
    'fieldTypeModal',
    'fieldMetadataModal',
    'contentTypeMetadataModal',
    'selectedFieldTypeIcon',
    'selectedFieldTypeLabel',
    'selectedFieldTypeDesc',
    'modalTitle',
    'submitButton',
    'backButton',
    'fieldIdentifier',
    'fieldName',
    'fieldDescription',
    'fieldRequired',
    'selectFieldSettings',
    'selectDisplayFormat',
    'selectOptionsContainer',
    'hiddenDisplayName',
    'hiddenDescription',
    'pageTitle',
    'sidebarDisplayName',
    'sidebarDescription',
    'modalDisplayName',
    'modalDescription',
  ];

  declare hiddenFieldsContainerTarget: HTMLDivElement;
  declare fieldsTableBodyTarget: HTMLTableSectionElement;
  declare emptyFieldsMessageTarget: HTMLDivElement;
  declare fieldTypeModalTarget: HTMLDivElement;
  declare fieldMetadataModalTarget: HTMLDivElement;
  declare contentTypeMetadataModalTarget: HTMLDivElement;
  declare selectedFieldTypeIconTarget: HTMLSpanElement;
  declare selectedFieldTypeLabelTarget: HTMLSpanElement;
  declare selectedFieldTypeDescTarget: HTMLParagraphElement;
  declare modalTitleTarget: HTMLSpanElement;
  declare submitButtonTarget: HTMLButtonElement;
  declare backButtonTarget: HTMLAnchorElement;
  declare fieldIdentifierTarget: HTMLInputElement;
  declare fieldNameTarget: HTMLInputElement;
  declare fieldDescriptionTarget: HTMLTextAreaElement;
  declare fieldRequiredTarget: HTMLInputElement;
  declare selectFieldSettingsTarget: HTMLDivElement;
  declare selectDisplayFormatTarget: HTMLSelectElement;
  declare selectOptionsContainerTarget: HTMLDivElement;
  declare hiddenDisplayNameTarget: HTMLInputElement;
  declare hiddenDescriptionTarget: HTMLInputElement;
  declare pageTitleTarget: HTMLHeadingElement;
  declare sidebarDisplayNameTarget: HTMLDivElement;
  declare sidebarDescriptionTarget: HTMLDivElement;
  declare modalDisplayNameTarget: HTMLInputElement;
  declare modalDescriptionTarget: HTMLTextAreaElement;

  declare hasFieldsTableBodyTarget: boolean;
  declare hasEmptyFieldsMessageTarget: boolean;

  private selectedFieldType = '';
  private editingFieldId: string | null = null;
  private selectOptionCounter = 0;

  connect(): void {
    this.initSortable();
  }

  private initSortable(): void {
    if (this.hasFieldsTableBodyTarget) {
      // @ts-expect-error UIkit is global
      UIkit.util.on(this.fieldsTableBodyTarget, 'stop', () => {
        this.updateFieldPositions();
      });
    }
  }

  // ============================================================================
  // Field Type Selection
  // ============================================================================

  addField(event: Event): void {
    const button = event.currentTarget as HTMLElement;
    const fieldType = button.dataset.fieldType;
    if (!fieldType) return;

    this.editingFieldId = null;
    this.selectedFieldType = fieldType;
    const info = FIELD_TYPE_LABELS[fieldType];

    this.updateFieldTypeDisplay(info);
    this.clearFieldForm();

    if (fieldType === 'select_field') {
      this.showSelectSettings(true);
      this.clearSelectOptions();
      this.selectDisplayFormatTarget.value = 'dropdown';
      this.addSelectOption();
    } else {
      this.showSelectSettings(false);
    }

    this.modalTitleTarget.textContent = 'フィールドメタデータの設定';
    this.submitButtonTarget.textContent = 'フィールドを追加する';
    this.backButtonTarget.style.display = '';

    this.hideModal('fieldTypeModal');
    this.showModal('fieldMetadataModal');
  }

  editField(event: Event): void {
    event.preventDefault();
    const link = event.currentTarget as HTMLAnchorElement;
    const {
      fieldId,
      fieldType,
      identifier,
      name,
      description,
      required,
    } = link.dataset;
    const selectDataStr = link.dataset.selectData;

    if (!fieldId || !fieldType) return;

    this.editingFieldId = fieldId;
    this.selectedFieldType = fieldType;
    const info = FIELD_TYPE_LABELS[fieldType];

    this.updateFieldTypeDisplay(info);

    this.fieldIdentifierTarget.value = identifier || '';
    this.fieldNameTarget.value = name || '';
    this.fieldDescriptionTarget.value = description || '';
    this.fieldRequiredTarget.checked = required === 'true';

    if (fieldType === 'select_field') {
      this.showSelectSettings(true);
      this.clearSelectOptions();
      if (selectDataStr && selectDataStr !== 'null') {
        try {
          const selectData: SelectData = JSON.parse(selectDataStr);
          this.selectDisplayFormatTarget.value =
            selectData.display_format || 'dropdown';
          if (selectData.options?.length > 0) {
            selectData.options.forEach((opt) => {
              this.addSelectOptionWithValues(opt.display_name, opt.unique_name, opt.id, opt.status, opt.deletable);
            });
          }
        } catch {
          this.selectDisplayFormatTarget.value = 'dropdown';
          this.addSelectOption();
        }
      } else {
        this.selectDisplayFormatTarget.value = 'dropdown';
        this.addSelectOption();
      }
    } else {
      this.showSelectSettings(false);
    }

    this.modalTitleTarget.textContent = 'フィールドの編集';
    this.submitButtonTarget.textContent = '保存する';
    this.backButtonTarget.style.display = 'none';

    this.showModal('fieldMetadataModal');
  }

  backToFieldTypeSelection(event: Event): void {
    event.preventDefault();
    this.hideModal('fieldMetadataModal');
    this.showModal('fieldTypeModal');
  }

  // ============================================================================
  // Field Form Submission
  // ============================================================================

  confirmAddOrUpdateField(event: Event): void {
    event.preventDefault();

    const identifier = this.fieldIdentifierTarget.value.trim();
    const name = this.fieldNameTarget.value.trim();
    const description = this.fieldDescriptionTarget.value.trim();
    const required = this.fieldRequiredTarget.checked;

    if (!identifier || !name) {
      alert('識別子と名前は必須です');
      return;
    }

    if (this.selectedFieldType === 'select_field') {
      const options = this.getSelectOptions();
      if (options.length === 0) {
        alert('セレクトフィールドには少なくとも1つの選択肢が必要です');
        return;
      }
      const validation = this.validateSelectOptions();
      if (!validation.valid) {
        alert(validation.error);
        return;
      }
    }

    if (this.editingFieldId) {
      this.updateExistingField(
        this.editingFieldId,
        identifier,
        name,
        description,
        required,
      );
    } else {
      this.addNewField(identifier, name, description, required);
    }

    this.hideModal('fieldMetadataModal');
  }

  // ============================================================================
  // Field CRUD Operations
  // ============================================================================

  private addNewField(
    identifier: string,
    name: string,
    description: string,
    required: boolean,
  ): void {
    const tenantInput = document.querySelector<HTMLInputElement>(
      'input[name="content_type[tenant_id]"]',
    );
    const tenantId = tenantInput?.value || '';
    const timestamp = Date.now().toString();

    const currentFieldCount = this.hasFieldsTableBodyTarget
      ? this.fieldsTableBodyTarget.querySelectorAll('tr[data-field-id]').length
      : 0;
    const position = currentFieldCount;

    const baseAttr = `content_type[fields_attributes][${timestamp}]`;
    let hiddenFieldsHtml = `
      <div data-field-id="${timestamp}">
        ${this.hiddenInput(baseAttr, 'tenant_id', tenantId)}
        ${this.hiddenInput(baseAttr, 'label', this.escapeHtml(name))}
        ${this.hiddenInput(baseAttr, 'api_identifier', this.escapeHtml(identifier))}
        ${this.hiddenInput(baseAttr, 'description', this.escapeHtml(description))}
        ${this.hiddenInput(baseAttr, 'field_type', this.selectedFieldType)}
        ${this.hiddenInput(baseAttr, 'required', required ? '1' : '0')}
        ${this.hiddenInput(baseAttr, 'position', position.toString())}
        ${this.hiddenInput(baseAttr, '_destroy', 'false', 'field-destroy-input')}
    `;

    let selectDataJson: string | undefined;

    if (this.selectedFieldType === 'select_field') {
      const displayFormat = this.selectDisplayFormatTarget.value;
      const options = this.getSelectOptions();
      const selectAttr = `${baseAttr}[select_attributes]`;
      hiddenFieldsHtml += this.hiddenInput(selectAttr, 'display_format', displayFormat);

      options.forEach((opt, idx) => {
        const optAttr = `${selectAttr}[options_attributes][${idx}]`;
        hiddenFieldsHtml += this.hiddenInput(
          optAttr,
          'display_name',
          this.escapeHtml(opt.display_name),
        );
        hiddenFieldsHtml += this.hiddenInput(
          optAttr,
          'unique_name',
          this.escapeHtml(opt.unique_name),
        );
        hiddenFieldsHtml += this.hiddenInput(
          optAttr,
          'position',
          opt.position.toString(),
        );
        hiddenFieldsHtml += this.hiddenInput(
          optAttr,
          'status',
          opt.status || 'enabled',
        );
      });

      // Build select data JSON for edit functionality
      selectDataJson = JSON.stringify({
        display_format: displayFormat,
        options: options.map((o) => ({
          display_name: o.display_name,
          unique_name: o.unique_name,
          status: o.status || 'enabled',
        })),
      });
    }

    hiddenFieldsHtml += '</div>';
    this.hiddenFieldsContainerTarget.insertAdjacentHTML('beforeend', hiddenFieldsHtml);

    if (this.hasEmptyFieldsMessageTarget) {
      this.emptyFieldsMessageTarget.remove();
    }

    this.ensureTableExists();
    this.addFieldRow(timestamp, identifier, name, description, required, selectDataJson);
  }

  private updateExistingField(
    fieldId: string,
    identifier: string,
    name: string,
    description: string,
    required: boolean,
  ): void {
    const hiddenContainer = this.hiddenFieldsContainerTarget.querySelector(
      `[data-field-id="${fieldId}"]`,
    );
    if (hiddenContainer) {
      this.updateHiddenInput(hiddenContainer, '[label]', name);
      this.updateHiddenInput(hiddenContainer, '[api_identifier]', identifier);
      this.updateHiddenInput(hiddenContainer, '[description]', description);
      this.updateHiddenInput(hiddenContainer, '[required]', required ? '1' : '0');

      // Update select field hidden inputs if applicable
      if (this.selectedFieldType === 'select_field') {
        const displayFormat = this.selectDisplayFormatTarget.value;
        this.updateHiddenInput(hiddenContainer, '[display_format]', displayFormat);

        // Collect existing option IDs from hidden inputs
        const existingOptionIds = new Set<string>();
        const oldOptionIdInputs = hiddenContainer.querySelectorAll<HTMLInputElement>(
          'input[name*="[options_attributes]"][name$="[id]"]',
        );
        oldOptionIdInputs.forEach((input) => {
          if (input.value) {
            existingOptionIds.add(input.value);
          }
        });

        // Remove all old option inputs
        const oldOptionInputs = hiddenContainer.querySelectorAll(
          'input[name*="[options_attributes]"]',
        );
        oldOptionInputs.forEach((input) => input.remove());

        const options = this.getSelectOptions();
        const baseNameMatch = hiddenContainer
          .querySelector('input[name*="[select_attributes]"]')
          ?.getAttribute('name')
          ?.match(/(.+\[select_attributes\])/);

        if (baseNameMatch) {
          const selectAttr = baseNameMatch[1];
          let optionIndex = 0;

          // Track which existing IDs are still in use
          const usedIds = new Set<string>();

          // Process current options
          options.forEach((opt) => {
            const optAttr = `${selectAttr}[options_attributes][${optionIndex}]`;

            // If option has an ID, it's an existing record - UPDATE it
            if (opt.id) {
              usedIds.add(opt.id);
              hiddenContainer.insertAdjacentHTML(
                'beforeend',
                this.hiddenInput(optAttr, 'id', opt.id),
              );
            }
            // If no ID, it's a new record - CREATE it (no id field needed)

            hiddenContainer.insertAdjacentHTML(
              'beforeend',
              this.hiddenInput(optAttr, 'display_name', this.escapeHtml(opt.display_name)),
            );
            hiddenContainer.insertAdjacentHTML(
              'beforeend',
              this.hiddenInput(optAttr, 'unique_name', this.escapeHtml(opt.unique_name)),
            );
            hiddenContainer.insertAdjacentHTML(
              'beforeend',
              this.hiddenInput(optAttr, 'position', opt.position.toString()),
            );
            hiddenContainer.insertAdjacentHTML(
              'beforeend',
              this.hiddenInput(optAttr, 'status', opt.status || 'enabled'),
            );
            optionIndex++;
          });

          // Mark removed options for destruction (existing IDs that are no longer in use)
          existingOptionIds.forEach((oldId) => {
            if (!usedIds.has(oldId)) {
              const optAttr = `${selectAttr}[options_attributes][${optionIndex}]`;
              hiddenContainer.insertAdjacentHTML(
                'beforeend',
                this.hiddenInput(optAttr, 'id', oldId),
              );
              hiddenContainer.insertAdjacentHTML(
                'beforeend',
                this.hiddenInput(optAttr, '_destroy', '1'),
              );
              optionIndex++;
            }
          });
        }
      }
    }

    const row = this.fieldsTableBodyTarget.querySelector<HTMLTableRowElement>(
      `tr[data-field-id="${fieldId}"]`,
    );
    if (row) {
      const asterisk = required
        ? '<span style="color: #f0506e; font-weight: bold; margin-left: 3px;">*</span>'
        : '';

      const identifierCell = row.children[1];
      if (identifierCell) {
        identifierCell.innerHTML = `<code>${this.escapeHtml(identifier)}</code>${asterisk}`;
      }

      const nameCell = row.children[2];
      if (nameCell) {
        const descHtml = description
          ? `<br><small class="uk-text-muted">${this.escapeHtml(description)}</small>`
          : '';
        nameCell.innerHTML = this.escapeHtml(name) + descHtml;
      }

      // Update the edit link's data-select-data attribute
      const editLink = row.querySelector<HTMLAnchorElement>(
        'a[data-action="content-type-field#editField"]',
      );
      if (editLink) {
        editLink.dataset.identifier = identifier;
        editLink.dataset.name = name;
        editLink.dataset.description = description;
        editLink.dataset.required = String(required);

        if (this.selectedFieldType === 'select_field') {
          const options = this.getSelectOptions();
          const selectDataJson = JSON.stringify({
            display_format: this.selectDisplayFormatTarget.value,
            options: options.map((o) => ({
              id: o.id,
              display_name: o.display_name,
              unique_name: o.unique_name,
              status: o.status || 'enabled',
            })),
          });
          editLink.dataset.selectData = selectDataJson;
        }
      }
    }
  }

  confirmRemoveField(event: Event): void {
    event.preventDefault();
    const link = event.currentTarget as HTMLAnchorElement;
    const fieldId = link.dataset.fieldId;

    if (!fieldId) return;

    if (confirm('このフィールドを削除しますか？')) {
      this.removeField(fieldId);
    }
  }

  private removeField(fieldId: string): void {
    const row = this.fieldsTableBodyTarget.querySelector<HTMLTableRowElement>(
      `tr[data-field-id="${fieldId}"]`,
    );
    if (row) {
      row.remove();
    }

    const hiddenFieldContainer = this.hiddenFieldsContainerTarget.querySelector(
      `[data-field-id="${fieldId}"]`,
    );
    if (hiddenFieldContainer) {
      const destroyInput =
        hiddenFieldContainer.querySelector<HTMLInputElement>('.field-destroy-input');
      if (destroyInput) {
        destroyInput.value = '1';
      } else {
        hiddenFieldContainer.remove();
      }
    }

    if (this.fieldsTableBodyTarget.children.length === 0) {
      this.showEmptyState();
    }
  }

  // ============================================================================
  // Select Field Options
  // ============================================================================

  addSelectOption(event?: Event): void {
    event?.preventDefault();
    this.addSelectOptionWithValues('', '');
  }

  private addSelectOptionWithValues(
    displayName: string,
    identifier: string,
    dbId?: string,
    status: 'enabled' | 'disabled' = 'enabled',
    deletable: boolean = true,
  ): void {
    const optionId = this.selectOptionCounter++;
    const dbIdAttr = dbId ? ` data-db-id="${dbId}"` : '';
    const isDisabled = status === 'disabled';
    const rowStyle = isDisabled ? ' style="opacity: 0.5;"' : '';
    const deleteButton = deletable
      ? `<button type="button"
                class="uk-button uk-button-danger uk-button-small"
                data-action="content-type-field#removeSelectOptionById"
                data-option-id="${optionId}">
          <span uk-icon="icon: trash; ratio: 0.8"></span>
        </button>`
      : `<button type="button"
                class="uk-button uk-button-default uk-button-small"
                uk-tooltip="title: 使用中のため削除できません"
                disabled
                style="opacity: 0.5; cursor: not-allowed;">
          <span uk-icon="icon: trash; ratio: 0.8"></span>
        </button>`;
    const optionHtml = `
      <div class="uk-margin-small select-option-row" data-option-id="${optionId}"${dbIdAttr}${rowStyle}>
        <div class="uk-grid-small uk-flex-middle" uk-grid>
          <div class="uk-width-auto">
            <a href="#" uk-icon="icon: menu; ratio: 0.8" class="option-drag-handle" style="cursor: move;"></a>
          </div>
          <div class="uk-width-expand">
            <input type="text"
                   class="uk-input uk-form-small option-display-name"
                   placeholder="表示名（例：ニュース）"
                   value="${this.escapeHtml(displayName)}">
          </div>
          <div class="uk-width-expand">
            <input type="text"
                   class="uk-input uk-form-small option-unique-name"
                   placeholder="識別子（例：news）"
                   value="${this.escapeHtml(identifier)}">
          </div>
          <div class="uk-width-auto">
            <label class="toggle-switch" style="cursor: pointer;">
              <input type="checkbox"
                     class="toggle-switch-input option-status"
                     ${isDisabled ? '' : 'checked'}
                     data-action="change->content-type-field#toggleOptionStatus"
                     data-option-id="${optionId}">
              <span class="toggle-switch-slider"></span>
            </label>
          </div>
          <div class="uk-width-auto">
            ${deleteButton}
          </div>
        </div>
      </div>
    `;
    this.selectOptionsContainerTarget.insertAdjacentHTML('beforeend', optionHtml);

    // Initialize UIkit icon for the new drag handle and trash icon
    const newRow = this.selectOptionsContainerTarget.querySelector(
      `.select-option-row[data-option-id="${optionId}"]`,
    );
    if (newRow) {
      newRow.querySelectorAll('[uk-icon]').forEach((icon) => {
        // @ts-expect-error UIkit is global
        UIkit.icon(icon);
      });
    }
  }

  removeSelectOptionById(event: Event): void {
    event.preventDefault();
    const button = event.currentTarget as HTMLButtonElement;
    const optionId = button.dataset.optionId;
    if (!optionId) return;

    const row = this.selectOptionsContainerTarget.querySelector(
      `.select-option-row[data-option-id="${optionId}"]`,
    );
    if (row) {
      row.remove();
    }
  }

  toggleOptionStatus(event: Event): void {
    const checkbox = event.currentTarget as HTMLInputElement;
    const optionId = checkbox.dataset.optionId;
    if (!optionId) return;

    const row = this.selectOptionsContainerTarget.querySelector<HTMLElement>(
      `.select-option-row[data-option-id="${optionId}"]`,
    );
    if (row) {
      row.style.opacity = checkbox.checked ? '1' : '0.5';
    }
  }

  private getSelectOptions(): SelectOption[] {
    const options: SelectOption[] = [];
    const rows = this.selectOptionsContainerTarget.querySelectorAll<HTMLElement>('.select-option-row');
    rows.forEach((row, index) => {
      const displayName =
        row.querySelector<HTMLInputElement>('.option-display-name')?.value.trim() || '';
      const uniqueName =
        row.querySelector<HTMLInputElement>('.option-unique-name')?.value.trim() || '';
      const statusCheckbox = row.querySelector<HTMLInputElement>('.option-status');
      const status: 'enabled' | 'disabled' = statusCheckbox?.checked ? 'enabled' : 'disabled';
      const dbId = row.dataset.dbId;
      if (displayName && uniqueName) {
        const option: SelectOption = { display_name: displayName, unique_name: uniqueName, position: index, status };
        if (dbId) {
          option.id = dbId;
        }
        options.push(option);
      }
    });
    return options;
  }

  private validateSelectOptions(): { valid: boolean; error?: string } {
    const options = this.getSelectOptions();
    const identifiers = options.map((o) => o.unique_name);
    const duplicates = identifiers.filter(
      (id, index) => identifiers.indexOf(id) !== index,
    );
    if (duplicates.length > 0) {
      const uniqueDupes = [...new Set(duplicates)].join(', ');
      return {
        valid: false,
        error: `選択肢の識別子が重複しています: ${uniqueDupes}`,
      };
    }
    return { valid: true };
  }

  // ============================================================================
  // Content Type Metadata Modal
  // ============================================================================

  openMetadataModal(event: Event): void {
    event.preventDefault();
    this.showModal('contentTypeMetadataModal');
  }

  updateContentTypeMetadata(event: Event): void {
    event.preventDefault();

    const displayName = this.modalDisplayNameTarget.value;
    const description = this.modalDescriptionTarget.value;

    this.hiddenDisplayNameTarget.value = displayName;
    this.hiddenDescriptionTarget.value = description;

    this.pageTitleTarget.textContent = displayName;
    this.sidebarDisplayNameTarget.textContent = displayName;
    this.sidebarDescriptionTarget.textContent = description || '-';

    this.hideModal('contentTypeMetadataModal');
  }

  // ============================================================================
  // Position Management
  // ============================================================================

  private updateFieldPositions(): void {
    if (!this.hasFieldsTableBodyTarget) return;

    const rows = this.fieldsTableBodyTarget.querySelectorAll<HTMLTableRowElement>(
      'tr[data-field-id]',
    );
    rows.forEach((row, index) => {
      const fieldId = row.dataset.fieldId;
      if (!fieldId) return;

      const hiddenContainer = this.hiddenFieldsContainerTarget.querySelector(
        `[data-field-id="${fieldId}"]`,
      );
      if (hiddenContainer) {
        const positionInput =
          hiddenContainer.querySelector<HTMLInputElement>('input[name*="[position]"]');
        if (positionInput) {
          positionInput.value = index.toString();
        }
      }
    });
  }

  // ============================================================================
  // Helper Methods
  // ============================================================================

  private updateFieldTypeDisplay(info: FieldTypeInfo): void {
    this.selectedFieldTypeLabelTarget.textContent = info.label;
    this.selectedFieldTypeDescTarget.textContent = info.desc;
    this.selectedFieldTypeIconTarget.setAttribute('uk-icon', `icon: ${info.icon}; ratio: 1.5`);
  }

  private clearFieldForm(): void {
    this.fieldIdentifierTarget.value = '';
    this.fieldNameTarget.value = '';
    this.fieldDescriptionTarget.value = '';
    this.fieldRequiredTarget.checked = false;
  }

  private showSelectSettings(show: boolean): void {
    this.selectFieldSettingsTarget.style.display = show ? 'block' : 'none';
  }

  private clearSelectOptions(): void {
    this.selectOptionsContainerTarget.innerHTML = '';
    this.selectOptionCounter = 0;
  }

  private showModal(modalName: string): void {
    const target = this.getModalTarget(modalName);
    if (target) {
      // @ts-expect-error UIkit is global
      UIkit.modal(target).show();
    }
  }

  private hideModal(modalName: string): void {
    const target = this.getModalTarget(modalName);
    if (target) {
      // @ts-expect-error UIkit is global
      UIkit.modal(target).hide();
    }
  }

  private getModalTarget(modalName: string): HTMLElement | null {
    switch (modalName) {
      case 'fieldTypeModal':
        return this.fieldTypeModalTarget;
      case 'fieldMetadataModal':
        return this.fieldMetadataModalTarget;
      case 'contentTypeMetadataModal':
        return this.contentTypeMetadataModalTarget;
      default:
        return null;
    }
  }

  private updateHiddenInput(
    container: Element,
    nameSuffix: string,
    value: string,
  ): void {
    const input = container.querySelector<HTMLInputElement>(
      `input[name*="${nameSuffix}"]`,
    );
    if (input) {
      input.value = value;
    }
  }

  private hiddenInput(
    baseName: string,
    fieldName: string,
    value: string,
    className?: string,
  ): string {
    const classAttr = className ? ` class="${className}"` : '';
    return `<input type="hidden" name="${baseName}[${fieldName}]" value="${value}"${classAttr}>`;
  }

  private ensureTableExists(): void {
    if (this.hasFieldsTableBodyTarget) return;

    const tableHtml = `
      <table class="uk-table uk-table-divider uk-table-small">
        <thead>
          <tr>
            <th style="width: 40px;"></th>
            <th>識別子</th>
            <th>名前</th>
            <th>種別</th>
            <th style="width: 40px;"></th>
          </tr>
        </thead>
        <tbody data-content-type-field-target="fieldsTableBody"
               uk-sortable="handle: .drag-handle"></tbody>
      </table>
    `;
    this.hiddenFieldsContainerTarget.insertAdjacentHTML('afterend', tableHtml);
    this.initSortable();
  }

  private addFieldRow(
    timestamp: string,
    identifier: string,
    name: string,
    description: string,
    required: boolean,
    selectData?: string,
  ): void {
    const info = FIELD_TYPE_LABELS[this.selectedFieldType];
    const fieldTypeLabel = info?.label || this.selectedFieldType;
    const fieldTypeIcon = info?.icon || 'file';
    const asterisk = required
      ? '<span style="color: #f0506e; font-weight: bold; margin-left: 3px;">*</span>'
      : '';
    const descHtml = description
      ? `<br><small class="uk-text-muted">${this.escapeHtml(description)}</small>`
      : '';

    const rowHtml = `
      <tr data-field-id="${timestamp}">
        <td class="uk-text-center">
          <a href="#" uk-icon="icon: menu" class="drag-handle" style="cursor: move;"></a>
        </td>
        <td>
          <code>${this.escapeHtml(identifier)}</code>${asterisk}
        </td>
        <td>
          ${this.escapeHtml(name)}${descHtml}
        </td>
        <td>
          <span uk-icon="icon: ${fieldTypeIcon}"></span>
          ${fieldTypeLabel}
        </td>
        <td class="uk-text-center">
          <a href="#" uk-icon="icon: more-vertical"></a>
          <div uk-dropdown="mode: click">
            <ul class="uk-nav uk-dropdown-nav">
              <li>
                <a href="#"
                   data-action="content-type-field#editField"
                   data-field-id="${timestamp}"
                   data-field-type="${this.selectedFieldType}"
                   data-identifier="${this.escapeHtml(identifier)}"
                   data-name="${this.escapeHtml(name)}"
                   data-description="${this.escapeHtml(description)}"
                   data-required="${required}"
                   data-select-data="${this.escapeAttr(selectData || 'null')}">
                  <span uk-icon="icon: pencil; ratio: 0.8"></span> 編集
                </a>
              </li>
              <li>
                <a href="#"
                   data-action="content-type-field#confirmRemoveField"
                   data-field-id="${timestamp}"
                   style="color: #f0506e;">
                  <span uk-icon="icon: trash; ratio: 0.8"></span> 削除
                </a>
              </li>
            </ul>
          </div>
        </td>
      </tr>
    `;
    this.fieldsTableBodyTarget.insertAdjacentHTML('beforeend', rowHtml);

    // Re-initialize UIkit icons
    const newRow = this.fieldsTableBodyTarget.querySelector(
      `tr[data-field-id="${timestamp}"] [uk-icon]`,
    );
    // @ts-expect-error UIkit is global
    UIkit.icon(newRow);
  }

  private showEmptyState(): void {
    const table = this.fieldsTableBodyTarget.closest('table');
    if (table) {
      table.remove();
    }
    const emptyHtml = `
      <div data-content-type-field-target="emptyFieldsMessage"
           class="uk-text-center uk-text-muted uk-margin">
        <p>フィールドがまだありません</p>
        <p>「フィールドを追加」ボタンからフィールドを追加してください</p>
      </div>
    `;
    this.hiddenFieldsContainerTarget.insertAdjacentHTML('afterend', emptyHtml);
  }

  private escapeHtml(text: string): string {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  private escapeAttr(text: string): string {
    return text
      .replace(/&/g, '&amp;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;');
  }
}
