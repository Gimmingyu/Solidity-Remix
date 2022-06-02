const HDWalletProvider = require("truffle-hdwallet-provider");
beneficiary =
	"popular across race change lava rifle patch spice soft summer muffin awkward";
module.exports = {
	networks: {
		ropsten: {
			provider: () =>
				new HDWalletProvider(
					beneficiary,
					"https://ropsten.infura.io/v3/a05cbffef0f54ad4983828e7e46a91c3"
				),
			network_id: 3,
			gas: 5000000,
			skipDryRun: false,
		},
		development: {
			host: "localhost",
			port: 7545,
			network_id: "*", // Match any network id
		},
	},

	compilers: {
		solc: {
			version: "0.5.8",
		},
	},
};
