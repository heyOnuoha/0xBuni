const path = require("path");
const HDWalletProvider = require("@truffle/hdwallet-provider");

const mnemonic = "deputy program minimum cabin issue seat ability that inspire nation case jacket";

module.exports = {
  contracts_build_directory: path.join(__dirname, "client/src/contracts"),
  networks: {
    develop: {
      port: 8545
    },
    ropsten: {
      provider: function() {
        return new HDWalletProvider(mnemonic, `https://rinkeby.infura.io/v3/c196503f6b064571b0700cacf467b5c8`);
      },
      network_id: 0x4,
      gas: 10000000,
      from: '0xB845796Ae42F5061C65717e3e29ff33495B1652d'
    }
  },
  compilers: {
    solc: {
      version: "0.8.9",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        },
        evmVersion: "byzantium"
      }
    }
  }
};
