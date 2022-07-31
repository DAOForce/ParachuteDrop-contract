# Parachute Drop Contract for HackAtom Seoul 2022
## Purpose
* **`Parachute Drop`** is an *airdrop platform* running on **`Evmos`** purposed to enhance economic sustainability for DAOs.
* Launch your own DAO and airdrop tokens in serveral pre-scheduled batch rounds run dividedly / fully on-chain, only with some initial settings.

## Problem
* More and more projects are using airdrop to distribute their tokens and initiate their token economy.
* However, airdrops are not working very ideally on many projects as people tend to sell airdropped tokens right after they got them, without contributing or participating on the DAO governance.
* However, you cannot perfectly identify and exclude people from airdrop who are willing to sell their tokens. 
* Selling airdropped tokens in a short term could damage the sustainability of projects and distort the token economy. 
* Also, many DAOs and projects make token receivers delegate their voting powers during the airdrop process. But receivers won’t change their delegation and neglect it.

## Solution
* We suggest 4 main features to solve mentioned problems:
1. Divide airdrop into 10 ~ 15 rounds with intervals of 3 ~ 6 months b/w each round
  1.1. Divided airdrops are executed as scheduled at the initial contract deployment, without additional off-chain operations.
2. Our `ERC20Trackable` token system, which is extension of `ERC20`
3. DAO/projects would check whether airdrop receivers have sold their tokens or not when the next round has begun. 
4. Receivers would get token proportionate to amounts of tokens they have been holding during the interval, and delegate its token to another one. (in case of governance token)

## How to keep track of users' balance of token 
Please follow this link
https://docs.google.com/document/d/11R5V5q38uc41Iu0GLragcQbfb6uuSFj7wGrOTU9E6ZM/edit?usp=sharing

## Dependencies
* @openzeppeline/contracts library
* Our ERC20 Token Contract `ERC20Trackable.sol`, specialized for DAO's airdrop division platform operation, inherits and overrides some key methods from `ERC20VotesComp.sol` Contract of @openzeppelin/contracts library.
