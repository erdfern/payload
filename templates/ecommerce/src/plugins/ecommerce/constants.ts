import { EUR } from '@payloadcms/plugin-ecommerce'
import type { CurrenciesConfig } from '@payloadcms/plugin-ecommerce/types'

// const EUR_CURRENCY: Currency = { code: 'EUR', decimals: 2, label: 'Euro', symbol: '€' }
// const USD_CURRENCY: Currency = { code: 'USD', decimals: 2, label: 'US Dollar', symbol: '$' }
export const CURRENCIES_CONFIG: CurrenciesConfig = {
  defaultCurrency: EUR.code,
  // supportedCurrencies: [EUR, GBP, USD],
  supportedCurrencies: [EUR],
}
