import type { AccountInterface } from 'starknet'

type StarknetProvider = {
  enable: (options?: { showModal?: boolean }) => Promise<string[]>
  account?: AccountInterface
  isConnected?: boolean
  selectedAddress?: string
}

declare global {
  interface Window {
    starknet?: StarknetProvider
  }
}

export {}
