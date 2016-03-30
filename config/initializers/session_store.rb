# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, {
  key: '_caos_session',
  expire_after: 6.hours,
}
