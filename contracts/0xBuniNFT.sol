// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/heyOnuoha/ERC721A/blob/main/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract OxBuniNFT is ERC721A, Ownable {

    using Strings for uint256;
    address public contractOwner;

    bool public paused = false;
    bool public pausedFreeMint = false;

    uint256 public mintPrice = 0.07 ether;
    uint256 public preMintPrice = 0.05 ether;

    uint256 public presaleMaxNFTPerWallet = 3;
    uint256 public publicSaleMaxNFTPerWallet = 4;

    uint256 public supply = 2000;
    uint256 public teamSupply = 70;

    bool public revealed = false;

    string private unRevealedURI = "";
    string private baseURI = "";

    address public metaAlienContractAddress = 0xD36da67D3ABF056a32815484879d817596d37F99;
    IERC721 public metaAlienContract;

    mapping(address => bool) public metaAlienMinters;
    uint256 metaAliensFreeMintCount = 0;
    uint256 metaAliensFreeMintMax = 30;

    constructor() ERC721A ("0xBuni", "0XB", supply) {

        contractOwner = msg.sender;

        metaAlienContract = IERC721(metaAlienContractAddress);
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

    //Free Mints for holders
    function freeMintMetaAliens(uint256 quantity) external {

        require(!paused, "Contract paused");
        require(!pausedFreeMint, "Contract paused");
        require(metaAlienContract.balanceOf(msg.sender) > 0, "You are not eligible for this free mint");
        require(totalSupply() + quantity <= supply, "You can't mint more then the total supply");

        require(!metaAlienMinters[msg.sender], "No free mints!");
        require(metaAliensFreeMintCount <= metaAliensFreeMintMax, "Meta Aliens Free Mint Qouta Exceeded");

        metaAliensFreeMintCount = metaAliensFreeMintCount + 1;

        metaAlienMinters[msg.sender] = true;

        _safeMint(msg.sender, quantity);
    }

    function teamMint() onlyOwner external {

        require(totalSupply() + teamSupply <= supply, "You can't mint more then the total supply");

        _safeMint(msg.sender, teamSupply);
    }

    function mint(uint256 quantity) external payable {

        require(!paused, "Contract paused");
        require(totalSupply() + quantity <= supply, "You can't mint more then the total supply");

        uint256 senderSupply = balanceOf(msg.sender);

        if(msg.sender != owner()) {

            uint256 salePrice = mintPrice;

            if(!revealed) {

                require(quantity + senderSupply <= presaleMaxNFTPerWallet, string(abi.encodePacked("You have only ", presaleMaxNFTPerWallet - senderSupply, " available")));

                salePrice = preMintPrice;
            }

            require(quantity + senderSupply <= publicSaleMaxNFTPerWallet, string(abi.encodePacked("You have only ", publicSaleMaxNFTPerWallet - senderSupply, " available")));
            require(msg.value >= salePrice * quantity, "Insufficient funds");
            
        }
        
        _safeMint(msg.sender, quantity);
    }

    function mintForAddress(uint256 quantity, address recipient) external payable {

        require(!paused, "Contract paused");
        require(recipient != address(0), "Invalid reciever address");
        require(totalSupply() + quantity <= supply, "You can't mint more then the total supply");

        uint256 salePrice = mintPrice;

        uint256 senderSupply = balanceOf(recipient);

        if(!revealed) {

            require(quantity + senderSupply <= presaleMaxNFTPerWallet, string(abi.encodePacked("You have only ", presaleMaxNFTPerWallet - senderSupply, " available")));

            salePrice = preMintPrice;
        }

        require(quantity + senderSupply <= publicSaleMaxNFTPerWallet, string(abi.encodePacked("You have only ", publicSaleMaxNFTPerWallet - senderSupply, " available")));
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

    function setNotRevealedUrl(string memory unRevealedURI_) public onlyOwner { unRevealedURI = unRevealedURI_; }

    function _baseURI() internal view override returns (string memory) { return baseURI; }

    function setBaseURI(string memory baseURI_) external onlyOwner { baseURI = baseURI_; }

    function setMintPrice (uint256 _newPrice) public onlyOwner { mintPrice = _newPrice; }

    function setPaused (bool _pausedState) public onlyOwner { paused = _pausedState; }

    function setPausedFree (bool _pauseState) public onlyOwner { pausedFreeMint = _pauseState; }

    function getContractBalance () public view onlyOwner returns (uint256) { return address(this).balance; }

    function setMetaAlienContractAddress(address metaAlien_) public onlyOwner { metaAlienContract = IERC721(address(metaAlien_)); }

    function setPublicSaleMaxNFTPerWallet(uint256 max_) public onlyOwner { publicSaleMaxNFTPerWallet = max_; }

    function getNotRevealedURL() public view returns (string memory) { return unRevealedURI;}

    function changeTreasury(address payable _newWallet) external onlyOwner { contractOwner = _newWallet; }

    function withdraw() public payable onlyOwner {
        (bool os, ) = payable(contractOwner).call{value: address(this).balance}("");
        require(os);
    }
}