import { CharacetrDB, UserDB } from "../models.js";
import { web3, makeCharacter } from "../web3/web3.js";

import jwt from "jsonwebtoken";

const { ACCESS_SECRET } = process.env;

export const makeUser = async (req, res) => {
  const ID = req.body.ID;
  const password = req.body.password;

  const IdCh = await UserDB.find({ ID: ID });

  if (IdCh.length !== 0) {
    res.status(200).send({ message: "아이디 중복!" });
  } else {
    const answer = web3;
    const account = await web3.eth.accounts.create();

    const makeUser = await new UserDB({
      ID: ID,
      password: password,
      address: account.address,
      privateKey: account.privateKey,
    });
    makeUser.save();

    const makeDBCharacter = await new CharacetrDB({
      address: account.address,
    });
    makeDBCharacter.save();
    makeCharacter(account.address);
    res.status(200).send({
      message: "아이디 생성 완료!",
      User: makeUser,
    });
  }
};

export const AllUser = async (req, res) => {
  const all = await UserDB.find();
  res.status(200).send({ message: "all user", data: all });
};

export const Login = async (req, res) => {
  const ID = req.body.ID;
  const password = req.body.password;
  const ch = await UserDB.find({ ID: ID, password: password });

  if (ch.length === 0) {
    res.status(500).send({ message: "실패.." });
  } else {
    const accessToken = await jwt.sign(
      { ID: ID, address: ch[0].address },
      ACCESS_SECRET,
      {
        expiresIn: "1h",
      }
    );

    res.status(200).send({ message: "로그인 성공!", Token: accessToken });
  }
};

export const vefiry = async (req, res) => {
  let temp = req.headers.authorization.split(" ")[0];
  let answer = "";

  for (let i = 1; i < temp.length - 1; i++) {
    answer += temp[i];
  }

  let data = jwt.verify(answer, ACCESS_SECRET);

  const User = await UserDB.findOne({ ID: data.ID });
  const Character = await CharacetrDB.findOne({ address: data.address });

  const sendData = {
    address: User.address,
    HavingLands: User.HavingLands,
    Soldier: User.Soldier,
    Token: User.Token,
    Pow: Character.Pow,
    limit: Character.limit,
  };

  res.status(200).send(sendData);
};

export const vefiry_google = async (req, res) => {
  const User = await UserDB.findOne({ address: req.body.address });
  const Characetr = await CharacetrDB({ address: req.body.address });

  if (User === null) {
    const User = await new UserDB({ address: req.body.address });
    User.save();

    const Characetr = await new CharacetrDB({ address: req.body.address });
    Characetr.save();
    makeCharacter(req.body.address);
    // 컨트랙트를 통해서 캐릭터를 만들어 주어야함
    const sendData = {
      address: req.body.address,
      HavingLands: User.HavingLands,
      Soldier: User.Soldier,
      Token: User.Token,
      Pow: Characetr.Pow,
      limit: Characetr.limit,
    };
    res.status(200).send({ message: "new Character", data: sendData });
  } else {
    const sendData = {
      address: req.body.address,
      HavingLands: User.HavingLands,
      Soldier: User.Soldier,
      Token: User.Token,
      Pow: Characetr.Pow,
      limit: Characetr.limit,
    };
    res.status(200).send({ message: "already User", data: sendData });
  }
};
