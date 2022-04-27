const FlexStacking = artifacts.require("FlexStaking")
const Token = artifacts.require("ERC20Token")
const { assert } = require('chai')
const truffleAssert = require('truffle-assertions')
const BigNumber = require("bignumber.js")
BigNumber.config({ EXPONENTIAL_AT: 1e+9 })
const constants = require('@openzeppelin/test-helpers/src/constants.js');

contract("Testing Flex Staking", accounts => {
    const projectOwner = accounts[0], amount = '1000000000000', APR = '5' // Annual Percentage Rate 
    let flexStacking
    before(async () => {
        flexStacking = await FlexStacking.deployed()
    })

    it('only the owner has control rights', async () => {
        const notProjectOwner = accounts[1]
        const lockedDeal = accounts[2]
        rewardToken = await Token.new('Reward Token', 'REWARD')
        lockedToken = await Token.new('Locked Token', 'LOCK')
        await truffleAssert.reverts(
            flexStacking.SetLockedDealAddress(lockedDeal, { from: notProjectOwner }), 'Authorization Error')
        await truffleAssert.passes(
            flexStacking.SetLockedDealAddress(lockedDeal, { from: projectOwner }))
    })

    it('should create stake Pool', async () => {
        await rewardToken.approve(flexStacking.address, amount, { from: projectOwner })
        await lockedToken.approve(flexStacking.address, amount, { from: projectOwner })
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 3)   // add 3 days
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneDay = 60 * 60 * 24 // seconds
        const twoDays = 60 * 60 * 24 * 2
        await flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, startTime, finishTime, APR, oneDay, twoDays, '1', '10', '0')
    })

    it('should create Pool with the same reward token', async () => {
        await lockedToken.approve(flexStacking.address, amount * 2, { from: projectOwner })
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 3)   // add 3 days
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneDay = 60 * 60 * 24 // seconds
        const twoDays = 60 * 60 * 24 * 2
        await flexStacking.CreateStakingPool(lockedToken.address, amount, lockedToken.address, amount, startTime, finishTime, APR, oneDay, twoDays, '1', '10', '0')
    })

    it("should set LockedDeal address", async () => {
        const lockedDeal = constants.ZERO_ADDRESS
        const previousAddr = accounts[2]
        await flexStacking.SetLockedDealAddress(lockedDeal)
        const result = await flexStacking.LockedDealAddress()
        assert.notEqual(result, previousAddr)
        assert.equal(result, lockedDeal)
        await truffleAssert.reverts(
            flexStacking.SetLockedDealAddress(lockedDeal), 'The address of the Locked Deal has already been changed')
    })

    it('should be greater than zero', async () => {
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 2)   // add 2 days
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneDay = 1000 * 60 * 60 * 24 // Milliseconds
        const twoDays = 1000 * 60 * 60 * 24 * 2
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, startTime, finishTime, '0', oneDay, twoDays, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, '0', rewardToken.address, amount, startTime, finishTime, APR, oneDay, twoDays, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, '0', finishTime, APR, oneDay, twoDays, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, startTime, '0', APR, oneDay, twoDays, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, startTime, finishTime, APR, oneDay, '0', '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStacking.CreateStakingPool(lockedToken.address, amount, rewardToken.address, amount, startTime, finishTime, APR, oneDay, twoDays, '1', '0', '0'),
            'The value should be greater than zero!')
    })
})