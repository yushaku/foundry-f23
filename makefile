
install :
	@echo "Installing dependencies..."
	forge install foundry-rs/forge-std
	forge install OpenZeppelin/openzeppelin-contracts
	forge install dmfxyz/murky
	forge install Cyfrin/foundry-devops
	@echo "Dependencies installed successfully!"
	

init_chain :
	anvil --fork-url https://eth-mainnet.public.blastapi.io --fork-block-number 1 -m 'test test test test test test test test test test test junk' --steps-tracing --gas-limit 5000000000