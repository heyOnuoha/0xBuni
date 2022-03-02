// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/chiru-labs/ERC721A/blob/main/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OxBuniNFT is ERC721A, Ownable {

    using Strings for uint256;
    address public contractOwner;

    bool public paused = false;

    uint256 public mintPrice = 0.07 ether;
    uint256 public preMintPrice = 0.05 ether;

    uint256 public presaleMaxNFTPerWallet = 3;
    uint256 public publicSaleMaxNFTPerWallet = 4;

    uint256 public supply = 2000;
    uint256 public teamSupply = 70;

    mapping(address => bool) public teamMinted;

    bool public revealed = false;

    string private unRevealedURI = "ipfs://QmdNszfEPEbdWWHp6uaJDhYatPsae2cWffs3Ag4vJPtu7n/1.json";
    string private baseURI = "ipfs://QmQM46aq4sfhHoaz1Z3Wh2pZmDc7WF9TiLmrTCLvPqf41F/";

    address public teamWallet = 0x37673969aab5FE047843579e7592Dc295ea411ac;

    constructor() ERC721A ("0xBuni", "0BUN") {

        contractOwner = msg.sender;
    }

    function reveal() public onlyOwner {

        revealed = true;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        if(!revealed) {

            return unRevealedURI;
        }

        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    function teamMint() onlyOwner external {

        require(totalSupply() + teamSupply <= supply, "You can't mint more then the total supply");
        require(!teamMinted[msg.sender], "Team has already minted");

        teamMinted[msg.sender] = true;

        _safeMint(teamWallet, teamSupply);
    }

    function mint(uint256 quantity) external payable {

        require(totalSupply() + quantity <= supply, "You can't mint more then the total supply");

        if(msg.sender != owner()) {

            uint256 senderSupply = balanceOf(msg.sender);

            require(!paused, "Contract paused");

            uint256 salePrice = mintPrice;

            if(!revealed) {

                require(quantity + senderSupply <= presaleMaxNFTPerWallet, string(abi.encodePacked("You can only mint ", presaleMaxNFTPerWallet.toString(), " NFTs at Presale")));

                salePrice = preMintPrice;
            }

            require(quantity + senderSupply <= publicSaleMaxNFTPerWallet, string(abi.encodePacked("You can only mint", publicSaleMaxNFTPerWallet.toString(), " NFTs at Main Sale")));
            require(msg.value >= salePrice * quantity, "Insufficient funds");
            
        }
        
        _safeMint(msg.sender, quantity);
    }

    function mintForAddress(uint256 quantity, address recipient) external payable onlyOwner {

        require(!paused, "Contract paused");
        require(recipient != address(0), "Invalid reciever address");
        require(totalSupply() + quantity <= supply, "You can't mint more then the total supply");

        uint256 salePrice = mintPrice;

        uint256 senderSupply = balanceOf(recipient);

        if(!revealed) {

            require(quantity + senderSupply <= presaleMaxNFTPerWallet, string(abi.encodePacked("You can only mint ", presaleMaxNFTPerWallet.toString(), " NFTs at Presale")));

            salePrice = preMintPrice;
        }

        require(quantity + senderSupply <= publicSaleMaxNFTPerWallet, string(abi.encodePacked("You can only mint ", publicSaleMaxNFTPerWallet.toString(), " NFTs at Main Sale")));
        require(msg.value >= salePrice * quantity, "Insufficient funds");
        
        _safeMint(recipient, quantity);
    }

    function getBaseURI() public onlyOwner view returns (string memory) {

        return baseURI;
    }

    function getMintPrice() public view returns (uint256) {

        if(!revealed) {

            return preMintPrice;
        }

        return mintPrice;
    }

    function setNotRevealedUrl(string memory unRevealedURI_) external onlyOwner { unRevealedURI = unRevealedURI_; }

    function _baseURI() internal view override returns (string memory) { return baseURI; }

    function setBaseURI(string memory baseURI_) external onlyOwner { baseURI = baseURI_; }

    function setMintPrice (uint256 _newPrice) external onlyOwner { mintPrice = _newPrice; }

    function setPaused (bool _pausedState) external onlyOwner { paused = _pausedState; }

    function getContractBalance () external view onlyOwner returns (uint256) { return address(this).balance; }

    function setPublicSaleMaxNFTPerWallet(uint256 max_) external onlyOwner { publicSaleMaxNFTPerWallet = max_; }

    function getNotRevealedURL() external onlyOwner view returns (string memory) { return unRevealedURI; }

    function changeTreasury(address payable _newWallet) external onlyOwner { contractOwner = _newWallet; }

    function setTeamWallet(address teamWallet_) external onlyOwner { teamWallet = teamWallet_; }

    function numberMinted(address owner) public view returns (uint256) { return _numberMinted(owner); }

    function totalMinted() public view returns (uint256) { return _totalMinted(); }

    function exists(uint256 tokenId) public view returns (bool) { return _exists(tokenId); }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(contractOwner).call{value: address(this).balance}("");
        require(os);
    }
}