# typed: true

# ==============================================================================
# spec/helpers/access_controlled_for_entry_helper.rb
# ==============================================================================
module AccessControlledForEntryHelper
  extend ActiveSupport::Concern

  T.bind(self, T.untyped)

  included do
    shared_context 'when access controlled by form' do
      before do
        T.cast(reception, Reception).configure_access_control(
          access_control_kind: Reception::AccessControlKindEnum::Form,
          access_control_scope: Reception::AccessControlScopeEnum::AllRestricted,
        )
      end

      let(:token_param) {
        Reception::FormSignature.new(
          tenant: current_tenant, reception:, personal_key: nil,
        ).to_s
      }
    end

    shared_context 'when access controlled by form personal key' do
      before do
        T.cast(reception, Reception).configure_access_control(
          access_control_kind: Reception::AccessControlKindEnum::FormPersonalKey,
          access_control_scope: Reception::AccessControlScopeEnum::AllRestricted,
        )
      end

      let(:token_param) {
        Reception::FormSignature.new(
          tenant: current_tenant, reception:, personal_key: 'some_personal_key',
        ).to_s
      }
    end

    shared_context 'when access controlled by serial code' do |password: false, consumable: true|
      consumption_kind = consumable ? SerialCodePool::ConsumptionKindEnum::Consumable : SerialCodePool::ConsumptionKindEnum::NonConsumable

      let(:serial_code_pool) { create(:serial_code_pool, :with_serial_codes, having_password: password, consumption_kind: consumption_kind.serialize) }
      let(:serial_code) { T.cast(serial_code_pool, SerialCodePool).serial_codes.first }

      before do
        T.cast(reception, Reception).configure_access_control(
          access_control_kind: Reception::AccessControlKindEnum::SerialCode,
          access_control_scope: Reception::AccessControlScopeEnum::AllRestricted,
          serial_code_pool_id: serial_code_pool.id,
        )
      end
    end

    shared_context 'when access controlled by keyword' do
      before do
        T.cast(reception, Reception).configure_access_control(
          access_control_kind: Reception::AccessControlKindEnum::Keyword,
          access_control_scope: Reception::AccessControlScopeEnum::AllRestricted,
          access_control_keyword_secret: 'keyword',
        )
      end
    end

    shared_context 'when current user have used the serial code' do
      before do
        serial_code.update!(user: current_user) if current_user.id != '00000000-0000-0000-0000-000000000000'
      end
    end

    shared_context 'when other user have used the serial code' do
      before do
        serial_code.update!(user: create(:user))
      end
    end

    # --------------------------------------------------------------------------
    # shared_examples
    # --------------------------------------------------------------------------
    # rubocop:disable RSpec/ImplicitSubject
    shared_examples 'validate access controlled behaviors for preview entry' do
      include_context 'when success (without companions)'

      context 'when access controlled by form' do
        include_context 'when access controlled by form'

        context 'when token is valid' do
          let(:params) {
            base_params.merge({
              access_control: {
                token: token_param,
              },
            })
          }

          it 'return preview of entry' do
            is_expected.to eq_status 200
          end
        end

        context 'when token is invalid' do
          let(:params) {
            base_params.merge({
              access_control: {
                token: 'this_is_invalid_token',
              },
            })
          }

          it 'return 403' do
            is_expected.to eq_status 403

            expect(JSON.parse(response.body, symbolize_names: true)).to include({
              error: {
                type: 'forbidden',
                code: 'access_controlled/form',
                message: 'お申込みできないチケットです。',
              },
            })
          end
        end
      end

      context 'when access controlled by form personal key' do
        include_context 'when access controlled by form personal key'

        context 'when token is valid' do
          let(:params) {
            base_params.merge({
              access_control: {
                token: token_param,
              },
            })
          }

          it 'return preview of entry' do
            is_expected.to eq_status 200
          end
        end

        context 'when token is invalid' do
          let(:params) {
            base_params.merge({
              access_control: {
                token: 'this_is_invalid_token',
              },
            })
          }

          it 'return 403' do
            is_expected.to eq_status 403

            expect(JSON.parse(response.body, symbolize_names: true)).to include({
              error: {
                type: 'forbidden',
                code: 'access_controlled/form',
                message: 'お申込みできないチケットです。',
              },
            })
          end
        end
      end

      context 'when access controlled by serial code' do
        context 'when serial code is consumable' do
          include_context 'when access controlled by serial code', password: false, consumable: true

          context 'when serial code is valid' do
            let(:params) {
              base_params.merge({
                access_control: {
                  code: serial_code.code,
                },
              })
            }

            it 'return preview of entry' do
              is_expected.to eq_status 200
            end

            context 'when serial code is already used by current user' do
              include_context 'when current user have used the serial code'

              it 'return 403' do
                is_expected.to eq_status 403

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'forbidden',
                    code: 'access_controlled/serial_code',
                    message: 'お申込みできないチケットです。',
                  },
                })
              end
            end

            context 'when serial code is already used by other user' do
              include_context 'when other user have used the serial code'

              it 'return 403' do
                is_expected.to eq_status 403

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'forbidden',
                    code: 'access_controlled/serial_code',
                    message: 'お申込みできないチケットです。',
                  },
                })
              end
            end
          end

          context 'when serial code is invalid' do
            let(:params) {
              base_params.merge({
                access_control: {
                  code: 'this_is_invalid_serial_code',
                },
              })
            }

            it 'return 403' do
              is_expected.to eq_status 403

              expect(JSON.parse(response.body, symbolize_names: true)).to include({
                error: {
                  type: 'forbidden',
                  code: 'access_controlled/serial_code',
                  message: 'お申込みできないチケットです。',
                },
              })
            end
          end
        end

        context 'when serial code is non-consumable' do
          include_context 'when access controlled by serial code', password: false, consumable: false

          context 'when serial code is valid' do
            let(:params) {
              base_params.merge({
                access_control: {
                  code: serial_code.code,
                },
              })
            }

            it 'return preview of entry' do
              is_expected.to eq_status 200
            end

            context 'when serial code is already used by current user' do
              include_context 'when current user have used the serial code'

              it 'return preview of entry' do
                is_expected.to eq_status 200
              end
            end

            context 'when serial code is already used by other user' do
              include_context 'when other user have used the serial code'

              it 'return 403' do
                is_expected.to eq_status 403

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'forbidden',
                    code: 'access_controlled/serial_code',
                    message: 'お申込みできないチケットです。',
                  },
                })
              end
            end
          end

          context 'when serial code is invalid' do
            let(:params) {
              base_params.merge({
                access_control: {
                  code: 'this_is_invalid_serial_code',
                },
              })
            }

            it 'return 403' do
              is_expected.to eq_status 403

              expect(JSON.parse(response.body, symbolize_names: true)).to include({
                error: {
                  type: 'forbidden',
                  code: 'access_controlled/serial_code',
                  message: 'お申込みできないチケットです。',
                },
              })
            end
          end
        end
      end

      context 'when access controlled by keyword' do
        include_context 'when access controlled by keyword'

        context 'when keyword is valid' do
          let(:params) {
            base_params.merge({
              access_control: {
                keyword: 'keyword',
              },
            })
          }

          it 'return preview of entry' do
            is_expected.to eq_status 200
          end
        end

        context 'when keyword is invalid' do
          let(:params) {
            base_params.merge({
              access_control: {
                keyword: 'invalid_keyword',
              },
            })
          }

          it 'return 403' do
            is_expected.to eq_status 403

            expect(JSON.parse(response.body, symbolize_names: true)).to include({
              error: {
                type: 'forbidden',
                code: 'access_controlled/keyword',
                message: 'お申込みできないチケットです。',
              },
            })
          end
        end
      end
    end

    shared_examples 'validate access controlled behaviors for create entry' do
      include_context 'when success (without companions)'

      context 'when access controlled by form' do
        include_context 'when access controlled by form'

        let(:preview_params) {
          base_preview_params.merge({
            access_control: {
              token: token_param,
            },
          })
        }

        # preview ができていれば token が正しいことは確認できているので create では token なしで通す
        it 'create entry without token' do
          is_expected.to eq_status 201
        end
      end

      context 'when access controlled by form personal key' do
        include_context 'when access controlled by form personal key'

        let(:preview_params) {
          base_preview_params.merge({
            access_control: {
              token: token_param,
            },
          })
        }

        # preview ができていれば token が正しいことは確認できているので create では token なしで通す
        it 'create entry without token' do
          is_expected.to eq_status 201

          the_entry = Entry.find(deserialized.id)
          expect(the_entry.form_personal_key).to eq 'some_personal_key'
        end
      end

      context 'when access controlled by serial code' do
        context 'when serial code is consumable' do
          include_context 'when access controlled by serial code', password: false, consumable: true

          context 'when serial code is valid' do
            let(:preview_params) {
              base_preview_params.merge({
                access_control: {
                  code: serial_code.code,
                },
              })
            }

            it 'create entry' do
              expect {
                is_expected.to eq_status 201
              }.to change { serial_code.reload.user }.from(nil).to(current_user)

              the_entry = Entry.find(deserialized.id)
              expect(the_entry.serial_code).to eq serial_code
              expect(deserialized.serial_code).to eq serial_code.code
            end

            # preview した後に別リクエストで同じ serial code を利用して申込みを完了した場合
            context 'when serial code is already used by current user' do
              it 'return 403' do
                expect(session_id).to be_present
                serial_code.update!(user: current_user)

                is_expected.to eq_status 400

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'invalid_request_error',
                    code: 'validation_error',
                    message: 'エラーが発生しました',
                    params: {
                      messages: {
                        serial_code: [
                          'シリアルコードこのシリアルコードは使用済み、または入力が誤っております。',
                        ],
                      },
                      details: {
                        serial_code: [
                          {
                            error: 'invalid',
                          },
                        ],
                      },
                    },
                  },
                })
              end
            end

            # preview した後に別ユーザーが同じ serial code を利用して申込みを完了した場合
            context 'when serial code is already used by other user' do
              let!(:other_user) { create(:user) }

              it 'return 403' do
                expect(session_id).to be_present
                serial_code.update!(user: other_user)

                is_expected.to eq_status 400

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'invalid_request_error',
                    code: 'validation_error',
                    message: 'エラーが発生しました',
                    params: {
                      messages: {
                        serial_code: [
                          'シリアルコードこのシリアルコードは使用済み、または入力が誤っております。',
                        ],
                      },
                      details: {
                        serial_code: [
                          {
                            error: 'invalid',
                          },
                        ],
                      },
                    },
                  },
                })
              end
            end
          end
        end

        context 'when serial code is non-consumable' do
          include_context 'when access controlled by serial code', password: false, consumable: false

          context 'when serial code is valid' do
            let(:preview_params) {
              base_preview_params.merge({
                access_control: {
                  code: serial_code.code,
                },
              })
            }

            it 'create entry' do
              expect {
                is_expected.to eq_status 201
              }.to change { serial_code.reload.user }.from(nil).to(current_user)

              the_entry = Entry.find(deserialized.id)
              expect(the_entry.serial_code).to eq serial_code
              expect(deserialized.serial_code).to eq serial_code.code
            end

            # preview した後に別リクエストで同じ serial code を利用して申込みを完了した場合
            context 'when serial code was used by current user between preview request' do
              it 'create entry' do
                expect(session_id).to be_present

                expect {
                  serial_code.update!(user: current_user)
                  is_expected.to eq_status 201
                }.to change { serial_code.reload.user }.from(nil).to(current_user)

                the_entry = Entry.find(deserialized.id)
                expect(the_entry.serial_code).to eq serial_code
              end
            end

            # preview した後に別ユーザーが同じ serial code を利用して申込みを完了した場合
            context 'when serial code is already used by other user' do
              let!(:other_user) { create(:user) }

              it 'return 403' do
                # preview request を飛ばした後に別ユーザーが serial code を利用する
                expect(session_id).to be_present
                serial_code.update!(user: other_user)

                is_expected.to eq_status 400

                expect(JSON.parse(response.body, symbolize_names: true)).to include({
                  error: {
                    type: 'invalid_request_error',
                    code: 'validation_error',
                    message: 'エラーが発生しました',
                    params: {
                      messages: {
                        serial_code: [
                          'シリアルコードこのシリアルコードは使用済み、または入力が誤っております。',
                        ],
                      },
                      details: {
                        serial_code: [
                          {
                            error: 'invalid',
                          },
                        ],
                      },
                    },
                  },
                })
              end
            end
          end
        end
      end

      context 'when access controlled by keyword' do
        include_context 'when access controlled by keyword'

        context 'when keyword is valid' do
          let(:preview_params) {
            base_preview_params.merge({
              access_control: {
                keyword: 'keyword',
              },
            })
          }

          it 'create entry' do
            expect {
              is_expected.to eq_status 201
            }.to change { Entry.count }.by(1)
          end
        end
      end
    end
    # rubocop:enable RSpec/ImplicitSubject
  end
end
