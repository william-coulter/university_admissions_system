const Sum = artifacts.require("Sum");

contract("Sum", sum => {
    it("should sum two numbers", async () => {
        const sum = await Sum.deployed();

        const expected = 10;
        const result = await sum.getSum(6,4);

        assert.equal(expected, result, "Sum of 6 and 4 does not equal 10"); 
    });
});
