module AuthAPIHelper
  extend ActiveSupport::Concern

  included do
    let(:tenant_idp) { create(:tenant, id: :utadahikaru, name: 'Utada Hikaru') }
    let(:tenant_adapter) { create(:tenant, id: :kenshiyonezu, name: 'Kenshi Yonezu') }

    let(:idp_user) {
      {
        uid: 'uid-of-idp',
        profile: {
          first_name: 'JohnIDP',
          last_name: 'SmithIDP',
          first_name_kana: 'ジョンIDP',
          last_name_kana: 'スミスIDP',
          birth_date: '2002-08-12',
          gender: '-1',
        },
        contact_address: {
          zip_code: '3050005',
          country_code: '',
          prefecture: '茨城県',
          city: 'つくば市',
          street: '天久保a',
          building: 'hjfkdgIDP',
        },
        email: 'keiya@twogate.com',
        phone_number: '00123456781',
        extra: {
          a: 'b',
          c: {
            d: 123,
          },
        },
      }
    }

    let(:idp_id_token) {
      JWT.encode({
        iss: 'auth-platform',
        sub: 'uid-of-idp',
        aud: idp_oauth_provider_user.client_id,
        exp: 9999999999, # rubocop:disable Style/NumericLiterals
        iat: Time.now.to_i,
        user: idp_user,
      }, idp_rsa_private, 'RS256', { kid: 'kid' },)
    }

    # rubocop:disable Layout/LineLength
    let(:idp_api_double) do
      instance_double(
        AuthAPI::IdPlatform,
        fetch_jwks: {
          keys: [
            {
              kty: 'RSA',
              n:
              'y4CKYzWBNX26n9ShJNX0jT4zZExSDsRVlYnt9GxAjBwQ73ZdgbP0kfLm1oKjWgAKfN18K_iFWw09sKdk8m7Pcto9s8o0_iLMTPyAKYZeEohlioxXyZtWEqZ6X2Hgw8SsM5E6VAUBUpAtembAn7bL4NqLCHg0i-AsCTV9KtgezB7ohB02jb-0-r2V5GVG4c82eXuzjGoAbYgAXSzYhTpHaZkATW5Nr8fx8Q4SEniXlPKNh14pHNRNxsHPLIa2vsN3nMglEis9E0noq1ChQZWwBotarlUBnpDp7ot30TWUJdZs7xCXHW4mthytLGanfENQaJ9ScUPl523YWqkiejQuVQ',
              e: 'AQAB',
              kid: 'kid',
              use: 'sig',
              alg: 'RS256',
            },
          ],
        },
        fetch_access_token: {
          'access_token' => 'yeah',
          'expires_in' => 31_536_000,
        },
        fetch_user: idp_user.deep_stringify_keys,
      )
    end
    # rubocop:enable Layout/LineLength

    let(:idp_rsa_private) {
      # copied from auth-platform's dev signing key
      key = <<~KEY
        -----BEGIN PRIVATE KEY-----
        MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDLgIpjNYE1fbqf
        1KEk1fSNPjNkTFIOxFWVie30bECMHBDvdl2Bs/SR8ubWgqNaAAp83Xwr+IVbDT2w
        p2Tybs9y2j2zyjT+IsxM/IAphl4SiGWKjFfJm1YSpnpfYeDDxKwzkTpUBQFSkC16
        ZsCftsvg2osIeDSL4CwJNX0q2B7MHuiEHTaNv7T6vZXkZUbhzzZ5e7OMagBtiABd
        LNiFOkdpmQBNbk2vx/HxDhISeJeU8o2HXikc1E3Gwc8shra+w3ecyCUSKz0TSeir
        UKFBlbAGi1quVQGekOnui3fRNZQl1mzvEJcdbia2HK0sZqd8Q1Bon1JxQ+Xnbdha
        qSJ6NC5VAgMBAAECggEAJyWH+YOuYlrYTqy5fvuFerIvcqjX1C1ihUyuMKmuVQWF
        IHt1i2DRuE2wqC0jPUnqupBktZSuGpDWgCgDXDuCvoZK/k30mbqZ8GlWQiat7AS+
        +8L5lDfEe/v4aGbMtPwdYCIcxVLdKUPA693eShsA5zVDL5LoEMxDzFW0yUwfyIYF
        TGbeOoSblPzTbi66LhLF7r76QHmk6ErYxwBon0Z30ar0i+H5oCCgLiPmncSeZXOV
        M/XBmqJyTt7o7YaqXpFTKV+iGDwQFysvRQ6D9ql2gblc39pCSZm99JMtnCg2yVIE
        GyvVwoBzO1WiWp/B5jOvDfCUvK637TsBeRTbH4WL4QKBgQD9QCBjfIDq/cN+NH2q
        M7hmJYq923jk4CZR258P+ZCxm3wLWYfTtZ++b0XOVVpSuzIniD4NEPCnJofi3KTV
        a/GiCpK0NXOyBCfZi9KowNIZ1apkQlVlTP4kwo0auZhn8eCx0sp3ZFHpCjPmwiOc
        Ik6xggNbyA/O0K8bNZ4n2/iuvQKBgQDNtiVC94VKQA9tA3YiPOIUGXDjggli1Agh
        R5iib/FTMrbp+GsBLHNJhguA2MU+Sk8jOAYv+qspBpXVPEEorLio/CFEb1g9XOuh
        LjK3Mdh1QCGgKCcfpD06spSLXPvCjzMWZzmoRnpIw1hnihRUWlmOuXSoRhRrpRKM
        aHkYYRjjeQKBgFeQSKKddeXKgEGu3JRw9Z079dDXheF9L0K2cTUQ0VrXq/gwqKom
        7mjmCHjjQivA1gKdNPdHmC3zQKDMMaIphI7GoRr2MF6o2S57DgeTRBHyssufs+8m
        w+jp6+gFrBCkrVBO1fqaEUhGYtOy5KUjp5nwnkCp1+1mcmUyENEvWbjxAoGBAJr4
        yYF1rziMohJiNTD95ON3dxAt+pw1WBqaMWbOJmOjJSGGQDaWIhQVo7zhkVan7I5/
        ukmS8jbp+x61UfEujb7gkr9XkoZH5kt63kIcjxFlyu840KCJvobl2fpThmbAMqCC
        C3G2BpGieIsn/sC9gBKBrFzIzsF5jkuwuOmg3HshAoGABuOJYVHD8SFQdVaQ4Boa
        F8k0KT1nEvV2NlyDrZ5P/Xo9AsBEf27rCtW6cCGGj/jkuRj8fXNni7w73IMLlOjH
        qIt0tZn+v1A39hqFyGwX3EiICNIdXR2iiwMUrGBehY+xyxBpaoARir6FqiC7WIRT
        DXZvXueNX6kUAiQxjfFxduI=
        -----END PRIVATE KEY-----
      KEY
      OpenSSL::PKey::RSA.new(key)
    }

    let(:idp_oauth_provider_admin) { create(:oauth_provider, tenant: tenant_idp, name: nil, kind: 'admin', client_id: 'idpadmin', client_secret: 'asdf') }
    let(:idp_oauth_provider_user) { create(:oauth_provider, tenant: tenant_idp, name: 'idp', kind: 'user', client_id: 'idpuser', client_secret: 'asdf') }

    let(:adapter_user) {
      {
        uid: 'uid-of-adapter',
        first_name: 'JohnAdapter',
        last_name: 'SmithAdapter',
        first_name_pron: 'ジョンAdapter',
        last_name_pron: 'スミスAdapter',
        email: 'keiya+adapter@twogate.com',
        phone_number: '0012345678',
        birthdate: '2001-01-11',
        gender: '1',
        zip_code: '1550033',
        prefecture: '東京都',
        city: '世田谷区',
        address_1: '代田',
        address_2: 'スーパーYEAHビル',
        id_provider: nil,
        member_rank: 100,
        extra: {
          a: 'b',
          c: {
            d: 123,
          },
        },
      }
    }

    let(:adapter_api_double) do
      instance_double(
        AuthAPI::Adapter,
        fetch_access_token: {
          'access_token' => 'yeah',
          'expires_in' => 31_536_000,
        },
        fetch_user: adapter_user.deep_stringify_keys,
      )
    end

    let(:adapter_oauth_provider_admin) {
      create(
        :oauth_provider,
        tenant: tenant_adapter,
        name: nil,
        kind: 'admin',
        client_id: 'adapteradmin',
        client_secret: 'asdf',
        endpoint_base: 'https://auth-adapter.t-riple.com',
      )
    }
    let(:adapter_oauth_provider_user) {
      create(
        :oauth_provider,
        tenant: tenant_adapter,
        name: 'adapter/bnid',
        kind: 'user',
        endpoint_base: 'https://auth-adapter.t-riple.com',
        jwt_iss: 'auth-adapter.t-riple.com',
        jwt_public_key: 'SxHgzA8UH+5ZNP+y10Z4MJUYa9x8xvWL5BhhYby8Zow=',
      )
    }

    before do
      allow(AuthAPI::IdPlatform).to receive(:new).and_return(idp_api_double)
      allow(AuthAPI::Adapter).to receive(:new).and_return(adapter_api_double)
    end
  end
end
