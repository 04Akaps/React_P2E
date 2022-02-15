import { character_abi } from "../Klaytn/abi_total.js";
import { character_CA } from "../Klaytn/CA_total.js";

export const get_contract = async (req, res) => {
  res.status(200).send({ CA: character_CA, abi: character_abi });
};
