.PHONY: deploy-chain
deploy-chain:
	ganache-cli --gasPrice 0

.PHONY: test
test:
	truffle test

.PHONY: deploy-contracts
deploy-contracts:
	truffle migrate
