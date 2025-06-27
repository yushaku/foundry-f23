import { loadFixture } from '@nomicfoundation/hardhat-network-helpers';
import { expect } from 'chai';
import { ethers } from 'hardhat';
import { MerkleTree } from 'merkletreejs';
import { parseEther, solidityPackedKeccak256, ZeroAddress } from 'ethers';
import keccak256 from 'keccak256';

// Helper function to parse token amounts with decimals
function parseTokenAmount(amount: string, decimals: number): bigint {
  const [integer, fraction = '0'] = amount.split('.');
  const paddedFraction = fraction.padEnd(decimals, '0').slice(0, decimals);
  return BigInt(integer + paddedFraction);
}

function getLeaf(account: { address: string; amount: bigint }) {
  return solidityPackedKeccak256(['address', 'uint256'], [account.address, account.amount]);
}

function createMerkleTree(accounts: { address: string; amount: bigint }[]) {
  const leaves = accounts.map(getLeaf);
  return new MerkleTree(leaves, keccak256, { sortPairs: true });
}

function getProof(tree: MerkleTree, account: { address: string; amount: bigint }) {
  const leaf = getLeaf(account);
  return tree.getHexProof(leaf);
}

describe('RewardDistribution', function () {
  // We define a fixture to reuse the same setup in every test.
  // We use loadFixture to run this setup once, snapshot that state,
  // and reset Hardhat Network to that snapshot in every test.
  async function deployRewardDistributionFixture() {
    // Contracts are deployed using the first signer/account by default
    const [owner, user1, user2, user3] = await ethers.getSigners();

    // Deploy MockERC20 token with explicit type casting
    const MockERC20 = await ethers.getContractFactory('MockERC20');
    const mockToken = (await MockERC20.deploy('Test Token', 'TEST', 18)) as MockERC20;
    await mockToken.waitForDeployment();
    const mockTokenAddress = await mockToken.getAddress();

    // Deploy RewardDistribution contract
    const RewardDistribution = await ethers.getContractFactory('RewardDistribution');
    const rewardDistribution = await RewardDistribution.deploy(mockTokenAddress);
    await rewardDistribution.waitForDeployment();

    // Mint some tokens to users for testing
    const tokenAmount = parseTokenAmount('1000', 18);
    await mockToken.mint(user1.address, tokenAmount);
    await mockToken.mint(user2.address, tokenAmount);

    // Approve RewardDistribution to spend tokens
    await mockToken.connect(user1).approve(await rewardDistribution.getAddress(), tokenAmount);
    await mockToken.connect(user2).approve(await rewardDistribution.getAddress(), tokenAmount);

    return {
      rewardDistribution,
      mockToken,
      owner,
      user1,
      user2,
      user3,
      tokenAmount,
    };
  }

  describe('Deployment', function () {
    it('Should set the right owner', async function () {
      const { rewardDistribution, owner } = await loadFixture(deployRewardDistributionFixture);
      expect(await rewardDistribution.owner()).to.equal(owner.address);
    });
  });

  describe('Token Management', function () {
    it('Should allow owner to add token to whitelist', async function () {
      const { rewardDistribution, mockToken, owner } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddress = await mockToken.getAddress();

      await expect(rewardDistribution.connect(owner).addToken(tokenAddress))
        .to.emit(rewardDistribution, 'RD__TokenWhitelisted')
        .withArgs(tokenAddress);

      const tokens = await rewardDistribution.whiteListTokens();
      expect(tokens).to.include(tokenAddress);
      expect(await rewardDistribution.isWhiteListed(tokenAddress)).to.be.true;
    });

    it('Should allow owner to remove token from whitelist', async function () {
      const { rewardDistribution, mockToken, owner } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddress = await mockToken.getAddress();

      await expect(rewardDistribution.connect(owner).addToken(tokenAddress))
        .to.emit(rewardDistribution, 'RD__TokenWhitelisted')
        .withArgs(tokenAddress);

      await expect(rewardDistribution.connect(owner).removeToken(tokenAddress))
        .to.emit(rewardDistribution, 'RD__TokenRemoved')
        .withArgs(tokenAddress);

      const tokens = await rewardDistribution.whiteListTokens();
      expect(tokens).to.not.include(tokenAddress);
    });

    it('Should prevent non-owner from adding tokens', async function () {
      const { rewardDistribution, mockToken, user1 } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddress = await mockToken.getAddress();

      await expect(rewardDistribution.connect(user1).addToken(tokenAddress)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      );
    });

    it('Should prevent non-owner from removing tokens', async function () {
      const { rewardDistribution, mockToken, owner, user1 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const tokenAddress = await mockToken.getAddress();

      await expect(rewardDistribution.connect(owner).removeToken(tokenAddress))
        .to.emit(rewardDistribution, 'RD__TokenRemoved')
        .withArgs(tokenAddress);

      await expect(rewardDistribution.connect(user1).removeToken(tokenAddress)).to.be.revertedWith(
        'Ownable: caller is not the owner',
      );
    });
  });

  describe('Merkle Root Management', function () {
    it('Should allow owner to add merkle root', async function () {
      const { rewardDistribution, mockToken, owner } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddress = await mockToken.getAddress();
      const merkleRoot = ethers.hexlify(ethers.randomBytes(32)); // Random merkle root

      await rewardDistribution.connect(owner).addToken(tokenAddress);

      await expect(rewardDistribution.connect(owner).addMerkleRoot(merkleRoot, tokenAddress))
        .to.emit(rewardDistribution, 'RD__MerkleRootAdded')
        .withArgs(1, merkleRoot, tokenAddress);

      const currentEpoch = await rewardDistribution.currentEpoch();
      expect(currentEpoch).to.equal(1);

      const merkleRootData = await rewardDistribution.merkleRoot(1);
      expect(merkleRootData.token).to.equal(tokenAddress);

      expect(merkleRootData.merkleRoot).to.equal(merkleRoot);
      expect(merkleRootData.token).to.equal(tokenAddress);
    });

    it('Should allow owner to update merkle root', async function () {
      const { rewardDistribution, mockToken, owner } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddress = await mockToken.getAddress();
      const merkleRoot = ethers.hexlify(ethers.randomBytes(32)); // Random merkle root
      const newMerkleRoot = ethers.hexlify(ethers.randomBytes(32)); // Random merkle root

      await rewardDistribution.connect(owner).addToken(tokenAddress);

      await expect(rewardDistribution.connect(owner).addMerkleRoot(merkleRoot, tokenAddress))
        .to.emit(rewardDistribution, 'RD__MerkleRootAdded')
        .withArgs(1, merkleRoot, tokenAddress);

      await expect(rewardDistribution.connect(owner).updateMerkleRoot(newMerkleRoot, tokenAddress))
        .to.emit(rewardDistribution, 'RD__MerkleRootUpdated')
        .withArgs(1n, newMerkleRoot, tokenAddress);

      const merkleRootData = await rewardDistribution.merkleRoot(1);
      expect(merkleRootData.merkleRoot).to.equal(newMerkleRoot);
      expect(merkleRootData.token).to.equal(tokenAddress);
    });

    it('Should not allow user to add merkle root', async function () {
      const { rewardDistribution, mockToken, owner, user1 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const tokenAddress = await mockToken.getAddress();
      const merkleRoot = ethers.hexlify(ethers.randomBytes(32)); // Random merkle root
      await rewardDistribution.connect(owner).addToken(tokenAddress);

      await expect(
        rewardDistribution.connect(user1).addMerkleRoot(merkleRoot, tokenAddress),
      ).to.be.revertedWith('Ownable: caller is not the owner');
    });

    it('Should not allow user to update merkle root', async function () {
      const { rewardDistribution, mockToken, owner, user1 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const tokenAddress = await mockToken.getAddress();
      const merkleRoot = ethers.hexlify(ethers.randomBytes(32)); // Random merkle root
      await rewardDistribution.connect(owner).addToken(tokenAddress);

      await expect(
        rewardDistribution.connect(user1).updateMerkleRoot(merkleRoot, tokenAddress),
      ).to.be.revertedWith('Ownable: caller is not the owner');
    });
  });

  // Additional coverage tests
  describe('Deposit Edge Cases', function () {
    it('Should revert when depositing native token with insufficient msg.value', async function () {
      const { rewardDistribution, owner } = await loadFixture(deployRewardDistributionFixture);
      const amount = ethers.parseEther('1.0');
      await expect(
        rewardDistribution.connect(owner).deposit(ZeroAddress, amount, { value: 0n }),
      ).to.be.revertedWithCustomError(rewardDistribution, 'RD__InsufficientBalance');
    });

    it('Should revert when depositing non-whitelisted ERC20 token', async function () {
      const { rewardDistribution, owner } = await loadFixture(deployRewardDistributionFixture);
      const Token = await ethers.getContractFactory('MockERC20');
      const badToken = await Token.deploy('Bad', 'BAD', 18);
      const amount = 100n;
      await expect(
        rewardDistribution.connect(owner).deposit(await badToken.getAddress(), amount),
      ).to.be.revertedWithCustomError(rewardDistribution, 'RD__InvalidToken');
    });
  });

  describe('Token List & Validation', function () {
    it('Should revert when owner tries to add zero address token', async function () {
      const { rewardDistribution, owner } = await loadFixture(deployRewardDistributionFixture);
      await expect(
        rewardDistribution.connect(owner).addToken(ethers.ZeroAddress),
      ).to.be.revertedWithCustomError(rewardDistribution, 'RD__ZeroAddress');
    });

    it('whiteListTokens should include newly added token', async function () {
      const { rewardDistribution, mockToken, owner } = await loadFixture(deployRewardDistributionFixture);
      const tokenAddr = await mockToken.getAddress();
      await rewardDistribution.connect(owner).addToken(tokenAddr);
      const list = await rewardDistribution.whiteListTokens();
      expect(list).to.include(tokenAddr);
    });
  });

  describe('Claim', function () {
    it('Should revert claim when proof is invalid', async function () {
      const { rewardDistribution, owner, user1, user2, user3 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const amount = parseEther('2.0');
      const accounts = [
        {
          address: user1.address,
          amount,
        },
        {
          address: user2.address,
          amount,
        },
      ];
      const tree = createMerkleTree(accounts);
      const root = tree.getHexRoot();
      const proof = getProof(tree, accounts[0]);
      await rewardDistribution.connect(owner).addMerkleRoot(root, ZeroAddress);

      await expect(rewardDistribution.connect(user3).claim(1, amount, proof)).to.be.revertedWithCustomError(
        rewardDistribution,
        'RD__InvalidProof',
      );
    });

    it('Should revert claim when amount is not correct', async function () {
      const { rewardDistribution, owner, user1, user2, user3 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const amount = parseEther('2.0');
      const accounts = [
        {
          address: user1.address,
          amount,
        },
        {
          address: user2.address,
          amount,
        },
      ];
      const tree = createMerkleTree(accounts);
      const root = tree.getHexRoot();
      const proof = getProof(tree, accounts[0]);
      await rewardDistribution.connect(owner).addMerkleRoot(root, ZeroAddress);

      await expect(rewardDistribution.connect(user3).claim(1, amount, proof)).to.be.revertedWithCustomError(
        rewardDistribution,
        'RD__InvalidProof',
      );
    });

    it('Should revert claim when user has already claimed', async function () {
      const { rewardDistribution, owner, user1, user2, user3 } = await loadFixture(
        deployRewardDistributionFixture,
      );
      const amount = parseEther('1');
      const accounts = [
        {
          address: user1.address,
          amount,
        },
        {
          address: user2.address,
          amount,
        },
        {
          address: user3.address,
          amount,
        },
      ];
      const tree = createMerkleTree(accounts);
      const root = tree.getHexRoot();
      const proof = getProof(tree, accounts[0]);
      const leaf = getLeaf(accounts[0]);

      expect(tree.verify(proof, leaf, root)).to.be.true;

      await expect(rewardDistribution.connect(owner).addMerkleRoot(root, ZeroAddress))
        .to.emit(rewardDistribution, 'RD__MerkleRootAdded')
        .withArgs(1, root, ZeroAddress);

      await rewardDistribution.connect(owner).deposit(ZeroAddress, amount * 10n, { value: amount * 10n });

      await rewardDistribution.connect(user1).claim(1, amount, proof);

      await expect(rewardDistribution.connect(user1).claim(1, amount, proof)).to.be.revertedWithCustomError(
        rewardDistribution,
        'RD__RewardAlreadyClaimed',
      );
    });
  });

  describe('Multicall', function () {
    it('claim 2 rewards', async function () {
      const { rewardDistribution, mockToken, owner, user1, user2, user3 } = await loadFixture(
        deployRewardDistributionFixture,
      );

      const amount = parseEther('1');
      const accounts = [
        {
          address: user1.address,
          amount,
        },
        {
          address: user2.address,
          amount,
        },
        {
          address: user3.address,
          amount,
        },
      ];
      const tree = createMerkleTree(accounts);
      const root = tree.getHexRoot();
      const proof = getProof(tree, accounts[0]);
      const leaf = getLeaf(accounts[0]);

      expect(tree.verify(proof, leaf, root)).to.be.true;
      const usdc = await mockToken.getAddress();

      await mockToken.connect(owner).approve(rewardDistribution.getAddress(), amount * 10n);
      await expect(rewardDistribution.connect(owner).deposit(usdc, amount * 10n))
        .to.emit(rewardDistribution, 'RD__RewardAdded')
        .withArgs(usdc, amount * 10n);

      await expect(rewardDistribution.connect(owner).addMerkleRoot(root, usdc))
        .to.emit(rewardDistribution, 'RD__MerkleRootAdded')
        .withArgs(1, root, usdc);

      await expect(rewardDistribution.connect(owner).addMerkleRoot(root, usdc))
        .to.emit(rewardDistribution, 'RD__MerkleRootAdded')
        .withArgs(2, root, usdc);

      const balanceBefore = await mockToken.balanceOf(user1.address);
      // multicall claim 2 rewards
      const multicallData = [
        rewardDistribution.interface.encodeFunctionData('claim', [1, amount, proof]),
        rewardDistribution.interface.encodeFunctionData('claim', [2, amount, proof]),
      ];

      await expect(rewardDistribution.connect(user1).multicall(multicallData))
        .to.emit(rewardDistribution, 'RD__RewardClaimed')
        .withArgs(user1.address, amount);

      const balanceAfter = await mockToken.balanceOf(user1.address);
      expect(balanceAfter).to.equal(balanceBefore + amount * 2n);
    });
  });
});
