// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface TokenInterface {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transfer_all(address[] memory recipient, uint256[] memory amount)
        external
        returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 amount);
}

contract Token is TokenInterface {
    mapping(address => uint256) private _balances;

    uint256 private Token_totalSupply = 100000000000000000000000;
    string private constant _name = "GOLD";
    string private constant _symbol = "GD";

    constructor() {
        _balances[address(this)] = Token_totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        // 기본적인 토큰을 지급하는 행위
        _transfer(address(this), recipient, amount);
        emit Transfer(address(this), recipient, amount);
        return true;
    }

    function transfer_all(address[] memory recipient, uint256[] memory amount)
        external
        override
        returns (bool)
    {
        // 지분에  따른 토큰을 지급할떄 사용하는 함수
        // 최소 실행 가스비 21000을 줄이기 위해서 배열로 쏘고 있슴
        for (uint256 i = 0; i < recipient.length; i++) {
            transfer(recipient[i], amount[i]);
        }
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[sender] -= amount;
        _balances[recipient] += amount;
    }

    function transfer_To_CA(
        address recipient,
        address sender,
        uint256 amount
    ) external {
        // 상호간에 토큰 거래가 필요할떄 사용하는 함수
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            _balances[sender] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _balances[sender] -= amount;
        _balances[recipient] += amount;
    }

    function name() public pure returns (string memory) {
        return _name;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }

    function showSymbol() public pure returns (string memory) {
        return _symbol;
    }

    function totalSupply() public view override returns (uint256) {
        return Token_totalSupply;
    }
}
