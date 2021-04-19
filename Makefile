.PHONY: install
install:
	npm install

.PHONY: deploy-chain
deploy-chain: install
	ganache-cli \
	--gasPrice 0 \
	--gasLimit "0xffffff" \
	--defaultBalanceEther "1000" \
	--allowUnlimitedContractSize

.PHONY: test
test: install
	truffle test

.PHONY: deploy-contracts
deploy-contracts: install
	truffle migrate
