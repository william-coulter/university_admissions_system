# University Admissions Tool

A set of smart contracts which can be used by a university to handle course enrolment and admissions. 

For COMP6451 Ethereum Programming assignment.

# Dependencies (and versions)
 - `npm`: 6.14.4
 - `node`: v14.16.1
 - `make`: 3.81
 - `truffle`: `npm install -g truffle@v5.1.65`: v5.1.65
 - `ganache-cli`: `npm install -g ganache-cli`: v6.12.2

# Tests

First deploy the chain: `make deploy-chain`.
This will deploy a `ganache` instance listening on `localhost:8545`.

Run the tests with: `make test`
This will perform an `npm install` and make sure all of the contracts have been compiled and deployed. 
All the tests in the `/test` directory will run.

See `Makefile` for more commands.

