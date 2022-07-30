import express, { Request, Response, NextFunction } from 'express';
const { ethers } = require("hardhat");

const app = express();
// Request body를 parsing 하기 위한 미들웨어 사용
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.send('Crypto is eating the world!');
});

app.post('/mint', async (req: Request, res: Response, next: NextFunction) => {
    try {
        const Token = await ethers.getContractFactory("TelescopeToken");
        const name: string = req.body['name'];
        const ticker: string = req.body['ticker'];
        const DAOName: string = req.body['DAOName'];
        const intro: string = req.body['intro'];
        const image: string = req.body['image'];
        const link: string = req.body['link'];
        const initial_supply: string = req.body['initial_supply'];
        const owner: string = req.body['owner'];

        const hardhatToken = await Token.deploy(name, ticker, DAOName, intro, image, link, initial_supply, owner);
        const receipt = await hardhatToken.deployed();

        return res.status(200).send({
            hash: receipt.deployTransaction.hash,
            contractAddress: receipt.deployTransaction.creates,
        })

    } catch (err) {
        console.log(err);
        return res.status(500).send({
            error: err
        })
    }
});

app.listen('8080', () => {
    console.log(`
  ################################################
  🛡️  Server listening on port: 8080🛡️
  ################################################
`);
});