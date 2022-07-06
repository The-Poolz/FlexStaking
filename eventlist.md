# List of events

<table>
<thead>
<tr>
<th align="center">functions</th>
<th>events</th>
<th>links</th>
</tr>
</thead>
<tbody>
<tr>
<td align="center"><b>CreateStakingPool</b></td>
<td align="left"><pre>
        TransferIn(uint256 Amount, address From, address Token)
        CreatedPool(
        address Owner,
        uint256 Id,
        address LockedToken,
        address RewardToken,
        uint256 TokensAmount,
        uint256 StartTime,
        uint256 FinishTime,
        uint256 APR,
        uint256 MinDuration,
        uint256 MaxDuration,
        uint256 MinAmount,
        uint256 MaxAmount,
        uint256 EarlyWithdraw
    )
</pre><td><a href="https://testnet.bscscan.com/tx/0x520408e628c9649fe1036aa33f31759563f26dfbe1eb54e58273f63dae286eea#eventlog">CreateStakingPool</a></td>
</tr>
<tr>
<td align="center"><b>Stake</b></td>
<td align="left"><pre>
if same reward token and locked token
        TransferIn(uint256 Amount, address From, address Token)
        TransferIn(uint256 Amount, address From, address Token)
        NewPoolCreated(uint256 PoolId, address Token, uint256 StartTime, uint256 FinishTime, uint256 StartAmount, address Owner)
        StakeInfo(address User, uint256 Id, uint256 LockedAmount, uint256 Earn, uint256 Duration)
<br>
if reward token and locked tokens do not match
        TransferIn(uint256 Amount, address From, address Token)
        TransferIn(uint256 Amount, address From, address Token)
        NewPoolCreated(uint256 PoolId, address Token, uint256 StartTime, uint256 FinishTime, uint256 StartAmount, address Owner)
        TransferIn(uint256 Amount, address From, address Token)
        NewPoolCreated(uint256 PoolId, address Token, uint256 StartTime, uint256 FinishTime, uint256 StartAmount, address Owner)
        StakeInfo(address User, uint256 Id, uint256 LockedAmount, uint256 Earn, uint256 Duration)
</pre></td>
<td><a href="https://testnet.bscscan.com/tx/0xbc07d08bfd0521c86dcef5e7023eeb26717e0ed2026a73dfe4646886313dc3bd#eventlog">Stake</a></td>
</tr>
<tr>
<td align="center"><b>WithdrawLeftOver</b></td>
<td align="left"><pre>
        TransferOut (uint256 Amount, address To, address Token)
        Transfer (index_topic_1 address from, index_topic_2 address to, uint256 value)
</pre></td>
<td><a href="https://testnet.bscscan.com/tx/0x69e24e8bf0659a755242eda78bf1be65c5640be544b84be91cacb9760be45050#eventlog">WithdrawLeftOver</a>
</td>
</tr>
</tbody>
</table>