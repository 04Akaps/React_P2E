import React from "react";
import "./MyPage.scss";
import { Link } from "react-router-dom";

import Web3 from "web3";
import erc20Abi from "../../abi/erc20Abi";
import { NFTList } from "../main";

function MyPage({ address, user }) {
  // const [account, setAccount] = useState();
  // const [inputValue, setInputValue] = useState();
  // const [erc20TokenAddr, setErc20TokenAddr] = useState();
  // const [sendToAddr, setSendToAddr] = useState();
  // console.log(address);
  // const connectWallet = async () => {
  //   if (window.ethereum === undefined) {
  //     alert("메타마스크를 설치해 주세요!");
  //   }
  //   const accounts = await window.ethereum.request({
  //     method: "eth_requestAccounts",
  //   });
  //   setAccount(accounts[0]);
  // };

  // const generateToken = async () => {
  //   const web3 = new Web3(window.ethereum);
  //   const contract = new web3.eth.Contract(erc20Abi, inputValue);
  //   setErc20TokenAddr(inputValue);
  //   setInputValue("");
  //   console.log(contract.methods);
  //   const tokenSymbol = await contract.methods.symbol().call();

  //   const tokenDecimals = 18;
  //   const tokenImage =
  //     "https://images.unsplash.com/photo-1582573732277-c5444fa37391?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2187&q=80";

  //   try {
  //     const wasAdded = await window.ethereum.request({
  //       method: "wallet_watchAsset",
  //       params: {
  //         type: "ERC20",
  //         options: {
  //           address: erc20TokenAddr,
  //           symbol: tokenSymbol,
  //           decimals: tokenDecimals,
  //           image: tokenImage,
  //         },
  //       },
  //     });

  //     if (wasAdded) {
  //       console.log("토큰 생성!");
  //     } else {
  //       console.log("실패!");
  //     }
  //   } catch (error) {
  //     console.log(error);
  //   }
  // };
  // //0xEB1f0b20ddc161557f78748193c8a9713e65D496
  // const sendErc20Token = async () => {
  //   const web3 = new Web3(window.ethereum);
  //   const contract = await new web3.eth.Contract(erc20Abi, erc20TokenAddr);
  //   console.log(await contract.methods.balanceOf(account).call());
  //   const tokenDecimals = web3.utils.toBN(18);
  //   const tokenAmountToTransfer = web3.utils.toBN(10000);
  //   const calculatedTransferValue = web3.utils.toHex(
  //     tokenAmountToTransfer.mul(web3.utils.toBN(10).pow(tokenDecimals))
  //   );
  //   // const checkValiable = await contract.methods
  //   //   .transferFrom(account, sendToAddr, calculatedTransferValue)
  //   //   .call();
  //   // console.log(checkValiable);
  //   if (sendToAddr) {
  //     await contract.methods
  //       .transfer(sendToAddr, calculatedTransferValue)
  //       .send({ from: account })
  //       .on("transactionHash", (hash) => {
  //         console.log(hash);
  //         setSendToAddr("");
  //       });
  //   }
  // };

  return (
    <>
      <div className="MyPage_App">
        <div className="Status_title">
          <h2>Welcome to Your Page</h2>
          <h2> You can See your Status and Equiment</h2>
          <h2> Enjoy Your Time</h2>
        </div>
        <div className="Status_Status">
          <div>아이디 : 룰루랄라</div>
          <div>주소 : 0xAea07E179dFC59dD118005A4A56768a51aD8F48b</div>
          <div>캐릭터이름 : 비숑은 커엽다</div>
          <div>PoW : 어쩃든 존나썜</div>
          <div>병력수 : 3000</div>
        </div>

        <div className="MyPage_Title">
          <img src="./img/MYpage.jpeg" alt="mypage" />
        </div>
      </div>
      <div className="Status_app">
        <div className="Status_container">
          <NFTList />
          <NFTList />
          <NFTList />
        </div>
      </div>
    </>
  );
}

export default MyPage;
