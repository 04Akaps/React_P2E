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
        uint256 Item;
        address Owner;
        address Buyer;
        uint256 price;
        Status status;
    }

    function Make_Bidding(uint256 NFT_index, uint256 _price) public {
        // 일단 NFT주소를 확인하게 됩니다.
        require(
            Char_contract.check_NFT_Owner(NFT_index) == msg.sender,
            "Not Your item"
        );
        // 일단 값을 가져와 봅니다.
        Bidding_System storage bidding_system = Bidding_struct[NFT_index];
        // 기존에 경매중이 물품은 경매에 다시 올릴수 없게 require문을 추가 합니다.
        require(bidding_system.status != Status.Bidding, "already on Bidding");
        // 기존에 경매가 끝나서 다시 경매를 하는 경우에는 문제가 없습니다.
        // 왜냐하면 그냥 오로지 경매 상태를 다시 갱신시켜 주면 됩니다.
        // 그러기 떄문에 단순히 bidding인 경매물품만을 걸러주는 역할을 수행하고 있습니다.
        if (bidding_system.Owner != address(0x0)) {
            // Owner가 기존에 존재한다는 소리는
            // 이미 거래가 한번 이루어 졌다는 소리이기 떄문에 단순히 값을 갱신해 줍니다.
            bidding_system.Owner = msg.sender;
            bidding_system.Buyer = address(0x0);
            bidding_system.price = _price;
            bidding_system.status = Status.start;
        } else {
            // 반대로 값이 없다는 소리에 처음하는 거래라는 의미이기 떄문에 일단 mapping값을 할당해 줌으로써 작동을 합니다.
            Bidding_struct[NFT_index] = Bidding_System({
                Item: NFT_index,
                Owner: msg.sender,
                Buyer: address(0x0),
                price: _price,
                status: Status.start
            });
        }
        // 새롭게 값이 만들어지는 행위이기 떄문에 마찬가지로 증가시켜 줍니다.
        total_Amount++;
    }

    // 판매자는 존재하고 있는데 구매자가 아직 아무런 bidding을 하지 않았을떄
    // 첫 biiding인 경우 실행
    function First_Bidding(uint256 NFT_index, uint256 _price)
        public
        returns (bool)
    {
        Bidding_System storage bidding_system = Bidding_struct[NFT_index];
        // 거래가 기록이 되었을떄 첫번쨰에는 이 함수를 통해서 경매를 진행합니다.
        // 배팅자의 토큰이 있는지를 확인하고
        // 현재 등록된 상품 가격보다 더 높은 가격인지를 확인합니다.
        require(
            bidding_system.Owner != msg.sender,
            "Owner can't bidding myself"
        );
        require(
            bidding_system.status == Status.start,
            "this is not existed Item"
        );
        require(
            Char_contract.Gold_balanceOf(msg.sender) >= _price,
            "Bidder must have more money"
        );
        require(bidding_system.price < _price, "bidding more money!!");

        bidding_system.Buyer = msg.sender;
        bidding_system.price = _price;
        bidding_system.status = Status.Bidding;

        return true;
    }

    function Bidding_after(uint256 NFT_index, uint256 _price)
        public
        returns (bool)
    {
        // 첫번째 bidding에는 윗에있는 함수를 사용하지만 이후의 bidding은 이함수를 사용하게 됩니다.
        Bidding_System storage bidding_system = Bidding_struct[NFT_index];
        // bidding상태인 상품과, 거래 배팅자가 자기 자신이 아니라는 조건을 추가해 줍니다.
        require(
            bidding_system.status == Status.Bidding,
            "before start this function, need to be stated Fist_Bidding"
        );
        require(
            bidding_system.Owner != msg.sender,
            "Owner can't bidding myself"
        );
        // 이후 금액을 확인해야 합니다.
        require(
            Char_contract.Gold_balanceOf(msg.sender) >= _price,
            "Bidder must have more money"
        );
        require(bidding_system.price < _price, "bidding more money!!");

        // 이후 데이터를 갱신시켜 줌으로써 작동을 하게 됩니다.
        bidding_system.Buyer = msg.sender;
        bidding_system.price = _price;

        return true;
    }

    function end_bidding(uint256 NFT_index) public returns (bool) {
        // 일단 해당 bidding을 가져옵니다.
        Bidding_System storage bidding_system = Bidding_struct[NFT_index];
        // 경매중인 상태인 종료 시켜야 하기 떄문에 require문을 통해서 확인
        require(bidding_system.status == Status.Bidding);
        // 그후 상태를 갱신 시키고 NFT를 이동시켜 줌과 동시에 Token거래를 유발 합니다.
        bidding_system.status = Status.end;

        // Char_contract.NFT_transfer();에서 msg.sender 를 사용하고 있기 때문에 delegatecall을 사용합니다.
        (bool success, ) = address(Char_contract).delegatecall(
            abi.encodeWithSignature(
                "NFT_transfer(address,uint256,uint256)",
                bidding_system.Buyer,
                bidding_system.price,
                NFT_index
            )
        );

        // NFT_transfer의 경우에는 msg.sender가 가지고 있는 nft를 전송하는 역할입니다.
        // 그러기 떄문에 인자로 들어가는 address는 수령자가 되며 그러기 떄문에 이부분에는 buyer가 들어가게 됩니다.
        // 두번쨰 인자는 가격을 의미하고 마지막 인자는 NFT번호를 의미합니다.
        if (!success) {
            revert();
        }
        // 거래가 한개 줄어들기 떄문에 총 수량을 제외시킨다.
        total_Amount--;
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

    function get_Bidding_Status(uint256 index)
        public
        view
        returns (Bidding_System memory)
    {
        return Bidding_struct[index];
    }
}
