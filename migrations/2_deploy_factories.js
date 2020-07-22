const TMath = artifacts.require('TMath');
const BToken = artifacts.require('BToken');
const BFactory = artifacts.require('BFactory');
const BPoolTemplateLib = artifacts.require('BPoolTemplateLib');

module.exports = async function (deployer, network, accounts) {
    if (network === 'development' || network === 'coverage') {
        deployer.deploy(TMath);
    }
    deployer.deploy(BPoolTemplateLib);
    deployer.link(BPoolTemplateLib, BFactory);
    deployer.deploy(BFactory);
};
