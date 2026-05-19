import { useMemo, useState } from 'react'
import { Contract, RpcProvider } from 'starknet'
import hashVerifierAbi from './abi/hash_verifier.json'
import './App.css'

const DEFAULT_RPC = 'http://127.0.0.1:5050'

const formatValue = (value: unknown): string => {
  if (typeof value === 'string') {
    return value
  }
  if (typeof value === 'bigint') {
    return `0x${value.toString(16)}`
  }
  if (Array.isArray(value) && value.length > 0) {
    return formatValue(value[0])
  }
  if (value && typeof value === 'object' && 'toString' in value) {
    return (value as { toString: () => string }).toString()
  }
  return String(value)
}

const toBoolLabel = (value: unknown): string => {
  if (value === true || value === 1 || value === 1n) {
    return 'PASS'
  }
  if (typeof value === 'string' && (value === '1' || value === '0x1')) {
    return 'PASS'
  }
  if (Array.isArray(value) && value.length > 0) {
    return toBoolLabel(value[0])
  }
  return 'FAIL'
}

const parseAge = (value: string): bigint => {
  const trimmed = value.trim()
  if (!trimmed) {
    return 0n
  }
  const parsed = Number(trimmed)
  if (!Number.isInteger(parsed) || parsed < 0) {
    throw new Error('Age must be a non-negative integer')
  }
  return BigInt(parsed)
}

