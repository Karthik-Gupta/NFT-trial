const Knights = artifacts.require("Knights");

contract("Knights", accounts => {
    var result, knight, knightCount; 

    before(async () => {
        knightsInstance = await Knights.deployed();
    });

    describe("application features", async () => {
        it("initial knights count be zero", async () => {
            knightCount = await knightsInstance.knightsCount();
            assert.equal(knightCount.toNumber(), 0);
        });

        it("allows users to mint ERC721 token", async () => {
            
        });
    });

});
