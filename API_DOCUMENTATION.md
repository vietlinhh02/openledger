# OpenLedger API Documentation

## Overview

OpenLedger is a Node.js automation tool for managing multiple wallet accounts on the OpenLedger platform. It provides functionality for authentication, WebSocket connections, heartbeat management, job processing, and reward claiming with proxy support.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Core Classes](#core-classes)
- [Utility Functions](#utility-functions)
- [Utilities](#utilities)
- [API Endpoints](#api-endpoints)
- [Usage Examples](#usage-examples)

## Installation

```bash
npm install
```

### Dependencies

- `axios` ^1.7.9 - HTTP client
- `axios-retry` ^4.5.0 - Request retry logic
- `chalk` ^5.4.1 - Terminal styling
- `crypto` ^1.0.1 - Cryptographic functionality
- `ethers` ^6.13.5 - Ethereum utilities
- `https-proxy-agent` ^7.0.6 - HTTP proxy support
- `socks-proxy-agent` ^8.0.5 - SOCKS proxy support
- `ws` ^8.18.0 - WebSocket client

## Configuration

### Required Files

1. **wallets.txt** - One wallet address per line
2. **proxy.txt** - One proxy URL per line (optional)

### Proxy Format Support
- HTTP: `http://username:password@host:port`
- SOCKS4: `socks4://username:password@host:port`
- SOCKS5: `socks5://username:password@host:port`

## Core Classes

### WebSocketClient

Main class for managing WebSocket connections to OpenLedger.

#### Constructor

```javascript
new WebSocketClient(authToken, address, proxy, index)
```

**Parameters:**
- `authToken` (string): Authentication token for the connection
- `address` (string): Wallet address
- `proxy` (string|null): Proxy URL or null for direct connection
- `index` (number): Account index for logging purposes

**Properties:**
- `url` (string): WebSocket endpoint URL
- `ws` (WebSocket): WebSocket connection instance
- `reconnect` (boolean): Auto-reconnection flag
- `registered` (boolean): Worker registration status
- `identity` (string): Base64 encoded wallet address
- `capacity` (object): Generated worker capacity
- `id` (string): Unique worker ID

#### Methods

##### connect()

Establishes WebSocket connection and handles events.

```javascript
webSocketClient.connect()
```

**Features:**
- Automatic worker registration
- Heartbeat mechanism (30-second intervals)
- Automatic reconnection on connection loss
- Job processing capability

**Events Handled:**
- `open`: Connection established, starts registration and heartbeat
- `message`: Incoming message processing and job handling
- `error`: Error logging
- `close`: Cleanup and reconnection logic

##### sendMessage(message)

Sends JSON message through WebSocket connection.

```javascript
webSocketClient.sendMessage(message)
```

**Parameters:**
- `message` (object): Message object to send

**Example:**
```javascript
webSocketClient.sendMessage({
    type: "HEARTBEAT",
    data: { status: "active" }
})
```

##### close()

Closes WebSocket connection and disables reconnection.

```javascript
webSocketClient.close()
```

##### loadJobData(event)

Handles incoming job assignments and sends acknowledgment.

```javascript
webSocketClient.loadJobData(event)
```

**Parameters:**
- `event` (object): WebSocket message event containing job data

## Utility Functions

### readFile(pathFile)

Reads and parses text files with line-based data.

```javascript
const data = readFile("wallets.txt")
```

**Parameters:**
- `pathFile` (string): Path to the file

**Returns:**
- `Array<string>`: Array of trimmed, non-empty lines

**Example:**
```javascript
const wallets = readFile("wallets.txt")
// Returns: ["0x1234...", "0x5678...", "0x9abc..."]
```

### newAgent(proxy)

Creates appropriate proxy agent based on proxy URL protocol.

```javascript
const agent = newAgent("http://proxy.example.com:8080")
```

**Parameters:**
- `proxy` (string|null): Proxy URL or null

**Returns:**
- `HttpsProxyAgent|SocksProxyAgent|null`: Appropriate proxy agent or null

**Supported Protocols:**
- HTTP/HTTPS proxies
- SOCKS4/SOCKS5 proxies

### generateToken(data, proxy)

Generates authentication token from wallet address.

```javascript
const tokenData = await generateToken({ address: "0x1234..." }, proxy)
```

**Parameters:**
- `data` (object): Object containing wallet address
  - `address` (string): Wallet address
- `proxy` (string|null): Proxy URL

**Returns:**
- `Promise<object|null>`: Token data object or null on failure

**Response Format:**
```javascript
{
    token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    // ... other token data
}
```

### getUserInfo(token, proxy, index)

Retrieves user information and daily points.

```javascript
const userInfo = await getUserInfo(token, proxy, 1)
```

**Parameters:**
- `token` (string): Authentication token
- `proxy` (string|null): Proxy URL
- `index` (number): Account index for logging

**Returns:**
- `Promise<object|string|null>`: User data, 'unauthorized' string, or null

**Response Format:**
```javascript
[{
    total_heartbeats: "150",
    // ... other user data
}]
```

### getClaimDetails(token, proxy, index)

Retrieves reward claim information.

```javascript
const claimDetails = await getClaimDetails(token, proxy, 1)
```

**Parameters:**
- `token` (string): Authentication token
- `proxy` (string|null): Proxy URL
- `index` (number): Account index for logging

**Returns:**
- `Promise<object|null>`: Claim details or null

**Response Format:**
```javascript
{
    tier: "Bronze",
    dailyPoint: 100,
    claimed: false,
    nextClaim: "2024-01-01T00:00:00Z"
}
```

### claimRewards(token, proxy, index)

Claims daily rewards for the account.

```javascript
const claimResult = await claimRewards(token, proxy, 1)
```

**Parameters:**
- `token` (string): Authentication token
- `proxy` (string|null): Proxy URL
- `index` (number): Account index for logging

**Returns:**
- `Promise<object|null>`: Claim result or null

### generateRandomCapacity()

Generates random worker capacity for WebSocket registration.

```javascript
const capacity = generateRandomCapacity()
```

**Returns:**
- `object`: Random capacity configuration

**Response Format:**
```javascript
{
    AvailableMemory: 32.45,
    AvailableStorage: "250.75",
    AvailableGPU: "",
    AvailableModels: []
}
```

## Utilities

### Logger (utils/logger.js)

Enhanced logging utility with colored output and timestamps.

#### Methods

##### log(level, message, value)

Base logging method with level-specific formatting.

```javascript
logger.log('info', 'Connection established', { status: 'success' })
```

**Parameters:**
- `level` (string): Log level ('info', 'warn', 'error', 'success', 'debug')
- `message` (string): Log message
- `value` (any): Optional value to log

##### info(message, value)

Logs informational messages in green.

```javascript
logger.info('Processing account', 1)
logger.info('User data', { points: 150 })
```

##### warn(message, value)

Logs warning messages in yellow.

```javascript
logger.warn('Connection lost, reconnecting...')
```

##### error(message, value)

Logs error messages in red.

```javascript
logger.error('Failed to generate token', error.message)
```

##### success(message, value)

Logs success messages in blue.

```javascript
logger.success('Rewards claimed successfully', { amount: 100 })
```

##### debug(message, value)

Logs debug messages in magenta.

```javascript
logger.debug('WebSocket message received', messageData)
```

**Output Format:**
```
[ OpenLedger ] [ 2024-01-01 12:00:00 ] [ INFO ] Processing account 1
```

### Banner (utils/banner.js)

Simple banner display for application startup.

```javascript
import banner from './utils/banner.js'
console.log(banner)
```

**Output:**
```
                        Running Open-Ledger CLI Version                
                 t.me/zlkcybergroup *** github.com/vietlinhh02
```

## API Endpoints

### Authentication

**POST** `https://apitn.openledger.xyz/api/v1/auth/generate_token`

Generates authentication token for wallet address.

**Request Body:**
```javascript
{
    address: "0x1234567890abcdef..."
}
```

### User Information

**GET** `https://rewardstn.openledger.xyz/api/v1/reward_realtime`

Retrieves real-time reward information.

**Headers:**
```javascript
{
    "Authorization": "Bearer <token>"
}
```

### Claim Details

**GET** `https://rewardstn.openledger.xyz/api/v1/claim_details`

Retrieves claim status and details.

### Claim Rewards

**GET** `https://rewardstn.openledger.xyz/api/v1/claim_reward`

Claims available daily rewards.

### WebSocket

**WSS** `wss://apitn.openledger.xyz/ws/v1/orch?authToken=<token>`

WebSocket endpoint for real-time communication.

## Usage Examples

### Basic Usage

```javascript
import { WebSocketClient } from './main.js'

// Create and connect WebSocket client
const client = new WebSocketClient(
    "your-auth-token",
    "0x1234567890abcdef...",
    "http://proxy.example.com:8080",
    1
)

client.connect()
```

### Generate Token and Connect

```javascript
import { generateToken, WebSocketClient } from './main.js'

const address = "0x1234567890abcdef..."
const proxy = "http://proxy.example.com:8080"

// Generate authentication token
const tokenData = await generateToken({ address }, proxy)
if (tokenData?.token) {
    // Create WebSocket client
    const client = new WebSocketClient(tokenData.token, address, proxy, 1)
    client.connect()
}
```

### Check and Claim Rewards

```javascript
import { getClaimDetails, claimRewards } from './main.js'

const token = "your-auth-token"
const proxy = "http://proxy.example.com:8080"

// Check claim status
const claimDetails = await getClaimDetails(token, proxy, 1)
if (claimDetails && !claimDetails.claimed) {
    // Claim rewards if available
    const result = await claimRewards(token, proxy, 1)
    console.log('Rewards claimed:', result)
}
```

### Using Logger

```javascript
import log from './utils/logger.js'

// Different log levels
log.info('Application started')
log.warn('Connection unstable')
log.error('Failed to connect', error.message)
log.success('Operation completed', { result: 'success' })
log.debug('Debug information', debugData)
```

### File Operations

```javascript
import { readFile } from './main.js'

// Read wallet addresses
const wallets = readFile('wallets.txt')
console.log(`Loaded ${wallets.length} wallets`)

// Read proxy list
const proxies = readFile('proxy.txt')
console.log(`Loaded ${proxies.length} proxies`)
```

### Error Handling

```javascript
try {
    const tokenData = await generateToken({ address }, proxy)
    if (!tokenData?.token) {
        throw new Error('Failed to generate token')
    }
    
    const userInfo = await getUserInfo(tokenData.token, proxy, 1)
    if (userInfo === 'unauthorized') {
        throw new Error('Token expired or invalid')
    }
    
} catch (error) {
    log.error('Operation failed:', error.message)
}
```

## Running the Application

```bash
# Start the application
npm start

# Or run directly
node main.js
```

The application will:
1. Read wallet addresses from `wallets.txt`
2. Read proxy list from `proxy.txt` (optional)
3. Generate tokens for each wallet
4. Establish WebSocket connections
5. Start heartbeat and job processing
6. Automatically claim daily rewards
7. Provide real-time logging and status updates

## Signal Handling

The application gracefully handles process signals:

- **SIGINT** (Ctrl+C): Cleanup and exit
- **SIGTERM**: Graceful shutdown

## Automatic Features

- **Token Refresh**: Automatic token regeneration on expiration
- **Reconnection**: Automatic WebSocket reconnection on disconnection
- **Heartbeat**: 30-second interval heartbeat messages
- **Reward Claiming**: Automatic daily reward claiming
- **User Info**: 10-minute interval user information updates
- **Claim Check**: 60-minute interval claim status checks

## Error Handling

The application includes comprehensive error handling:

- Network timeouts and retries (3 attempts with exponential backoff)
- Token expiration detection and refresh
- WebSocket connection failures and reconnection
- Proxy connection issues
- File reading errors
- API response validation

## Logging

All operations are logged with timestamps, color coding, and detailed information:

- **Info** (Green): Normal operations
- **Warn** (Yellow): Non-critical issues
- **Error** (Red): Failures and exceptions
- **Success** (Blue): Successful operations
- **Debug** (Magenta): Debug information