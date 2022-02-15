import { TokenDB } from "./models.js";
import Caver from "caver-js";
import dotenv from "dotenv";
import {
  Auction_abi,
  auction_CA,
  character_abi,
  character_CA,
} from "./abi,CA.js";

dotenv.config();

const caver = new Caver("https://api.baobab.klaytn.net:8651");

export const giveTokenBlockChain = async (req, res) => {
  const answer = await TokenDB.find({ check: false });

  if (answer.length > 0) {
    console.log(" ========== BlockChain기록 시작!===========");
    await caver.wallet.add(process.env.Server_PrivateKey);
    for (let i = 0; i < answer.length; i++) {
      if (answer[i].contract === "Character") {
        // character컨트랙트를 작동시킬시
        let tx = answer[i].tx;
        await caver.klay.accounts
          .signTransaction(tx, process.env.Server_PrivateKey)
          .then(async (Tx) => {
            await caver.klay.sendSignedTransaction(
              Tx.rawTransaction,
              (err, hash) => {
                if (err) console.log(err);
                else {
                  console.log(hash);
                }
              }
            );
          });
      } else {
        // auction컨트랙트를 작동시킬시
        let tx = answer[i].tx;
        await caver.klay.accounts
          .signTransaction(tx, process.env.Server_PrivateKey)
          .then(async (Tx) => {
            await caver.klay.sendSignedTransaction(
              Tx.rawTransaction,
              (err, hash) => {
                if (err) console.log(err);
                else {
                  console.log(hash);
                }
              }
            );
          });
      }
      await TokenDB.findOneAndUpdate(
        { _id: answer[i].id },
        {
          check: true,
        },
        {
          new: true,
        }
      );
    }
    console.log(" =========== BlockChain기록 완료 =========");
  } else {
    console.log("지급할 데이터가 없음!");
  }
};
//  Transaction was not mined within 750 seconds
