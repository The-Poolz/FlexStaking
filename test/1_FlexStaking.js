const FlexStakingUser = artifacts.require("FlexStakingUser")
const Token = artifacts.require("ERC20Token")
const { assert } = require('chai')
const truffleAssert = require('truffle-assertions')
const BigNumber = require("bignumber.js")
BigNumber.config({ EXPONENTIAL_AT: 1e+9 })
const timeMachine = require('ganache-time-traveler')
const constants = require('@openzeppelin/test-helpers/src/constants.js');

contract("Testing Flex Staking", accounts => {
    const projectOwner = accounts[0], amount = '1000000000000', APR = '5' // Annual Percentage Rate 
    const minAmount = '10000000', maxAmount = '1000000000'
    const lockedDeal = accounts[2]
    const oneMonth = 60 * 60 * 24 * 30 // seconds
    const twoMonths = 60 * 60 * 24 * 60
    const date = new Date()
    const startTime = Math.floor(date.getTime() / 1000) + 60
    let finishTime
    let flexStaking

    before(async () => {
        flexStaking = await FlexStakingUser.deployed()
        date.setDate(date.getDate() + 365)   // add a year
        finishTime = Math.floor(date.getTime() / 1000) + 60
    })

    it('only the owner has control rights', async () => {
        const notProjectOwner = accounts[1]
        rewardToken = await Token.new('Reward Token', 'REWARD')
        lockedToken = await Token.new('Locked Token', 'LOCK')
        await truffleAssert.reverts(
            flexStaking.SetLockedDealAddress(lockedDeal, { from: notProjectOwner }), 'Authorization Error')
        await truffleAssert.passes(
            flexStaking.SetLockedDealAddress(lockedDeal, { from: projectOwner }))
    })

    it('should create stake Pool', async () => {
        await rewardToken.approve(flexStaking.address, amount, { from: projectOwner })
        await flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonths, minAmount, maxAmount, '0')
    })

    it('should create Pool with the same reward token', async () => {
        await lockedToken.approve(flexStaking.address, amount, { from: projectOwner })
        const result = await flexStaking.CreateStakingPool(lockedToken.address, lockedToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonths, minAmount, maxAmount, '0')
        poolId = result.logs[result.logs.length - 1].args.Id.toString()
    })

    it("should set LockedDeal address", async () => {
        const newLockedDeal = constants.ZERO_ADDRESS
        const previousAddr = accounts[2]
        await flexStaking.SetLockedDealAddress(newLockedDeal)
        const result = await flexStaking.LockedDealAddress()
        assert.notEqual(result, previousAddr)
        assert.equal(result, newLockedDeal)
        await truffleAssert.reverts(
            flexStaking.SetLockedDealAddress(newLockedDeal), 'the address of the Locked Deal has already been changed')
    })

    it('should be greater than zero', async () => {
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, '0', oneMonth, twoMonths, '1', '10', '0'),
            'the value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, '0', twoMonths, '1', '10', '0'),
            'the value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, twoMonths, '0', '10', '0'),
            'the value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, '0', startTime, finishTime, APR, oneMonth, twoMonths, '1', '10', '0'),
            'the value should be greater than zero!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, '0', finishTime, APR, oneMonth, twoMonths, '1', '10', '0'),
            'invalid start time!')
    })

    it('should withdraw leftover tokens', async () => {
        const date = new Date()
        date.setDate(date.getDate() + 366)
        const future = Math.floor(date.getTime() / 1000) + 60
        await truffleAssert.reverts(flexStaking.WithdrawLeftOver(poolId), 'should wait when pool is over!')
        await timeMachine.advanceBlockAndSetTime(future)
        await flexStaking.WithdrawLeftOver(poolId)
        await truffleAssert.reverts(flexStaking.WithdrawLeftOver(poolId), 'all tokens distributed!')
    })

    it('should revert wrong id', async () => {
        let wrongID = '10000'
        await flexStaking.SetLockedDealAddress(lockedDeal)
        await truffleAssert.reverts(flexStaking.WithdrawLeftOver(wrongID), 'invalid id!')
        await truffleAssert.reverts(flexStaking.Stake(wrongID, minAmount, oneMonth), 'invalid id!')
        wrongID = '0'
        await truffleAssert.reverts(flexStaking.WithdrawLeftOver(wrongID), 'invalid id!')
        await truffleAssert.reverts(flexStaking.Stake(wrongID, minAmount, oneMonth), 'invalid id!')
    })

    it('should revert when not enough tokens', async () => {
        await truffleAssert.reverts(flexStaking.Stake(poolId, minAmount, oneMonth), 'not enough tokens!')
    })

    it('should revert wrong amount', async () => {
        await truffleAssert.reverts(flexStaking.Stake(poolId, minAmount - 1, oneMonth), 'wrong amount!')
        await truffleAssert.reverts(flexStaking.Stake(poolId, maxAmount + 1, oneMonth), 'wrong amount!')
        await timeMachine.advanceBlockAndSetTime(startTime)
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, oneMonth, minAmount, minAmount - 1, '0'),
            'invalid maxium amount!')
    })

    it('should revert invalid start time', async () => {
        const date = new Date()
        date.setDate(date.getDate() - 400)
        const past = Math.floor(date.getTime() / 1000) + 60
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, past, finishTime, APR, oneMonth, oneMonth, minAmount, minAmount, '0'),
            'invalid start time!')
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, startTime - 1, APR, oneMonth, oneMonth, minAmount, minAmount, '0'),
            'invalid start time!')
    })

    it('should revert wrong duration time', async () => {
        await truffleAssert.reverts(
            flexStaking.CreateStakingPool(lockedToken.address, rewardToken.address, amount, startTime, finishTime, APR, oneMonth, oneMonth - 1, minAmount, maxAmount, '0'),
            'invalid maximum duration time!')
        await truffleAssert.reverts(flexStaking.Stake(poolId - 1, minAmount, twoMonths + 1), 'wrong duration time!')
        await truffleAssert.reverts(flexStaking.Stake(poolId - 1, minAmount, oneMonth - 1), 'wrong duration time!')
    })
})