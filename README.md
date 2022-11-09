# FlexStaking

[![Build Status](https://app.travis-ci.com/The-Poolz/FlexStaking.svg?token=xusbS8YxMuyCLykrBixj&branch=master)](https://app.travis-ci.com/The-Poolz/FlexStaking)
[![codecov](https://codecov.io/gh/The-Poolz/FlexStaking/branch/master/graph/badge.svg?token=RwT6sEA5xI)](https://codecov.io/gh/The-Poolz/FlexStaking)
[![CodeFactor](https://www.codefactor.io/repository/github/the-poolz/flexstaking/badge)](https://www.codefactor.io/repository/github/the-poolz/flexstaking)

**DApp** that allows users to stake their **ERC20** tokens and earn rewards or create their own staking pool.

### Navigation

- [Installation](#installation)
- [Contract relations](#uml)
- [Contract owner](#contract-owner)
- [Project owner](#project-owner)
- [Investor](#investor)
- [License](#license)
#### Installation

```console
npm install
```

#### Testing

```console
truffle run coverage
```

#### Deployment

```console
truffle dashboard
```

```console
truffle migrate --network dashboard
```

## UML
![classDiagram](https://user-images.githubusercontent.com/68740472/200824349-d5a9e263-f400-4b54-9125-bf14768cd2a0.svg)

## Contract owner
**The owner** of the contract has administrator rights, which he can transfer to any other address by using **transferOwnership** function.
```solidity
transferOwnership(address newOwner)
```
### Locked-Deal
Before contract can be used for staking, the Locked Deal address must be set using the **SetLockedDealAddress** method. **Locked-Deal** is a service contract whose main task is to store tokens.
https://github.com/The-Poolz/FlexStaking/blob/78fe05cacafe6e76b7d6df6115dbce1672e049e6/contracts/FlexStakingManageable.sol#L19
**Locked-Deal** contract documentation: https://github.com/The-Poolz/Locked-pools#locked-deal-v2
### Pauseable
The admin has the right to suspend the contract using the `Pause()` and `Unpause()` functions. After the suspension, **users** and **pool owners** can't invest and create new staking pools. When paused, the **Pool Owner** can withdraw the remaining tokens if the pool has expired.

## Project owner
A **Project Owner** is a user who creates their own staking pool using the **CreateStakingPool** function.
https://github.com/The-Poolz/FlexStaking/blob/78fe05cacafe6e76b7d6df6115dbce1672e049e6/contracts/FlexStakingPO.sol#L26-L38
When created, a pool receives its own pool ID, which can be used for the staking and withdrawal functions of the remaining funds. 

### Withdraw Left Over 
**WithdrawLeftOver** is a function that allows the pool owner to withdraw the remaining tokens if the staking pool has expired.
https://github.com/The-Poolz/FlexStaking/blob/78fe05cacafe6e76b7d6df6115dbce1672e049e6/contracts/FlexStakingPO.sol#L94
## Investor
An **Investor** is a user who stakes tokens to earn more. After using the **Stake** function, tokens will be transferred to the contract.
https://github.com/The-Poolz/FlexStaking/blob/78fe05cacafe6e76b7d6df6115dbce1672e049e6/contracts/FlexStakingUser.sol#L17-L21
The vaults are then created in **Locked-Pools** after the stake. If the reward and locked tokens are different, then two pools will be opened, if they are the same, only one.
https://github.com/The-Poolz/FlexStaking/blob/78fe05cacafe6e76b7d6df6115dbce1672e049e6/contracts/FlexStakingUser.sol#L66-L72
### How to return my reward tokens?
The **Locked-Deal** contract has a `WithdrawToken` function that must be used to return rewards and locked tokens.
### How do I find my Locked-Deal Pool IDs?
A **LockedDeal** has a `GetMyPoolsId` function that returns the IDs of all your pools.
```solidity
function GetMyPoolsId(address _UserAddress)
```
## License
The-Poolz Contracts is released under the MIT License.