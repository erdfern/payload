// import { stripeCheckoutAdapter } from '@/lib/payments/adapters/stripe-checkout'

import { adminOnlyFieldAccess } from '@/access/adminOnlyFieldAccess'
import { adminOrPublishedStatus } from '@/access/adminOrPublishedStatus'
import { customerOnlyFieldAccess } from '@/access/customerOnlyFieldAccess'
import { isAdmin } from '@/access/isAdmin'
import { isAdminOrDocumentOwner } from '@/access/isDocumentOwner'
import { ProductsCollection } from '@/collections/Products'
import { ecommercePlugin, EUR } from '@payloadcms/plugin-ecommerce'
import { stripeAdapter } from '@payloadcms/plugin-ecommerce/payments/stripe'
import type { Plugin } from 'payload'

export const ecommercePluginConfig: Plugin = ecommercePlugin({
  access: {
    isAdmin,
    isDocumentOwner: isAdminOrDocumentOwner,
    adminOnlyFieldAccess,
    adminOrPublishedStatus,
    customerOnlyFieldAccess,
  },
  customers: { slug: 'users' },
  currencies: {
    defaultCurrency: EUR.code,
    // supportedCurrencies: [EUR, GBP, USD],
    supportedCurrencies: [EUR],
  },
  payments: {
    paymentMethods: [
      //   stripeCheckoutAdapter({
      //     appInfo: {
      //       name: 'BRUNO Stripe Checkout Payload Plugin',
      //     },
      //     secretKey: process.env.STRIPE_SECRET_KEY,
      //     publishableKey: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY,
      //     webhookSecret: process.env.STRIPE_WEBHOOKS_SIGNING_SECRET,
      //     label: 'Stripe Checkout',
      //     // groupOverrides: { }
      //   }),
      stripeAdapter({
        appInfo: { name: 'BRUNO Stripe Payload Plugin' },
        secretKey: process.env.STRIPE_SECRET_KEY!,
        publishableKey: process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY!,
        webhookSecret: process.env.STRIPE_WEBHOOKS_SIGNING_SECRET,
        label: 'Stripe',
        // NOTE: api/payments/stripe/webhooks
        // can't use defineStripeWebhooks approach here, since it's using different types?? and doesn't even export them
        webhooks: {
          'product.created': ({ event, req, stripe }) => {
            // event is Stripe.ProductCreatedEvent here
            req.payload.logger.debug(event)
            req.payload.logger.debug(stripe.products.list())
          },
          'product.updated': ({ event, req, stripe }) => {
            // event is Stripe.ProductUpdatedEvent
            req.payload.logger.debug(event)
            req.payload.logger.debug(stripe.products.list())
          },
        },
      }),
    ],
  },
  products: {
    productsCollectionOverride: ProductsCollection,
  },
  transactions: {
    transactionsCollectionOverride: ({ defaultCollection }) => ({
      ...defaultCollection,
      fields: [
        ...defaultCollection.fields,
        {
          name: 'notes',
          label: 'Notes',
          type: 'textarea',
        },
      ],
    }),
  },
})
