# typed: true

# ==============================================================================
# spec - helpers - dataset helper
# ==============================================================================
module DatasetHelper
  extend ActiveSupport::Concern

  class_methods do
    def prepare_reception_dataset
      T.bind(self, T.untyped)

      let!(:tour) { create(:tour) }

      let!(:fee_1) {
        create(:fee, :single_range, tour:, position: 1, charging_unit: :per_choice, kind: :base, target_name: nil, no_refund: false, single_range_amount: 333, name: 'システム利用料')
      }
      let!(:fee_2) {
        create(:fee, :single_range, tour:, position: 2, charging_unit: :per_ticket, kind: :base, target_name: nil, no_refund: false,
       single_range_amount: 444, name: '特別手数料',)
      }
      let!(:fee_3) {
        create(:fee, :pay_easy_1, tour:, position: 3, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::PayEasyV1.to_s, no_refund: true, name: 'ペイジー手数料')
      }
      let!(:fee_4) {
        create(
          :fee, :konbini_1, tour:, position: 4, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::KonbiniSevenElevenV1.to_s, no_refund: true,
          name: 'コンビニ手数料',
        )
      }
      let!(:fee_5) {
        create(
          :fee, :single_range, tour:, position: 5, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::TapirsSqrcV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'SQRC',
        )
      }
      let!(:fee_6) {
        create(
          :fee, :single_range, tour:, position: 6, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::MoalaTicketV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'MoalaTicket',
        )
      }

      let!(:act_1) { create(:act, tour:, position: 1, name: '東京公演') }
      let!(:act_2) { create(:act, tour:, position: 2, name: '名古屋公演') }
      let!(:act_3) { create(:act, tour:, position: 3, name: '大阪公演') }
      let!(:act_4) { create(:act, tour:, position: 4, name: '福岡公演') }
      let!(:act_5) { create(:act, tour:, position: 5, name: '札幌公演') }

      let!(:seat_1) { create(:seat, :default_seat_plan, tour:, position: 1, name: 'S席', default_seat_plan_price: 22_500) }
      let!(:seat_2) { create(:seat, :default_seat_plan, tour:, position: 2, name: 'A席', default_seat_plan_price: 11_050) }
      let!(:seat_3) { create(:seat, :default_seat_plan, tour:, position: 3, name: 'B席', default_seat_plan_price: 9_760) }
      let!(:seat_4) { create(:seat, :default_seat_plan, tour:, position: 4, name: '立ち見席', default_seat_plan_price: 7_590) }
      let!(:seat_5) { create(:seat,                     tour:, position: 5, name: '親子券') }
      let!(:seat_6) { create(:seat,                     tour:, position: 6, name: 'ファミリー券') }
      let!(:seat_5_seat_plan_1) { create(:seat_plan, seat: seat_5, price: 10_000, name: '大人', position: 1) }
      let!(:seat_5_seat_plan_2) { create(:seat_plan, seat: seat_5, price: 6_500,  name: '子供', position: 2) }
      let!(:seat_6_seat_plan_1) { create(:seat_plan, seat: seat_6, price: 10_000, name: '大人', position: 1) }
      let!(:seat_6_seat_plan_2) { create(:seat_plan, seat: seat_6, price: 8_000,  name: '高校生', position: 2) }
      let!(:seat_6_seat_plan_3) { create(:seat_plan, seat: seat_6, price: 7_000,  name: '中学生', position: 3) }
      let!(:seat_6_seat_plan_4) { create(:seat_plan, seat: seat_6, price: 6_000,  name: '小学生', position: 4) }

      let!(:act_1_seat_1) { create(:act_seat, act: act_1, seat: seat_1, resale_enabled: true) }
      let!(:act_1_seat_2) { create(:act_seat, act: act_1, seat: seat_2, resale_enabled: true) }
      let!(:act_1_seat_4) { create(:act_seat, act: act_1, seat: seat_4, resale_enabled: true) }

      let!(:act_2_seat_1) { create(:act_seat, act: act_2, seat: seat_1, resale_enabled: true) }
      let!(:act_2_seat_4) { create(:act_seat, act: act_2, seat: seat_4, resale_enabled: true) }
      let!(:act_2_seat_6) { create(:act_seat, act: act_2, seat: seat_6, resale_enabled: true) }

      # この reception では使わないがレコードは作成しておく
      let!(:act_3_seat_1) { create(:act_seat, act: act_3, seat: seat_1, resale_enabled: true) }

      let!(:act_4_seat_1) { create(:act_seat, act: act_4, seat: seat_1, resale_enabled: true) }
      let!(:act_4_seat_3) { create(:act_seat, act: act_4, seat: seat_3, resale_enabled: true) }
      let!(:act_4_seat_2) { create(:act_seat, act: act_4, seat: seat_2, resale_enabled: true) }

      let!(:act_5_seat_2) { create(:act_seat, act: act_5, seat: seat_2, resale_enabled: true) }
      let!(:act_5_seat_5) { create(:act_seat, act: act_5, seat: seat_5, resale_enabled: true) }
      let!(:act_5_seat_6) { create(:act_seat, act: act_5, seat: seat_6, resale_enabled: true) }

      let!(:reception_act_1_seat_1_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_1) }
      let!(:reception_act_1_seat_2_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_2) }
      let!(:reception_act_1_seat_4_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_4) }

      let!(:reception_act_2_seat_1_act_seat) { create(:reception_act_seat, reception:, act_seat: act_2_seat_1) }
      let!(:reception_act_2_seat_4_act_seat) { create(:reception_act_seat, reception:, act_seat: act_2_seat_4) }
      let!(:reception_act_2_seat_6_act_seat) { create(:reception_act_seat, reception:, act_seat: act_2_seat_6) }

      # act_3 大阪公演は受付対象外

      let!(:reception_act_4_seat_1_act_seat) { create(:reception_act_seat, reception:, act_seat: act_4_seat_1) }
      let!(:reception_act_4_seat_3_act_seat) { create(:reception_act_seat, reception:, act_seat: act_4_seat_3) }
      let!(:reception_act_4_seat_2_act_seat) { create(:reception_act_seat, reception:, act_seat: act_4_seat_2) }

      let!(:reception_act_5_seat_2_act_seat) { create(:reception_act_seat, reception:, act_seat: act_5_seat_2) }
      let!(:reception_act_5_seat_5_act_seat) { create(:reception_act_seat, reception:, act_seat: act_5_seat_5) }
      let!(:reception_act_5_seat_6_act_seat) { create(:reception_act_seat, reception:, act_seat: act_5_seat_6) }

      let!(:reception_act_1_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_1_act_seat) }
      let!(:reception_act_1_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_2_act_seat) }
      let!(:reception_act_1_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_4_act_seat) }

      let!(:reception_act_2_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_1_act_seat) }
      let!(:reception_act_2_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_4_act_seat) }
      let!(:reception_act_2_seat_6_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_6_act_seat, seat_plan: seat_6_seat_plan_1) }
      let!(:reception_act_2_seat_6_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_6_act_seat, seat_plan: seat_6_seat_plan_2) }
      let!(:reception_act_2_seat_6_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_6_act_seat, seat_plan: seat_6_seat_plan_3) }
      let!(:reception_act_2_seat_6_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_act_2_seat_6_act_seat, seat_plan: seat_6_seat_plan_4) }

      let!(:reception_act_4_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_4_seat_1_act_seat) }
      let!(:reception_act_4_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_4_seat_3_act_seat) }
      let!(:reception_act_4_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_4_seat_2_act_seat) }

      let!(:reception_act_5_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_2_act_seat) }
      let!(:reception_act_5_seat_5_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_5_act_seat, seat_plan: seat_5_seat_plan_1) }
      let!(:reception_act_5_seat_5_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_5_act_seat, seat_plan: seat_5_seat_plan_2) }
      let!(:reception_act_5_seat_6_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_6_act_seat, seat_plan: seat_6_seat_plan_1) }
      let!(:reception_act_5_seat_6_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_6_act_seat, seat_plan: seat_6_seat_plan_2) }
      let!(:reception_act_5_seat_6_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_6_act_seat, seat_plan: seat_6_seat_plan_3) }
      let!(:reception_act_5_seat_6_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_act_5_seat_6_act_seat, seat_plan: seat_6_seat_plan_4) }

      let!(:reception_fee_1) { create(:reception_fee, reception:, fee: fee_1) }
      let!(:reception_fee_2) { create(:reception_fee, reception:, fee: fee_2) }
      let!(:reception_fee_3) { create(:reception_fee, reception:, fee: fee_3) }
      let!(:reception_fee_4) { create(:reception_fee, reception:, fee: fee_4) }
      let!(:reception_fee_5) { create(:reception_fee, reception:, fee: fee_5) }
      let!(:reception_fee_6) { create(:reception_fee, reception:, fee: fee_6) }
    end

    def prepare_multiple_receptions_dataset
      T.bind(self, T.untyped)

      let!(:tour) { create(:tour) }

      let!(:fee_1) {
        create(:fee, :single_range, tour:, position: 1, charging_unit: :per_choice, kind: :base, target_name: nil, no_refund: false, single_range_amount: 333, name: 'システム利用料')
      }
      let!(:fee_2) {
        create(:fee, :single_range, tour:, position: 2, charging_unit: :per_ticket, kind: :base, target_name: nil, no_refund: false,
       single_range_amount: 444, name: '特別手数料',)
      }
      let!(:fee_3) {
        create(:fee, :pay_easy_1, tour:, position: 3, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::PayEasyV1.to_s, no_refund: true, name: 'ペイジー手数料')
      }
      let!(:fee_4) {
        create(
          :fee, :konbini_1, tour:, position: 4, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::KonbiniSevenElevenV1.to_s, no_refund: true,
          name: 'コンビニ手数料',
        )
      }
      let!(:fee_5) {
        create(
          :fee, :single_range, tour:, position: 5, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::TapirsSqrcV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'SQRC',
        )
      }
      let!(:fee_6) {
        create(
          :fee, :single_range, tour:, position: 6, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::MoalaTicketV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'MoalaTicket',
        )
      }

      let!(:act_1) { create(:act, tour:, position: 1, name: '東京公演') }
      let!(:act_2) { create(:act, tour:, position: 2, name: '名古屋公演') }
      let!(:act_3) { create(:act, tour:, position: 3, name: '大阪公演') }
      let!(:act_4) { create(:act, tour:, position: 4, name: '福岡公演') }

      let!(:seat_1) { create(:seat, :default_seat_plan, tour:, position: 1, name: 'S席', default_seat_plan_price: 22_500) }
      let!(:seat_2) { create(:seat, :default_seat_plan, tour:, position: 2, name: 'A席', default_seat_plan_price: 11_050) }
      let!(:seat_3) { create(:seat, :default_seat_plan, tour:, position: 3, name: 'B席', default_seat_plan_price: 9_760) }
      let!(:seat_4) { create(:seat,                     tour:, position: 6, name: 'ファミリー券') }
      let!(:seat_4_seat_plan_1) { create(:seat_plan, seat: seat_4, price: 10_000, name: '大人', position: 1) }
      let!(:seat_4_seat_plan_2) { create(:seat_plan, seat: seat_4, price: 8_000,  name: '高校生', position: 2) }
      let!(:seat_4_seat_plan_3) { create(:seat_plan, seat: seat_4, price: 7_000,  name: '中学生', position: 3) }
      let!(:seat_4_seat_plan_4) { create(:seat_plan, seat: seat_4, price: 6_000,  name: '小学生', position: 4) }

      let!(:act_1_seat_1) { create(:act_seat, act: act_1, seat: seat_1, resale_enabled: true) }
      let!(:act_1_seat_2) { create(:act_seat, act: act_1, seat: seat_2, resale_enabled: true) }
      let!(:act_1_seat_3) { create(:act_seat, act: act_1, seat: seat_3, resale_enabled: true) }
      let!(:act_1_seat_4) { create(:act_seat, act: act_1, seat: seat_4, resale_enabled: true) }

      let!(:act_2_seat_1) { create(:act_seat, act: act_2, seat: seat_1, resale_enabled: true) }
      let!(:act_2_seat_2) { create(:act_seat, act: act_2, seat: seat_2, resale_enabled: true) }
      let!(:act_2_seat_3) { create(:act_seat, act: act_2, seat: seat_3, resale_enabled: true) }
      let!(:act_2_seat_4) { create(:act_seat, act: act_2, seat: seat_4, resale_enabled: true) }

      let!(:act_3_seat_1) { create(:act_seat, act: act_3, seat: seat_1, resale_enabled: true) }
      let!(:act_3_seat_2) { create(:act_seat, act: act_3, seat: seat_2, resale_enabled: true) }
      let!(:act_3_seat_3) { create(:act_seat, act: act_3, seat: seat_3, resale_enabled: true) }
      let!(:act_3_seat_4) { create(:act_seat, act: act_3, seat: seat_4, resale_enabled: true) }

      let!(:act_4_seat_1) { create(:act_seat, act: act_4, seat: seat_1, resale_enabled: true) }
      let!(:act_4_seat_2) { create(:act_seat, act: act_4, seat: seat_2, resale_enabled: true) }
      let!(:act_4_seat_3) { create(:act_seat, act: act_4, seat: seat_3, resale_enabled: true) }
      let!(:act_4_seat_4) { create(:act_seat, act: act_4, seat: seat_4, resale_enabled: true) }

      # ------------------------------------------------------------------------
      # Reception
      # ------------------------------------------------------------------------
      let!(:reception_1) { create(:reception, :having_cover_image, tour:, status: :public, entry_period_ends_at: 3.days.from_now) }
      let!(:reception_2) { create(:reception, :having_cover_image, tour:, status: :public, entry_period_ends_at: 7.days.from_now) }
      let!(:reception_3) { create(:reception, :having_cover_image, tour:, status: :public, entry_period_ends_at: 4.days.from_now) }

      # [ reception 1 ]
      # - act_1 東京公演
      # --- 席種
      let!(:reception_1_act_1_seat_1_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_1_seat_1) }
      let!(:reception_1_act_1_seat_2_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_1_seat_2) }
      let!(:reception_1_act_1_seat_3_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_1_seat_3) }
      let!(:reception_1_act_1_seat_4_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_1_seat_4) }
      # --- 券種
      let!(:reception_1_act_1_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_1_act_seat) }
      let!(:reception_1_act_1_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_2_act_seat) }
      let!(:reception_1_act_1_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_3_act_seat) }
      let!(:reception_1_act_1_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_1_act_1_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_1_act_1_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_1_act_1_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_1_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_2 名古屋公演
      # --- 席種
      let!(:reception_1_act_2_seat_1_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_2_seat_1) }
      let!(:reception_1_act_2_seat_2_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_2_seat_2) }
      let!(:reception_1_act_2_seat_3_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_2_seat_3) }
      let!(:reception_1_act_2_seat_4_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_2_seat_4) }
      # --- 券種
      let!(:reception_1_act_2_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_1_act_seat) }
      let!(:reception_1_act_2_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_2_act_seat) }
      let!(:reception_1_act_2_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_3_act_seat) }
      let!(:reception_1_act_2_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_1_act_2_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_1_act_2_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_1_act_2_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_1_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_3 大阪公演
      # --- 席種
      let!(:reception_1_act_3_seat_1_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_3_seat_1) }
      let!(:reception_1_act_3_seat_2_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_3_seat_2) }
      let!(:reception_1_act_3_seat_3_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_3_seat_3) }
      let!(:reception_1_act_3_seat_4_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_3_seat_4) }
      # --- 券種
      let!(:reception_1_act_3_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_1_act_seat) }
      let!(:reception_1_act_3_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_2_act_seat) }
      let!(:reception_1_act_3_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_3_act_seat) }
      let!(:reception_1_act_3_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_1_act_3_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_1_act_3_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_1_act_3_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_1_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_4 福岡公演
      # --- 席種
      let!(:reception_1_act_4_seat_1_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_4_seat_1) }
      let!(:reception_1_act_4_seat_2_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_4_seat_2) }
      let!(:reception_1_act_4_seat_3_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_4_seat_3) }
      let!(:reception_1_act_4_seat_4_act_seat) { create(:reception_act_seat, reception: reception_1, act_seat: act_4_seat_4) }
      # --- 券種
      let!(:reception_1_act_4_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_1_act_seat) }
      let!(:reception_1_act_4_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_2_act_seat) }
      let!(:reception_1_act_4_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_3_act_seat) }
      let!(:reception_1_act_4_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_1_act_4_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_1_act_4_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_1_act_4_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_1_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }

      let!(:reception_1_fee_1) { create(:reception_fee, reception: reception_1, fee: fee_1) }
      let!(:reception_1_fee_2) { create(:reception_fee, reception: reception_1, fee: fee_2) }
      let!(:reception_1_fee_3) { create(:reception_fee, reception: reception_1, fee: fee_3) }
      let!(:reception_1_fee_4) { create(:reception_fee, reception: reception_1, fee: fee_4) }
      let!(:reception_1_fee_5) { create(:reception_fee, reception: reception_1, fee: fee_5) }
      let!(:reception_1_fee_6) { create(:reception_fee, reception: reception_1, fee: fee_6) }

      # [ reception 2 ]
      # - act_1 東京公演
      # --- 席種
      let!(:reception_2_act_1_seat_1_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_1_seat_1) }
      let!(:reception_2_act_1_seat_2_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_1_seat_2) }
      let!(:reception_2_act_1_seat_3_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_1_seat_3) }
      let!(:reception_2_act_1_seat_4_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_1_seat_4) }
      # --- 券種
      let!(:reception_2_act_1_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_1_act_seat) }
      let!(:reception_2_act_1_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_2_act_seat) }
      let!(:reception_2_act_1_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_3_act_seat) }
      let!(:reception_2_act_1_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_2_act_1_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_2_act_1_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_2_act_1_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_2_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_2 名古屋公演
      # --- 席種
      let!(:reception_2_act_2_seat_1_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_2_seat_1) }
      let!(:reception_2_act_2_seat_2_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_2_seat_2) }
      let!(:reception_2_act_2_seat_3_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_2_seat_3) }
      let!(:reception_2_act_2_seat_4_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_2_seat_4) }
      # --- 券種
      let!(:reception_2_act_2_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_1_act_seat) }
      let!(:reception_2_act_2_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_2_act_seat) }
      let!(:reception_2_act_2_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_3_act_seat) }
      let!(:reception_2_act_2_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_2_act_2_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_2_act_2_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_2_act_2_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_2_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_3 大阪公演
      # --- 席種
      let!(:reception_2_act_3_seat_1_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_3_seat_1) }
      let!(:reception_2_act_3_seat_2_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_3_seat_2) }
      let!(:reception_2_act_3_seat_3_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_3_seat_3) }
      let!(:reception_2_act_3_seat_4_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_3_seat_4) }
      # --- 券種
      let!(:reception_2_act_3_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_1_act_seat) }
      let!(:reception_2_act_3_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_2_act_seat) }
      let!(:reception_2_act_3_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_3_act_seat) }
      let!(:reception_2_act_3_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_2_act_3_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_2_act_3_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_2_act_3_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_2_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_4 福岡公演
      # --- 席種
      let!(:reception_2_act_4_seat_1_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_4_seat_1) }
      let!(:reception_2_act_4_seat_2_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_4_seat_2) }
      let!(:reception_2_act_4_seat_3_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_4_seat_3) }
      let!(:reception_2_act_4_seat_4_act_seat) { create(:reception_act_seat, reception: reception_2, act_seat: act_4_seat_4) }
      # --- 券種
      let!(:reception_2_act_4_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_1_act_seat) }
      let!(:reception_2_act_4_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_2_act_seat) }
      let!(:reception_2_act_4_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_3_act_seat) }
      let!(:reception_2_act_4_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_2_act_4_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_2_act_4_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_2_act_4_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_2_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }

      let!(:reception_2_fee_1) { create(:reception_fee, reception: reception_2, fee: fee_1) }
      let!(:reception_2_fee_2) { create(:reception_fee, reception: reception_2, fee: fee_2) }
      let!(:reception_2_fee_3) { create(:reception_fee, reception: reception_2, fee: fee_3) }
      let!(:reception_2_fee_4) { create(:reception_fee, reception: reception_2, fee: fee_4) }
      let!(:reception_2_fee_5) { create(:reception_fee, reception: reception_2, fee: fee_5) }
      let!(:reception_2_fee_6) { create(:reception_fee, reception: reception_2, fee: fee_6) }

      # [ reception 3 ]
      # - act_1 東京公演
      # --- 席種
      let!(:reception_3_act_1_seat_1_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_1_seat_1) }
      let!(:reception_3_act_1_seat_2_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_1_seat_2) }
      let!(:reception_3_act_1_seat_3_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_1_seat_3) }
      let!(:reception_3_act_1_seat_4_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_1_seat_4) }
      # --- 券種
      let!(:reception_3_act_1_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_1_act_seat) }
      let!(:reception_3_act_1_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_2_act_seat) }
      let!(:reception_3_act_1_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_3_act_seat) }
      let!(:reception_3_act_1_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_3_act_1_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_3_act_1_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_3_act_1_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_3_act_1_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_2 名古屋公演
      # --- 席種
      let!(:reception_3_act_2_seat_1_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_2_seat_1) }
      let!(:reception_3_act_2_seat_2_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_2_seat_2) }
      let!(:reception_3_act_2_seat_3_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_2_seat_3) }
      let!(:reception_3_act_2_seat_4_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_2_seat_4) }
      # --- 券種
      let!(:reception_3_act_2_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_1_act_seat) }
      let!(:reception_3_act_2_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_2_act_seat) }
      let!(:reception_3_act_2_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_3_act_seat) }
      let!(:reception_3_act_2_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_3_act_2_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_3_act_2_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_3_act_2_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_3_act_2_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_3 大阪公演
      # --- 席種
      let!(:reception_3_act_3_seat_1_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_3_seat_1) }
      let!(:reception_3_act_3_seat_2_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_3_seat_2) }
      let!(:reception_3_act_3_seat_3_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_3_seat_3) }
      let!(:reception_3_act_3_seat_4_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_3_seat_4) }
      # --- 券種
      let!(:reception_3_act_3_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_1_act_seat) }
      let!(:reception_3_act_3_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_2_act_seat) }
      let!(:reception_3_act_3_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_3_act_seat) }
      let!(:reception_3_act_3_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_3_act_3_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_3_act_3_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_3_act_3_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_3_act_3_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }
      # act_4 福岡公演
      # --- 席種
      let!(:reception_3_act_4_seat_1_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_4_seat_1) }
      let!(:reception_3_act_4_seat_2_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_4_seat_2) }
      let!(:reception_3_act_4_seat_3_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_4_seat_3) }
      let!(:reception_3_act_4_seat_4_act_seat) { create(:reception_act_seat, reception: reception_3, act_seat: act_4_seat_4) }
      # --- 券種
      let!(:reception_3_act_4_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_1_act_seat) }
      let!(:reception_3_act_4_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_2_act_seat) }
      let!(:reception_3_act_4_seat_3_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_3_act_seat) }
      let!(:reception_3_act_4_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_1) }
      let!(:reception_3_act_4_seat_4_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_2) }
      let!(:reception_3_act_4_seat_4_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_3) }
      let!(:reception_3_act_4_seat_4_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_3_act_4_seat_4_act_seat, seat_plan: seat_4_seat_plan_4) }

      let!(:reception_3_fee_1) { create(:reception_fee, reception: reception_3, fee: fee_1) }
      let!(:reception_3_fee_2) { create(:reception_fee, reception: reception_3, fee: fee_2) }
      let!(:reception_3_fee_3) { create(:reception_fee, reception: reception_3, fee: fee_3) }
      let!(:reception_3_fee_4) { create(:reception_fee, reception: reception_3, fee: fee_4) }
      let!(:reception_3_fee_5) { create(:reception_fee, reception: reception_3, fee: fee_5) }
      let!(:reception_3_fee_6) { create(:reception_fee, reception: reception_3, fee: fee_6) }
    end

    # リセール抽選用のデータセット
    def prepare_resale_lottery_reception_dataset
      T.bind(self, T.untyped)

      let!(:tour) { create(:tour) }

      let!(:fee_1) {
        create(:fee, :single_range, tour:, position: 1, charging_unit: :per_choice, kind: :base, target_name: nil, no_refund: false, single_range_amount: 333, name: 'システム利用料')
      }
      let!(:fee_2) {
        create(:fee, :single_range, tour:, position: 2, charging_unit: :per_ticket, kind: :base, target_name: nil, no_refund: false,
       single_range_amount: 444, name: '特別手数料',)
      }
      let!(:fee_3) {
        create(:fee, :pay_easy_1, tour:, position: 3, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::PayEasyV1.to_s, no_refund: true, name: 'ペイジー手数料')
      }
      let!(:fee_4) {
        create(
          :fee, :konbini_1, tour:, position: 4, charging_unit: :amount_per_instance, kind: :payment, target_name: PaymentCore::KomojuPayment::KonbiniSevenElevenV1.to_s, no_refund: true,
          name: 'コンビニ手数料',
        )
      }
      let!(:fee_5) {
        create(
          :fee, :single_range, tour:, position: 5, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::TapirsSqrcV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'SQRC',
        )
      }
      let!(:fee_6) {
        create(
          :fee, :single_range, tour:, position: 6, charging_unit: :per_ticket, kind: :ticket_reception, target_name: TicketReceptionCore::MoalaTicketV1.to_s, no_refund: false,
          single_range_amount: 148, name: 'MoalaTicket',
        )
      }

      let!(:act_1) { create(:act, tour:, position: 1, name: '東京公演') }
      let!(:act_2) { create(:act, tour:, position: 2, name: '名古屋公演') }
      let!(:act_3) { create(:act, tour:, position: 3, name: '大阪公演') }
      let!(:act_4) { create(:act, tour:, position: 4, name: '福岡公演') }
      let!(:act_5) { create(:act, tour:, position: 5, name: '札幌公演') }
      let!(:resale_act) {
        act_1.update!(resale_period_starts_at: 1.day.ago, resale_period_ends_at: 1.day.from_now)
        act_1
      }

      let!(:seat_1) { create(:seat, :default_seat_plan, tour:, position: 1, name: 'S席', default_seat_plan_price: 22_500) }
      let!(:seat_2) { create(:seat, :default_seat_plan, tour:, position: 2, name: 'A席', default_seat_plan_price: 11_050) }
      let!(:seat_3) { create(:seat, :default_seat_plan, tour:, position: 3, name: 'B席', default_seat_plan_price: 9_760) }
      let!(:seat_4) { create(:seat, :default_seat_plan, tour:, position: 4, name: '立ち見席', default_seat_plan_price: 7_590) }
      let!(:seat_5) { create(:seat,                     tour:, position: 5, name: '親子券') }
      let!(:seat_6) { create(:seat,                     tour:, position: 6, name: 'ファミリー券') }
      let!(:seat_5_seat_plan_1) { create(:seat_plan, seat: seat_5, price: 10_000, name: '大人', position: 1) }
      let!(:seat_5_seat_plan_2) { create(:seat_plan, seat: seat_5, price: 6_500,  name: '子供', position: 2) }
      let!(:seat_6_seat_plan_1) { create(:seat_plan, seat: seat_6, price: 10_000, name: '大人', position: 1) }
      let!(:seat_6_seat_plan_2) { create(:seat_plan, seat: seat_6, price: 8_000,  name: '高校生', position: 2) }
      let!(:seat_6_seat_plan_3) { create(:seat_plan, seat: seat_6, price: 7_000,  name: '中学生', position: 3) }
      let!(:seat_6_seat_plan_4) { create(:seat_plan, seat: seat_6, price: 6_000,  name: '小学生', position: 4) }

      let!(:act_1_seat_1) { create(:act_seat, act: act_1, seat: seat_1, resale_enabled: true) }
      let!(:act_1_seat_2) { create(:act_seat, act: act_1, seat: seat_2, resale_enabled: true) }
      let!(:act_1_seat_4) { create(:act_seat, act: act_1, seat: seat_4, resale_enabled: true) }
      let!(:act_1_seat_5) { create(:act_seat, act: act_1, seat: seat_5, resale_enabled: true) }
      let!(:act_1_seat_6) { create(:act_seat, act: act_1, seat: seat_6, resale_enabled: true) }

      let!(:act_2_seat_1) { create(:act_seat, act: act_2, seat: seat_1, resale_enabled: true) }
      let!(:act_2_seat_4) { create(:act_seat, act: act_2, seat: seat_4, resale_enabled: true) }
      let!(:act_2_seat_6) { create(:act_seat, act: act_2, seat: seat_6, resale_enabled: true) }

      let!(:act_3_seat_1) { create(:act_seat, act: act_3, seat: seat_1, resale_enabled: true) }

      let!(:act_4_seat_1) { create(:act_seat, act: act_4, seat: seat_1, resale_enabled: true) }
      let!(:act_4_seat_3) { create(:act_seat, act: act_4, seat: seat_3, resale_enabled: true) }
      let!(:act_4_seat_2) { create(:act_seat, act: act_4, seat: seat_2, resale_enabled: true) }

      let!(:act_5_seat_2) { create(:act_seat, act: act_5, seat: seat_2, resale_enabled: true) }
      let!(:act_5_seat_5) { create(:act_seat, act: act_5, seat: seat_5, resale_enabled: true) }
      let!(:act_5_seat_6) { create(:act_seat, act: act_5, seat: seat_6, resale_enabled: true) }

      let!(:reception_act_1_seat_1_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_1) }
      let!(:reception_act_1_seat_2_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_2) }
      let!(:reception_act_1_seat_4_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_4) }
      let!(:reception_act_1_seat_5_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_5) }
      let!(:reception_act_1_seat_6_act_seat) { create(:reception_act_seat, reception:, act_seat: act_1_seat_6) }

      let!(:reception_act_1_seat_1_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_1_act_seat) }
      let!(:reception_act_1_seat_2_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_2_act_seat) }
      let!(:reception_act_1_seat_4_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_4_act_seat) }
      let!(:reception_act_1_seat_5_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_5_act_seat, seat_plan: seat_5_seat_plan_1) }
      let!(:reception_act_1_seat_5_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_5_act_seat, seat_plan: seat_5_seat_plan_2) }
      let!(:reception_act_1_seat_6_seat_plan_1) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_6_act_seat, seat_plan: seat_6_seat_plan_1) }
      let!(:reception_act_1_seat_6_seat_plan_2) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_6_act_seat, seat_plan: seat_6_seat_plan_2) }
      let!(:reception_act_1_seat_6_seat_plan_3) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_6_act_seat, seat_plan: seat_6_seat_plan_3) }
      let!(:reception_act_1_seat_6_seat_plan_4) { create(:reception_seat_plan, reception_act_seat: reception_act_1_seat_6_act_seat, seat_plan: seat_6_seat_plan_4) }

      let!(:reception_fee_1) { create(:reception_fee, reception:, fee: fee_1) }
      let!(:reception_fee_2) { create(:reception_fee, reception:, fee: fee_2) }
      let!(:reception_fee_3) { create(:reception_fee, reception:, fee: fee_3) }
      let!(:reception_fee_4) { create(:reception_fee, reception:, fee: fee_4) }
      let!(:reception_fee_5) { create(:reception_fee, reception:, fee: fee_5) }
      let!(:reception_fee_6) { create(:reception_fee, reception:, fee: fee_6) }
    end
  end
end
