# ParachuteDrop (DAOForce)
![Frame 5927 (1)](https://user-images.githubusercontent.com/91793849/191650040-b643a65f-34db-4d00-9a36-d6be978207d9.png)


## Inspiration
There are three main pain points in the current DAO system regarding airdrop and delegation on Cosmos.

Airdrop becomes the primary strategy for communities and DAOs to boost the community. Average airdrop allocation has been increased from 0% in 2019 to 15% in 2021. However, we find out two crucial problems in the current airdrop system. First, People who often dump their airdrop tokens. Considering that Dex is where most tokens are listed, their price would get lower and lower as liquidity has drawn in the pool. As a result, the faster you dump your token, the more fiat you could get. If a situation gets severe, the token economy could collapse, which would cause damage to sustainability. Even if it’s not that critical, dumping airdrop tokens arouse disbelief and conflict in many DAOs and demotivate their members.

Second, it’s impossible to exclude someone who might sell her tokens. There is a strategy to target users who would not sell their tokens by analyzing data, but it’s not a perfect solution as data only shows the history. It means you can’t manage their future actions. In many cases, it ends in an incentive alignment failure because receivers who dump their tokens earn more rewards than holding tokens.

The last one is IBC integration. Cosmos ecosystem would integrate into IBC and more assets would be transferred across chains. It implies that strategies to improve token airdrop should embrace cross-chains data rather than relying on one chain. However, there are no application that could track cross-chain assets and airdrop tokens.

## What it does
We suggest two main features for the solution

![Frame 5932 (1)](https://user-images.githubusercontent.com/91793849/191650353-6864e077-9b49-42c3-ac60-b861a0bdbfcd.png)

**1) Airdrop Vesting Model**: We adopt the vesting option for airdrop but reflect loyalty. The amount of airdropped tokens would be changed in proportion to tokens that had been sold. For example, WEB3 DAO which is trying to mint WEB3 tokens would divide their airdrop into 10 rounds at 6 months intervals. Alice, who got a token airdrop in the first round sold half of her tokens immediately. In the next round, she would get only half of the number of tokens that she could have received.

Let’s find out how the calculation mechanism of our platform. We will reflect how many tokens receivers sell and the period receivers hold. So, in this picture, the x-axis is the period, and the y-axis is the number of tokens one holds. Let k as the number of token receivers got, and n as the number of blocks during the interval. We will compute the sum of the area of red rectangles, and divide it by the total area, which is n multiplies k. So receivers would get tokens as this formula: original amounts * (1-sum of red rectangles/total area). We will not consider whether receivers have more than k or not.

Let’s take an example. Telescope DAO is going to mint and airdrop their governance token. it sets 10 rounds, with 6 months intervals. Alice could get 1,000 tokens from telescope DAO in total. So she gets 100 tokens for the first round.

Alice then sold half of her token she got airdropped after 3 months.

Alice claims her shares when the 2nd airdrop round is open. Telescope DAO computes the area colored in red on the graph and divides it into total areas below 100. It wouldn’t consider whether it’s over 100 or not. As Alice sold half of her tokens 3 months later, the red area is 3*50 = 150 in this case. Since the total area is 6*100 = 600, Alice would get her token as the formula here, which is 75 tokens.

During the second interval, Alice held 125 tokens when the second interval began. And at this time, she bought 75 tokens after 3 months from the second airdrop round.

Alice would claim her tokens When round 3 started. Telescope DAO again checks her accounts. As Alice bought 75 tokens 9 months later from the first token airdrop round, the red areas would be 75 * 3 = 225. As the total area is 200 * 6 = 1200 in the third round, Alice would get her tokens as this formula, which is 81.25 tokens. As you can see, Alice could alleviate the penalty of selling tokens by buyback tokens.

![Frame 5970](https://user-images.githubusercontent.com/91793849/191650407-4dc6ab78-9885-4ead-b03e-e0c6b57c56e8.png)

**2) Cross-chain token tracking** Cosmos ecosystem would be expanded across various chains using IBC. It implies that users would move their tokens from Evmos to Osmosis. In Parachute Drop, projects could find out whether airdrop receivers sold their tokens or not, not only in the Evmos but also in various chains integrated with IBC.

## How we built it

![Frame 5939](https://user-images.githubusercontent.com/91793849/191650462-5f1c89f9-facb-458c-8731-427445345962.png)

Parachute drop consist of three main parts. First is constructing airdrop. Deploy ContractInfo.sol (contract for storing metadata) and insert address of ContractInfo.sol to DAOForceToken.sol constructor . Next, Insert DAOForceToken.sol to DAOForceGovernance.sol and deploy it. This is the process for deploying airdrop contract. DAO managers can repeat this process if they want the next airdrop. Second is tracking DAO transfer and calculation. ERC20Trackable is an extension for calculating token amount receivers are holding. It will save structure mapping like a snapshot whenever token transfer occurs. Users could claim their tokens when the next airdrop round begins. Claimairdrop function will call initiate airdrop amounts function. And then it will call compute airdrop amounts function. Airdrop amount receivers can get will be calculated in this process. The last one is IBC integration. We conduct mapping ERC20 on Evmos to sdk.Coin type by the governance proposal. Event listener for ConvertERC20would track transactions. For now, we rely on server to manage data, but there will be light clients to manage data in decentralized way.

## Challenges we ran into
While building the project, we faced 3 big obstacles: Which calculation mechanism should we use, how can we capture data, and how can we track tokens across IBC.

For the first obstacle, we focus on the period and amount of tokens to determine one’s loyalty. We consider one’s consistent interest as loyalty to the project. To reflect this idea, we set an ideal model in numeric form (token amount for y-axis, period for x-axis) for token holding across the entire airdrop rounds, and calculate the difference between the ideal model and the actual data. The ratio of the difference against the ideal model would be used to decide how many tokens it should airdrop.

The second obstacle is that it's difficult to get data of future events fluently without a server since we should gather raw data from the blockchain itself. However, we want to decentralize the airdrop by eliminating the exterior solution and relying on the blockchain. To solve this problem, we insert a snapshot feature on the token minting model. If someone transfers its token, the transaction would be recorded like a snapshot. With this snapshot feature, our platform could easily capture transaction data for calculation.

For the last one, we track records when ERC20 in Evmos become sdk.Coin. As ERC20 tokens on Evmos moves to other chains, it would be converted to sdk.Coin. In the long term, we will develop light client to track data across cosmos ecosystem.

## Accomplishments that we're proud of
We are proud of three main features. First, we designed the token airdrop system that reflects loyalties not only to the past but also to the future. It gives receivers an incentive for holding tokens rather than dumping them, which could enhance sustainability and incentive alignment. Second, we came up with a measurement system for loyalty. It’s a challenging idea to integrate smart contracts with a trading record in a decentralized method - without servers. To achieve this purpose, we build a snapshot system and use snapshot records for smart contracts. The last thing is IBC aggregation. To track IBC transfer, we subscribe Evmos tendermint web socket to capture "Convert ERC20" event and "Convert Coin" event. In the near future, we will build a light client for more data.

## What we learned
While building the structure of Parachute Drop, we learned more about basic concepts of Evmos and its ecosystem, and how IBC integrates with Evmos.

Evmos is a blockchain built on Cosmos SDK for EVM compatibility. It could bring the Ethereum ecosystem to Cosmos which eventually expands it. Other blockchains on Cosmos SDK use Rust as their language. However, as Evmos provide EVM compatible environment, we wrote our codes in Solidity, and it has worked without extra actions. With this experiment, we learned how convenient Evmos is in terms of development.

We also find out how Evmos communicates with other chains through IBC. What’s important is that IBC is more secure than bridges, and it supports various options that bridges couldn’t. It makes us possible to aggregate and record data across many blockchains in a secure way. We believe that IBC has a lot of potential to expand utilities and usage of blockchains.

## What's next for Parachute Drop
We will go beyond the airdrop platform. The current Cosmos ecosystem lacks DAO infrastructure compared to Ethereum. Also, it’s challenging to develop DAO infrastructure in many Cosmos chains. As a result, there are not many DAOs in the Cosmos ecosystem.

So we are trying to make a gateway to a cross-chain ecosystem. Parachute Drop is just the beginning. We will bring Ethereum-based DAO tooling to the Cosmos ecosystem. First, we will add a Snapshot-style voting platform across IBC. Another project that we are going to get is that guild.xyz-style role management platform, coordinape-style compensation tooling, and juice box-style fundraising platform.

With our DAO tooling platform, Evmos would be the infrastructure of cross-chain DAOs in the Cosmos ecosystem.

## Evmos momentum hackathon Devpost submission
https://devpost.com/software/parachute-drop

## Presentation link
https://www.figma.com/proto/s0VnXDwK2bnJGUSLe8QPMa/Parachute-Drop_PPT?page-id=28%3A1027&node-id=28%3A1027&starting-point-node-id=28%3A1028&scaling=contain
