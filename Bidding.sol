// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

import "./Character.sol";

contract Bidding {
    Character private Char_contract;
    mapping(uint256 => Bidding_System) private Bidding_struct;
    uint256 private total_Amount = 0;

    constructor(Character _Character) {
        // Character컨트랙트를 할당해 준다.
        // 상속하는 방향으로 진행을 하면 character에서 constructor부분을 다룰수가 없음
        // 그리고 사실 컨트랙트 구조가 상당히 계획없이 짠거 같아서 수정하기에는 너무 먼길..
        Char_contract = _Character;
    }

    enum Status {
        start,
        Bidding,
        end
    }

    struct Bidding_System {
        string Item;
        address Owner;
        address Buyer;
        uint256 price;
        Status status;
    }

    function Make_Bidding(uint256 NFT_index, uint256 _price) public {
        // 일단 NFT주소를 확인하게 됩니다.
        require(Char_contract.check_NFT_Owner(NFT_index) == msg.sender);
        Bidding_System memory bidding_system = Bidding_struct[NFT_index];
        // 기존에 경매중이 물품은 경매에 다시 올릴수 없게 require문을 추가 합니다.
        require(bidding_system.status != Status.Bidding, "already on Bidding");
        // bidding을 시작합니다.
        Bidding_struct[NFT_index] = Bidding_System({
            Item: Char_contract.get_NFT_Item(NFT_index),
            Owner: msg.sender,
            Buyer: address(0x0),
            price: _price,
            status: Status.start
        });
        total_Amount++;
    }

    function First_Bidding(uint256 NFT_index, uint256 _price)
        public
        returns (bool)
    {
        Bidding_System storage bidding_system = Bidding_struct[NFT_index];
        // 거래가 기록이 되었을떄 첫번쨰에는 이 함수를 통해서 경매를 진행합니다.
        require(
            bidding_system.status == Status.start,
            "this is not existed Item"
        );
        require(
            Char_contract.Gold_balanceOf(msg.sender) >= _price,
            "Bidder must have more money"
        );

        bidding_system.Buyer = msg.sender;
        bidding_system.price = _price;
        bidding_system.status = Status.Bidding;

        return true;
    }

    function MultiCall_Bidding() public view returns (Bidding_System[] memory) {
        // 화면에 거래 목록들을 보여주는 부분 입니다.
        Bidding_System[] memory bidding = new Bidding_System[](total_Amount);
        for (uint256 i = 0; i < total_Amount; i++) {
            bidding[i] = Bidding_struct[i];
        }
        return bidding;
    }
}
