const Knights = artifacts.require("Knights");

contract("Knights", accounts => {
    var knightCount; 

    before(async () => {
        knightsInstance = await Knights.deployed();
    });

    describe("application features", async () => {
        it("initial knights count be zero", async () => {
            knightCount = await knightsInstance.knightsCount();
            assert.equal(knightCount.toNumber(), 0);
        });

        it("allow minting ERC721 token", async () => {
            await knightsInstance.mintKnight("https://ipfstokenuri.com", 200, true, {from : accounts[1]});
            //assert.equal((await knightsInstance.knightsCount()).toNumber(), 1);
            assert.equal((await knightsInstance.tokenURI(1)), "https://ipfstokenuri.com");
        });

        it("fetch the owner of minted token", async () => {
            assert.equal((await knightsInstance.ownerOf(1)), accounts[1]);
        });
    });

});
