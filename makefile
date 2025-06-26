-include .env

install :
	@echo "Installing dependencies..."
	-forge install foundry-rs/forge-std@v1.8.2
	-forge install transmissions11/solmate@v6
	@echo "Dependencies installed successfully!"

# Update Dependencies
update:; forge update

test :; forge test

coverage :; forge coverage --report debug > coverage.txt