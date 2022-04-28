const FlexStaking = artifacts.require("FlexStaking")
const Token = artifacts.require("ERC20Token")
const { assert } = require('chai')
const truffleAssert = require('truffle-assertions')
const BigNumber = require("bignumber.js")
BigNumber.config({ EXPONENTIAL_AT: 1e+9 })
const constants = require('@openzeppelin/test-helpers/src/constants.js');

contract("Testing Flex Staking", accounts => {
    const projectOwner = accounts[0], amount = '1000000000000', APR = '5' // Annual Percentage Rate 
    let flexStaking
    before(async () => {
        flexStaking = await FlexStaking.deployed()
    })

    it('only the owner has control rights', async () => {
        const notProjectOwner = accounts[1]
        const lockedDeal = accounts[2]
        rewardToken = await Token.new('Reward Token', 'REWARD')
        lockedToken = await Token.new('Locked Token', 'LOCK')
        await truffleAssert.reverts(
            flexStaking.SetLockedDealAddress(lockedDeal, { from: notProjectOwner }), 'Authorization Error')
        await truffleAssert.passes(
            flexStaking.SetLockedDealAddress(lockedDeal, { from: projectOwner }))
    })

    it('should create stake Pool', async () => {
        await rewardToken.approve(flexStaking.address, amount, { from: projectOwner })
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 365)   // add a year
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneMonth = 60 * 60 * 24 * 30 // seconds
        const twoMonth = 60 * 60 * 24 * 60
        await flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonth, '1', '10', '0')
    })

    it('should create Pool with the same reward token', async () => {
        await lockedToken.approve(flexStaking.address, amount, { from: projectOwner })
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 365)   // add a year
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneMonth = 60 * 60 * 24 * 30 // seconds
        const twoMonth = 60 * 60 * 24 * 60
        const result = await flexStaking.CreateStakingPool(lockedToken.address, lockedToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonth, '1', '10', '0')
        poolId = result.logs[result.logs.length - 1].args.Id.toString()
    })

    it("should set LockedDeal address", async () => {
        const lockedDeal = constants.ZERO_ADDRESS
        const previousAddr = accounts[2]
        await flexStaking.SetLockedDealAddress(lockedDeal)
        const result = await flexStaking.LockedDealAddress()
        assert.notEqual(result, previousAddr)
        assert.equal(result, lockedDeal)
        await truffleAssert.reverts(
            flexStaking.SetLockedDealAddress(lockedDeal), 'The address of the Locked Deal has already been changed')
    })

    it('should be greater than zero', async () => {
        const date = new Date()
        const startTime = Math.floor(date.getTime() / 1000) + 60
        date.setDate(date.getDate() + 3)   // add 3 days
        const finishTime = Math.floor(date.getTime() / 1000) + 60
        const oneMonth = 60 * 60 * 24 * 30 // seconds
        const twoMonths = 60 * 60 * 24 * 60
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, '0', oneMonth, twoMonths, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, '0', finishTime, APR, oneMonth, twoMonths, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, '0', APR, oneMonth, twoMonths, '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, twoMonths, '0', '1', '10', '0'),
            'The value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonths, '1', '0', '0'),
            'The value should be greater than zero!')
    })
})