// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

// Map데이터를 수정하는 부분입니다.
// 가스비를 고려하지 않고 최대한 DAO형태로 만들기 위해서 일단 컨트랙트로 모두 작동시킬 생각입니다.
import "./Character.sol";

interface event_interface {
    event Initialize(address owner, uint256 time);
    event Attact_Error(address attacker, uint256 map_index);
}

contract Map is event_interface {
    struct Map_Data {
        string Map_name;
        address Owner;
        uint256 index;
        uint256 award;
        string img_link;
        uint256 defenser;
    }

    Character private Char_contract;
    mapping(uint256 => Map_Data) public Map_Owner;
    uint256 private Total_MapAmount = 0;
    uint256 private Total_Owner = 0;

    constructor(
        string[] memory _Map,
        uint256[] memory _award,
        string[] memory _imgLink,
        address _char
    ) {
        // 컨트랙트가 시작될떄 일단 전체 데이터를 집어넣어줍니다.
        // 처음에는 점령한 땅이 없기 떄문에 0x0값을 넣어준다.
        for (uint256 i = 0; i < _Map.length; i++) {
            Map_Owner[i] = Map_Data(
                _Map[i],
                address(0x0),
                i,
                _award[i],
                _imgLink[i],
                0
            );
        }

        Total_MapAmount = _Map.length;
        Char_contract = Character(_char);
        emit Initialize(msg.sender, block.timestamp);
    }

    // char : 0xC8f5cBB372d2518536607fB6E5a5620b6830bab3

    function Attack_Map(uint256 Map_index, uint256 Soldier_Amount) public {
        // 해당 맵 데이터에 주인이 있는지를 확인해야함
        Map_Data storage map_data = Map_Owner[Map_index];
        require(map_data.Owner != msg.sender, "can't attack mySelf!!");

        // 만약 해당 맵에 주인이 없다면 바로 점령을 해준다.
        if (map_data.Owner == address(0x0)) {
            map_data.Owner = msg.sender;
            map_data.defenser = Soldier_Amount;
            // 이후 공격에 사용된 병사수를 캐릭터에서 뺴주어야 한다.
            (bool check, ) = address(Char_contract).call(
                abi.encodeWithSignature(
                    "Char_spend_Soldier(address,uint256)",
                    msg.sender,
                    Soldier_Amount
                )
            );
            if (!check) {
                revert();
            }
            // 공격에 성공하면 해당 주소에 토큰을 지급해 주어야 합니다.
            Char_contract.Gold_transfer(msg.sender, 3);
            Total_Owner++;
        } else {
            // 이곳은 맵에 주인이 있을떄의 상황을 말합니다.
            // 전투 부분이 필요한 부분이기 때문에 랜덤한 값을 통해서 전투를 이어 나갑니다.
            // 이 부분은 Character컨트랙트에서 다루고 있습니다
            // Character컨트랙트에서 다루는 이유는 간단합니다.
            // Map컨트랙트에는 Character부분을 다룰수 없기 떄문에
            // address 값을 보내주어서 해당 컨트랙트에서 전투를 펼치는 방향으로 진행할 예정입니다.
            // 또한 랜덤값을 Character컨트랙트에서 다루기 떄문에 사용합니다.
            // 전송할값 ->  방어병력, 공격자의 address, 공격병력
            bool result = Char_contract.Char_Battle(
                msg.sender,
                map_data.Owner,
                Soldier_Amount,
                map_data.defenser
            );

            if (result) {
                // result가 true라는 뜻은 공격자가 이겼다는 의미
                // 병력수는 이미 Character컨트랙트에서 제외를 했기떄문에 map데이터 갱신이 필요
                map_data.defenser = Soldier_Amount;
                map_data.Owner = msg.sender;
                // 공격자가 승리하였기 떄문에 Token을 지급
                Char_contract.Gold_transfer(msg.sender, 3);
            } else {
                // 방어자가 이기는 상황
                // 병력수는 마찬가지로 Character에서 빠져주었기 떄문에
                // 방어자에게 Token만 지급하면 됨
                Char_contract.Gold_transfer(map_data.Owner, 3);
            }
        }
    }

    function show_Map_Data() public view returns (Map_Data[] memory) {
        // MultiCall을 하여 한 화면에 모두 보이게 해야합니다.
        // 프론트에서 화면에 보이는 부분을 담당하게 됩니다.
        Map_Data[] memory AllMap = new Map_Data[](Total_MapAmount);

        for (uint256 i = 0; i < Total_MapAmount; i++) {
            AllMap[i] = Map_Owner[i];
        }

        return AllMap;
    }

    function Mypage_MyMap(address _address)
        public
        view
        returns (string[] memory)
    {
        // 점령한 땅을 보여주는 함수
        string[] memory MyMap = new string[](Total_Owner);
        uint256 index = 0;

        for (uint256 i = 0; i < Total_MapAmount; i++) {
            if (Map_Owner[i].Owner == _address) {
                MyMap[index] = Map_Owner[i].Map_name;
                index++;
            }
        }

        return MyMap;
    }

    function Map_Gold_MintAll() public {
        // Character부분에서 onlyOwner를 사용하기 떄문에 굳이 검사할 필요가 없다.
        // require(msg.sender == Owner,"This Function can be runned by Owner!!");
        address[] memory Winner = new address[](Total_Owner);
        uint256[] memory Token_Amount = new uint256[](Total_Owner);
        // owner 가 address(0x0)일떄는 제외를 시켜야 한다.
        uint256 index = 0;
        for (uint256 i = 0; i < Total_MapAmount; i++) {
            if (Map_Owner[i].Owner != address(0x0)) {
                Winner[index] = Map_Owner[i].Owner;
                Token_Amount[index] = Map_Owner[i].award;
                index++;
            }
            // 원래는 index따로 안두고 i를 활용하려고 했는데
            // address(0x0)인경우를 처리할수가 없어서 따로 인덱스 변수를 추가
        }
        // delegateCAll를 통해서 사용해야함
        // Character에서 onlyOwner를 사용하기 떄문에
        (bool check, ) = address(Char_contract).delegatecall(
            abi.encodeWithSignature(
                "Gold_mintAll(address[],uint256[])",
                Winner,
                Token_Amount
            )
        );
        if (!check) {
            revert();
        }
    }
}
