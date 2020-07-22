const BPool = artifacts.require('BPool');
const BFactory = artifacts.require('BFactory');

contract('BFactory', async (accounts) => {

    describe('Factory', () => {
        let factory;
        let pool;
        let POOL;

        before(async () => {
            factory = await BFactory.deployed();

            // ========= new =============
            await factory.deployBPoolTemplate();
            // arg: 1 is for salt
            POOL = await factory.getAddress(1);
            // ============ end new ==========
            await factory.newBPool(1);
            pool = await BPool.at(POOL);
        });
        // ========= new ========
        it('BPool is Deployed - for gas reporter', async () => {
            const pool = await factory.newBPool(2);
        });
        // ========== end new =========
    });
});