function App() {
  const [rpcUrl, setRpcUrl] = useState(DEFAULT_RPC)
  const [contractAddress, setContractAddress] = useState('')
  const [status, setStatus] = useState('Idle')
  const [accountAddress, setAccountAddress] = useState('')
  const [adminAddress, setAdminAddress] = useState('')
  const [storeUser, setStoreUser] = useState('')
  const [storeAge, setStoreAge] = useState('25')
  const [readUser, setReadUser] = useState('')
  const [storedHash, setStoredHash] = useState('')
  const [verifyAge, setVerifyAge] = useState('25')
  const [verifyResult, setVerifyResult] = useState('')
  const [walletConnected, setWalletConnected] = useState(false)

  const provider = useMemo(() => new RpcProvider({ nodeUrl: rpcUrl }), [rpcUrl])
  const readOptions = useMemo(() => ({ blockIdentifier: 'latest' as const }), [])

  const getReadContract = () => {
    if (!contractAddress.trim()) {
      throw new Error('Contract address is required')
    }
    return new Contract(hashVerifierAbi as never, contractAddress.trim(), provider)
  }

  const getWriteContract = () => {
    if (!contractAddress.trim()) {
      throw new Error('Contract address is required')
    }
    if (!window.starknet?.account) {
      throw new Error('Wallet not connected')
    }
    return new Contract(
      hashVerifierAbi as never,
      contractAddress.trim(),
      window.starknet.account,
    )
  }

  const connectWallet = async () => {
    try {
      if (!window.starknet) {
        setStatus('No StarkNet wallet detected')
        return
      }
      const accounts = await window.starknet.enable({ showModal: true })
      const address = accounts[0] ?? window.starknet.selectedAddress ?? ''
      setAccountAddress(address)
      setWalletConnected(Boolean(address))
      setStatus(address ? 'Wallet connected' : 'Wallet connection cancelled')
    } catch (error) {
      setStatus(`Wallet error: ${(error as Error).message}`)
    }
  }

  const loadAdmin = async () => {
    try {
      setStatus('Fetching admin...')
      const contract = getReadContract()
      const admin = await contract.call('get_admin', [], readOptions)
      setAdminAddress(formatValue(admin))
      setStatus('Admin loaded')
    } catch (error) {
      setStatus(`Admin error: ${(error as Error).message}`)
    }
  }

  const storeHash = async () => {
    try {
      setStatus('Sending store transaction...')
      const contract = getWriteContract()
      const targetUser = storeUser.trim() || accountAddress
      if (!targetUser) {
        throw new Error('User address is required')
      }
      const ageValue = parseAge(storeAge)
      const response = await contract.invoke('store_hash', [targetUser, ageValue])
      await provider.waitForTransaction(response.transaction_hash)
      setStatus('Hash stored successfully')
    } catch (error) {
      setStatus(`Store error: ${(error as Error).message}`)
    }
  }

  const readHash = async () => {
    try {
      setStatus('Reading stored hash...')
      const contract = getReadContract()
      const targetUser = readUser.trim() || accountAddress
      if (!targetUser) {
        throw new Error('User address is required')
      }
      const result = await contract.call('get_hash', [targetUser], readOptions)
      setStoredHash(formatValue(result))
      setStatus('Hash loaded')
    } catch (error) {
      setStatus(`Read error: ${(error as Error).message}`)
    }
  }

  const verifyCall = async () => {
    try {
      setStatus('Calling verify_hash...')
      const contract = getReadContract()
      if (!accountAddress) {
        throw new Error('Wallet not connected')
      }
      const ageValue = parseAge(verifyAge)
      const result = await contract.call(
        'verify_hash_for',
        [accountAddress, ageValue],
        readOptions,
      )
      setVerifyResult(toBoolLabel(result))
      setStatus('Verification complete')
    } catch (error) {
      setStatus(`Verify error: ${(error as Error).message}`)
    }
  }

  const verifyTx = async () => {
    try {
      setStatus('Sending verify transaction...')
      const contract = getWriteContract()
      const ageValue = parseAge(verifyAge)
      const response = await contract.invoke('verify_hash', [ageValue])
      await provider.waitForTransaction(response.transaction_hash)
      await verifyCall()
      setStatus('Verify transaction confirmed')
    } catch (error) {
      setStatus(`Verify tx error: ${(error as Error).message}`)
    }
  }

  return (
    <div className="app">
      <header className="hero">
        <div>
          <p className="eyebrow">StarkNet Devnet Frontend</p>
          <h1>Hash Verifier Console</h1>
        </div>
        <div className="status">
          <span>Status</span>
          <strong>{status}</strong>
        </div>
      </header>

      <section className="grid">
        <div className="panel">
          <h2>Connection</h2>
          <label className="field">
            RPC URL
            <input
              value={rpcUrl}
              onChange={(event) => setRpcUrl(event.target.value)}
              placeholder="http://127.0.0.1:5050"
            />
          </label>
          <label className="field">
            Contract Address
            <input
              value={contractAddress}
              onChange={(event) => setContractAddress(event.target.value)}
              placeholder="0x..."
            />
          </label>
          <div className="row">
            <button className="primary" type="button" onClick={connectWallet}>
              {walletConnected ? 'Wallet Connected' : 'Connect Wallet'}
            </button>
            <button className="ghost" type="button" onClick={loadAdmin}>
              Load Admin
            </button>
          </div>
          <div className="hint">
            <div>
              <span>Wallet</span>
              <strong>{accountAddress || 'Not connected'}</strong>
            </div>
            <div>
              <span>Admin</span>
              <strong>{adminAddress || 'Not loaded'}</strong>
            </div>
          </div>
        </div>

        <div className="panel">
          <h2>Store Hash (Admin)</h2>
          <label className="field">
            Target User Address
            <input
              value={storeUser}
              onChange={(event) => setStoreUser(event.target.value)}
              placeholder="Defaults to connected wallet"
            />
          </label>
          <label className="field">
            Age
            <input
              type="number"
              min="0"
              value={storeAge}
              onChange={(event) => setStoreAge(event.target.value)}
            />
          </label>
          <button className="primary" type="button" onClick={storeHash}>
            Store Hash
          </button>
          <p className="note">
            Only the admin can store. The hash is calculated inside the contract.
          </p>
        </div>

        <div className="panel">
          <h2>Read Stored Hash</h2>
          <label className="field">
            User Address
            <input
              value={readUser}
              onChange={(event) => setReadUser(event.target.value)}
              placeholder="Defaults to connected wallet"
            />
          </label>
          <button className="ghost" type="button" onClick={readHash}>
            Get Hash
          </button>
          <div className="result">
            <span>Stored Hash</span>
            <strong>{storedHash || '—'}</strong>
          </div>
        </div>

        <div className="panel">
          <h2>Verify Age</h2>
          <label className="field">
            Age to Verify
            <input
              type="number"
              min="0"
              value={verifyAge}
              onChange={(event) => setVerifyAge(event.target.value)}
            />
          </label>
          <div className="row">
            <button className="ghost" type="button" onClick={verifyCall}>
              Verify (Call)
            </button>
            <button className="primary" type="button" onClick={verifyTx}>
              Verify (Tx)
            </button>
          </div>
          <div className="result">
            <span>Result</span>
            <strong>{verifyResult || '—'}</strong>
          </div>
        </div>
      </section>
    </div>
  )
}

export default App
