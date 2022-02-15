// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.0;

interface IERC721 {
    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external returns (bool);

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

contract NFT is IERC721, IERC721Metadata {
    string private constant _name = "destiny";
    string private constant _symbol = "DES";

    uint256 private _nftId = 0;

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;
    mapping(uint256 => string) public _tokenURIs;

    uint256 private _TotalNFTAmount = 0;

    constructor() {}

    function getNFT_List(address owner)
        internal
        view
        returns (string[] memory)
    {
        // 사용자가 소지한 모든 NFT를 받아오는 함수
        string[] memory NFT_List = new string[](_balances[owner]);
        uint256 index = 0;
        for (uint256 i = 0; i < _TotalNFTAmount; i++) {
            if (_owners[i] == owner) {
                NFT_List[index] = (_tokenURIs[i]);
                index++;
            }
        }
        return NFT_List;
    }

    function totalNFTAmount() external view returns (uint256) {
        return _TotalNFTAmount;
    }

    function getTokenURIs(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        return _tokenURIs[tokenId];
    }

    function mintNFT(address to, string memory URI) external returns (uint256) {
        _nftId++;
        _TotalNFTAmount++;
        uint256 newId = _nftId;

        _mint(to, newId);
        _setTokenURI(newId, URI);

        return newId;
    }

    function getOwner(uint256 tokenId) external view returns (address) {
        return _owners[tokenId];
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function getTotalNFTAmount() public view returns (uint256) {
        return _TotalNFTAmount;
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external override returns (bool) {
        // Character부분에서 이 조건을 검사하기 떄문에 주석처리해 줍니다.

        // require(
        //     _isApprovedOrOwner(from, tokenId),
        //     "ERC721: transfer caller is not owner nor approved"
        // );

        _Transfer(from, to, tokenId);
        return true;
    }

    function getNFT(uint256 _id) public view returns (string memory) {
        return _tokenURIs[_id];
    }

    function _Transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        // 이 부분도 검사를 해줍니다
        // -> Character 컨트랙트에서
        // require(
        //     NFT.ownerOf(tokenId) == from,
        //     "ERC721: transfer from incorrect owner"
        // );
        // require(to != address(0), "ERC721: transfer to the zero address");

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function balanceOf(address owner) public view override returns (uint256) {
        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view override returns (address) {
        address owner = _owners[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );
        return owner;
    }

    function name() external view virtual override returns (string memory) {
        return _name;
    }

    function symbol() external view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId))
                : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }
}
