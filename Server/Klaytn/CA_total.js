import fs from "fs";
const basePath = "/Users/yuhojin/Desktop/React_P2E";
import path from "path";

export const character_CA = fs.readFileSync(
  path.join(basePath, "/truffle/CA/character_CA"),
  {
    encoding: "utf-8",
  }
);

export const auction_CA = fs.readFileSync(
  path.join(basePath, "/truffle/CA/auction_CA"),
  {
    encoding: "utf-8",
  }
);
