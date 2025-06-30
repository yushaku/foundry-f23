import { expect, test, describe, beforeEach, beforeAll } from 'bun:test';
import MerkleTree from 'merkletreejs';
import {
  keccak256,
  encodePacked,
  Address,
  createWalletClient,
  http,
  createPublicClient,
  defineChain,
  getContract,
} from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import {
  abi as MerkleAirdropAbi,
  bytecode as MerkleAirdropBytecode,
} from '../out/MerkleAirdrop.sol/MerkleAirdrop.json';

const localChain = defineChain({
  id: 31337,
  name: 'Localhost',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: ['http://127.0.0.1:8545'] },
  },
});

export const account = privateKeyToAccount(
  '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80',
);

export const walletClient = createWalletClient({
  chain: localChain,
  transport: http('http://127.0.0.1:8545'),
  account,
});

export const client = createPublicClient({
  chain: localChain,
  transport: http('http://127.0.0.1:8545'),
});

function getLeaf({ address, amount }: { address: Address; amount: bigint }) {
  return keccak256(encodePacked(['address', 'uint256'], [address, amount]), 'hex');
}

function createMerkleTree(accounts: { address: Address; amount: bigint }[]) {
  const leaves = accounts.map(getLeaf);
  return new MerkleTree(leaves, keccak256, { sortPairs: true });
}

function getProof(tree: MerkleTree, account: { address: Address; amount: bigint }) {
  const leaf = getLeaf(account);
  return tree.getHexProof(leaf);
}

describe('Merkle Tree', () => {
  let contact: any;

  beforeAll(async () => {
    const balance = await client.getBalance({ address: account.address });
    console.log('Account balance:', balance);

    const data: any = {
      abi: MerkleAirdropAbi as any,
      bytecode: MerkleAirdropBytecode.object as `0x${string}`,
      account,
      chain: localChain,
      gas: BigInt(5000000),
    };
    const hash = await walletClient.deployContract(data);

    console.log('Contract deployed at:', hash);
    const receipt = await client.waitForTransactionReceipt({ hash });
    console.log('Receipt:', receipt);
    const contractAddress = receipt.contractAddress;

    contact = getContract({
      address: contractAddress as Address,
      abi: MerkleAirdropAbi as any,
      client: client as any,
    });
  });

  test('create Merkle Tree', () => {
    const accounts: { address: Address; amount: bigint }[] = [
      { address: '0x1234567890123456789012345678901234567890', amount: 100n },
      { address: '0xabcdef1234567890abcdef1234567890abcdef12', amount: 200n },
      { address: '0x1234567890123456789012345678901234567890', amount: 300n },
      { address: '0xabcdef1234567890abcdef1234567890abcdef12', amount: 400n },
      { address: '0x1234567890123456789012345678901234567890', amount: 500n },
      { address: '0xabcdef1234567890abcdef1234567890abcdef12', amount: 600n },
      { address: '0x1234567890123456789012345678901234567890', amount: 700n },
      { address: '0xabcdef1234567890abcdef1234567890abcdef12', amount: 800n },
    ];

    const tree = createMerkleTree(accounts);
    const hexRoot = tree.getHexRoot();
    const proof = getProof(tree, accounts[0]);

    const isValid = tree.verify(proof, getLeaf(accounts[0]), hexRoot);
    expect(isValid).toBe(true);
  });

  test('claim', async () => {
    const epoch = await contact.read.getEpoch();
    console.log('Epoch:', epoch);
  });
});
