const Negotiate = artifacts.require("./Negotiate.sol")

module.exports = function(deployer) {
	deployer.deploy(Negotiate);
};