// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;
import "./libraries/Token.sol";
import "./libraries/NFT.sol";

interface char {
    event NewUser(address indexed owner);
    event TokenPurchased(
        address indexed account,
        uint256 indexed amount,
        address indexed server
    );

    event Token_Transfer_All(address[] indexed account, uint256 indexed value);

    event Token_Sell(
        address indexed account,
        uint256 indexed amount,
        address indexed server
    );

    event token_transferError(address account, uint256 amount);
}

contract check_User {
    mapping(address => bool) public checkUser;
    address public owner;

    modifier isOwner(address _address) {
        require(checkUser[_address] == true);
        _;
    }
    modifier onlyOwner() {
        require(owner == msg.sender, "Not adming address!");
        _;
    }
}

contract Character is char, check_User {
    // Token : 0x273aC6a8F4BEE86B91CF6D1C25D00E1FD607d3a6
    // NFT : 0x3F82eFfbE8A3A1DCFabAA123Bbd19a32Fece5763

    mapping(address => My_Character) private _Character;
    mapping(uint256 => address) private _Character_for_Charge;
    uint256 private Total_User = 0;

    Token private gold;
    NFT private nft;

    uint256 constant PowFee = 30;
    uint256 constant limitFee = 50;
    uint256 constant NFT_Price = 50;

    struct My_Character {
        uint256 Pow;
        uint256 limit;
        uint256 Soldier_amount;
    }

    modifier check_balance(address _address, uint256 value) {
        require(gold.balanceOf(_address) >= value);
        _;
    }

    constructor(address _token, address _NFT) {
        gold = Token(_token);
        nft = NFT(_NFT);
        owner = msg.sender;
    }

    function buyTokens() public payable {
        require(msg.sender != address(0x0), "No Existed address");
        // 단위 계산이 wei로 들어오기 때문에 나눠준다.
        uint256 tokenAmount = msg.value / 100000000000;

        Gold_transfer_eachOther(msg.sender, address(gold), tokenAmount);

        // 괜히 delegatecall을 사용해보고 싶어서 만지작 대다가... onlnyOwner이라는 문제와 msg.sender이라는 문제에 막혀서 그냥 다른 함수를 사용하였습니다.
        // (bool success, ) = address(this or gold).delegatecall(abi.encodeWithSignature("transfer(address,uint256)", msg.sender, tokenAmount));

        // if(!success){
        //     emit token_transferError(msg.sender, tokenAmount);
        //     revert();
        // }

        // Uniswap에서 pair pool을 만들떄에 CA값을 활용하는 것을 보고 처음에는 payable(address(gold))로 적고 시도를 해보았다.
        // 근데 CA에는 transfer가 안된다는 것을 까먹고 계속 뭐가 문제인지를 파악하지 못했다...
        // pair pool이라는 CA값에 너무 집중했는지 쓸데 없는 시간을 낭비했던 부분;;
        // Swap이라고 부르기도 좀 그렇지만 유동성문제를 해결할수 없기 떄문에 활용가능한 범위에서만 코드를 적었습니다.
        address payable p_owner = payable(owner);
        p_owner.transfer(msg.value);

        emit TokenPurchased(msg.sender, tokenAmount, address(gold));
    }

    function sellTokens(uint256 value) public payable {
        // 사용자에게 이더를 전해주어야 하는데 어떤 방식으로 전해야 할지를 모르겟음;;
        // 사실상 서버가 실행하는 방향으로 하면 msg.value를 담아서 전송을 해주면 되는데..
        // 사용자가 직접 실행하고 처리하는 형태로 하고 싶은 고민이 있음

        require(msg.sender != address(0x0), "No Existed address");
        // Token을 CA주소로 반환하는 행위
        Gold_transfer_eachOther(address(gold), msg.sender, value);
        // wei로 들어올떄 100000000000만큼 나누어 줌
        // 나갈떄에는 Token의 양에 100000000000만큼 곱해주면됨
        uint256 Wei_amount = value * 100000000000 wei;

        address payable p_owner = payable(msg.sender);
        p_owner.transfer(Wei_amount);

        emit Token_Sell(msg.sender, msg.value, address(gold));
    }

    function NFT_minting(string memory URI) public isOwner(msg.sender) {
        // 아이템을 뽑을떄 실행시킬 트랜잭션
        require(
            Gold_balanceOf(msg.sender) >= NFT_Price,
            "NFT PRice is 50fee need more money"
        );
        nft.mintNFT(msg.sender, URI);

        Gold_transfer_eachOther(address(gold), msg.sender, NFT_Price);
    }

    function NFT_transfer(
        address buyer,
        uint256 Price,
        uint256 NFT_index
    ) external isOwner(msg.sender) {
        require(buyer != address(0), "Not Existed address");
        require(Gold_balanceOf(buyer) >= Price, "Buyer is not having Price");
        require(
            nft.ownerOf(NFT_index) == msg.sender,
            "The owner of this NFT is not msg.sender"
        );
        // 이전에는 1분마다 하루가 지난 거래를 확인하여 거래를 진행하였지만 이번에는
        // 사용자가 직접 원할떄에 버튼을 눌러서 거래가 되게 할 예정
        // 단순히 token 거래와 NFT이동만 시켜주면 된다.

        // 일단 토큰 거래를 해준다
        Gold_transfer_eachOther(msg.sender, buyer, Price);

        // 그후 NFT거래를 해준다.
        NFT_transferFrom(msg.sender, buyer, NFT_index);
    }

    function NFT_transferFrom(
        address owner,
        address buyer,
        uint256 NFT_index
    ) internal {
        nft.transferFrom(owner, buyer, NFT_index);
    }

    function Gold_transfer_eachOther(
        address recipient,
        address sender,
        uint256 value
    ) internal {
        // 이 부분은 CA와 사용자간의 거래를 하는 부분
        gold.transfer_To_CA(recipient, sender, value);
    }

    function Gold_transfer(address to, uint256 amount) public isOwner(to) {
        // 서버계정에서 사람들에게 token을 지급하는 부분
        gold.transfer(to, amount);
    }

    function Charge_Soldirt() public onlyOwner {
        // 캐릭터를 충전시켜주는 부분
        // 일정시간마다 작동을 시켜서 캐릭터를 충전 시켜줍니다.
        for (uint256 i = 0; i < Total_User; i++) {
            My_Character storage mycharacter = _Character[
                _Character_for_Charge[i]
            ];
            mycharacter.Soldier_amount = mycharacter.limit;
        }
    }

    function Gold_mintAll(address[] memory account, uint256[] memory amount)
        public
        onlyOwner
    {
        for (uint256 i = 0; i < account.length; i++) {
            require(checkUser[account[i]] != false, "not Existed User!");
            // 이런 검증 로직이 많아지면 가스비 소모가 증가하지만
            // 검증하는 부분을 뺴놓을수가 없어서...
        }
        gold.transfer_all(account, amount);
    }

    function Char_makeCharacter() public returns (bool) {
        // 기존에 없는 캐릭터여야 한다.
        // 서버가 실행하여 캐릭터를 만들어 준다.
        require(checkUser[msg.sender] == false);
        checkUser[msg.sender] = true;

        _Character[msg.sender] = My_Character(1, 300, 300);
        _Character_for_Charge[Total_User] = msg.sender;

        Total_User++;
        emit NewUser(msg.sender);

        return true;
    }

    function Char_IncreaseLimit()
        public
        isOwner(msg.sender)
        check_balance(msg.sender, limitFee)
    {
        // 자신이 가지고 있는 토큰을 gold의 CA주소에 반환해야 한다.
        Gold_transfer_eachOther(address(gold), msg.sender, limitFee);

        My_Character storage character = _Character[msg.sender];

        character.limit += 300;
    }

    function Char_IncreasePow()
        public
        isOwner(msg.sender)
        check_balance(msg.sender, PowFee)
    {
        // 자신이 가지고 있는 토큰을 gold의 CA주소에 반환해야 한다.
        Gold_transfer_eachOther(address(gold), msg.sender, PowFee);

        My_Character storage character = _Character[msg.sender];
        character.Pow += uint32(Char_getStatus());
    }

    function Char_getPow(address _address)
        public
        view
        isOwner(_address)
        returns (uint256)
    {
        My_Character memory character = _Character[_address];
        return character.Pow;
    }

    function Char_getLimit(address _address)
        public
        view
        isOwner(_address)
        returns (uint256)
    {
        My_Character memory character = _Character[_address];
        return character.limit;
    }

    function Char_spend_Soldier(address _Attacker, uint256 Soldier_amount)
        external
    {
        // Map컨트랙트에서 실행시키는 함수
        // address에 해당하는 캐릭터의 병사수를 줄인다.
        My_Character storage character = _Character[_Attacker];
        require(
            character.Soldier_amount >= Soldier_amount,
            "need more Soldier"
        );
        character.Soldier_amount -= Soldier_amount;
    }

    function Char_Battle(
        address _Attacker,
        address _Defenser,
        uint256 _Attack_Amount,
        uint256 _Defen_Amount
    ) external returns (bool) {
        My_Character storage Attacker = _Character[_Attacker];
        My_Character memory Defenser = _Character[_Defenser];

        uint256 Random_Number_For_Attacker = Char_getStatus();

        uint256 Attack_Power = Attacker.Pow *
            Random_Number_For_Attacker +
            _Attack_Amount;

        uint256 Random_Number_For_Defenser = Char_getStatus();

        uint256 Defense_Power = Defenser.Pow *
            Random_Number_For_Defenser +
            _Defen_Amount;

        if (Attack_Power > Defense_Power) {
            // 공격자가 이기는 상황
            // 이러면 Map데이터를 갱신시키고 공격자의 병력수를 뺴야함
            Attacker.Soldier_amount -= _Attack_Amount;
            // Map데이터는 Map컨트랙트에서 조율
            return true;
        } else {
            // 방어자가 이기는 상황
            // 단순히 공격자의 병력수를 뺴주면됨
            Attacker.Soldier_amount -= _Attack_Amount;
            return false;
        }
    }

    function Char_getUser(address _address)
        public
        view
        isOwner(_address)
        returns (My_Character memory)
    {
        return _Character[_address];
    }

    function Char_getRandomNumber() internal view returns (uint256) {
        // 오라클적인 문제점을 해결하기 위해서
        // 계속 변화할수 있는 tokenCA가 가지고 있는 토큰의 양을 인자르 넘겨 주엇다
        // token트랜잭션에 따라서 계속 변화할 것이기 떄문에
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        Gold_balanceOf(address(gold))
                    )
                )
            ) % 100;
    }

    function Char_getStatus() private view returns (uint256) {
        // 이 함수는 따로 랜덤한 값을 받기 위해서 사용을 해야 하기 떄문에 public로 선언
        return Char_getRandomNumber() % 10;
    }

    function Gold_balanceOf(address _address) public view returns (uint256) {
        return gold.balanceOf(_address);
    }

    function getNFT_List(address owner)
        public
        view
        onlyOwner
        isOwner(owner)
        returns (string[] memory)
    {
        // 사용자가 소지한 모든 NFT를 받아오는 함수
        string[] memory NFT_List = new string[](nft.balanceOf(owner));
        uint256 index = 0;
        for (uint256 i = 1; i <= nft.totalNFTAmount(); i++) {
            if (nft.getOwner(i) == owner) {
                NFT_List[index] = (nft.getTokenURIs(i));
                index++;
            }
        }
        return NFT_List;
    }

    function check_NFT_Owner(uint256 NFT_index)
        external
        view
        returns (address)
    {
        return nft.ownerOf(NFT_index);
    }

    function get_NFT_Item(uint256 NFT_index)
        external
        view
        returns (string memory)
    {
        return nft.getTokenURIs(NFT_index);
    }
}

// 0xE7a622d46A767B313aF9DC71c76446299B246140

// 0xE7a622d46A767B313aF9DC71c76446299B246140
