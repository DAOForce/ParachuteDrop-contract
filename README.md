# Parachute Drop Contract for HackAtom Seoul 2022
## Parachute Drop
* **`Parachute Drop`** is an *airdrop platform* running on **`Evmos`** purposed to enhance economic sustainability for DAOs.
* Launch your own DAO and airdrop tokens in serveral pre-scheduled batch rounds run dividedly / fully on-chain, only with a few initial settings.

## Problem
* Many crypto projects including awesome DAOs airdrops their governance token to initiate and activate their own token economy.
* However, airdrops are not working very ideally as people tend to sell the tokens right after they got them, without contributing or participating on the DAO governance.
* Dumping airdropped tokens in a short term could damage the sustainability of the projects and distort the token economy. 
* We suggest a novel solution to efficiently incentivize active supporters & token holders of the DAO in a long term of time, instead of in a single batch airdrop event.


## Solution
* We suggest 4 main features to solve mentioned problems:
1. Divide airdrop into 10 ~ 15 rounds with intervals of 3 ~ 6 months b/w each round
  1.1. Divided airdrops are executed as scheduled at the initial contract deployment, without additional off-chain operations.
2. Our `ERC20Trackable` token system, which is extension of `ERC20` tracks every single token transfer by users, recording snapshots of balance for each token holders
3. At each round of the airdrop, our `ScheduledAirdrop` contract calculates the `Holding Score` based on the amount and holding period during the previous airdrop rounds intervals.
4. As a new airdrop round launches, `Holding Scores` are calculated on-chain, distributing different amount of tokens to token holders.
5. No off-chain data input is required after the initial deployment of the contracts.

## How to keep track of users' balance of token 
Please follow this link
https://docs.google.com/document/d/11R5V5q38uc41Iu0GLragcQbfb6uuSFj7wGrOTU9E6ZM/edit?usp=sharing

## Dependencies
* @openzeppeline/contracts library
* Our ERC20 Token Contract `ERC20Trackable.sol`, specialized for DAO's airdrop division platform operation, inherits and overrides some key methods from `ERC20VotesComp.sol` Contract of @openzeppelin/contracts library.
