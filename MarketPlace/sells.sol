// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";

contract TokenMarketPlace is Ownable, ReentrancyGuard {
    uint256 public feePercent;
    address public feeCollector;

    struct Listing {
        address seller;
        address tokenAddress;
        string tokenName;
        uint256 amount;
        uint256 pricePerToken;
        bool active;
    }

    // foward mappings to give each token a uniqu identifier
    mapping(uint256 => Listing) public listings;

    // reverse mapping that is linking to the tokens uniqu number identifier to a hash for easy lookup
    mapping(bytes32 => uint256) public listingKey;
    // mapping(address => address) sellerAddress;
    uint256 nextListingId = 1;

    event TokenListed(
        uint256 indexed listingId,
        address seller,
        address tokenAddress,
        uint256 amount,
        uint256 pricePerToken
    );

    event TokenAmountUpdated(
        uint256 indexed listingId,
        address _tokenAddress,
        uint256 amountUpdated,
        uint256 _newTokenPrice
    );

    constructor(uint256 _feePercentage, address _feeCollector)
        Ownable(msg.sender)
    {
        require(_feePercentage <= 10, "Fee must not exceed 10%");
        require(_feeCollector != address(0), "Invalid fee recipient address");

        feePercent = _feePercentage;
        feeCollector = _feeCollector;
    }

    function _generatekeyId(address token, address seller)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(token, seller));
    }

    function chekApproveAllowance(address _tokenAddress, address user)
        internal
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).allowance(user, address(this));
    }

   
    function creatListing(
        address _tokenAddress,
        uint256 _amount,
        uint256 _pricePerToken
    ) external nonReentrant {
        require(_tokenAddress != address(0), "Invalid token");
        require(_amount > 0, "Token amount can not be zero");
        require(_pricePerToken > 0, "Token price can not be zero");

        require(
            chekApproveAllowance(_tokenAddress, msg.sender) > 0,
            "You must approve this contract to use your tokens"
        );

        // check if the market place have enough approved token to list
        require(
            chekApproveAllowance(_tokenAddress, msg.sender) >= _amount,
            "Insufficient tokens"
        );

        // declare a token instance
        IERC20 token = IERC20(_tokenAddress);

        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Error while transferring tokens"
        );

        bytes32 keyId = _generatekeyId(_tokenAddress, msg.sender);

        if (listingKey[keyId] == 0) {
            listings[nextListingId] = Listing({
                seller: msg.sender,
                tokenName: IERC20Metadata(_tokenAddress).name(),
                tokenAddress: _tokenAddress,
                amount: _amount,
                pricePerToken: _pricePerToken,
                active: true
            });

            listingKey[keyId] = nextListingId;
            nextListingId++;
        } else {
            uint256 listingId = listingKey[keyId];
            require(listings[listingId].active, "this token is not active");

            listings[listingId].amount += _amount;
            listings[listingId].pricePerToken = _pricePerToken;
        }
    }

    function purchaseToken(uint256 _listingId, uint256 _amount)
        external
        payable
        nonReentrant
    {
        require(_amount > 0, "amount must be greater than zero");
        require(msg.sender != address(0), "_token address must be valid");

        Listing storage listing = listings[_listingId];

        require(listing.amount >= _amount, "_token amount not enough");
        require(listing.active, "this token is not active at the moment");

        uint256 totalpriceInEth = _amount * listing.pricePerToken;
        uint256 fee = (feePercent * totalpriceInEth) / 100;
        uint256 totalprice = totalpriceInEth + fee;

        require(msg.value >= totalprice, "insufficient ETH  sent");

        (bool feesuccess, ) = payable(feeCollector).call{value: fee}("");
        require(feesuccess, "Error while sending Eth to the feecollector");

        (bool success, ) = payable(listing.seller).call{value: totalpriceInEth}(
            ""
        );
        require(success, "Error while sending Eth to the seller");

        // Refund any excess ETH sent
        if (msg.value > totalprice) {
            payable(msg.sender).transfer(msg.value - totalprice);
        }

        if (_amount == listing.amount) {
            listing.active = false;
        } else {
            listing.amount -= _amount;
        }

        // transfer the token to the user

        IERC20 token = IERC20(listing.tokenAddress);
        // transfer the token to the user
        require(token.transfer(msg.sender, _amount), "Transaction failed");
    }

    function tokenBalanceByAddress(address _tokenAddress, address _account)
        public
        view
        returns (uint256)
    {
        return IERC20(_tokenAddress).balanceOf(_account);
    }

    function cancelListing(address _tokenAddress) external {
        bytes32 keyId = _generatekeyId(_tokenAddress, msg.sender);
        uint256 listingId = listingKey[keyId];

        require(
            listings[listingId].seller == msg.sender,
            "only the owner can cancel"
        );

        require(listings[listingId].active, "this token is not active");

        listings[listingId].active = false;
    }

    function reactivateListing(address _tokenAddress) external {
        bytes32 keyId = _generatekeyId(_tokenAddress, msg.sender);
        uint256 listingId = listingKey[keyId];

        require(
            listings[listingId].seller == msg.sender,
            "only the owner can cancel"
        );

        require(!listings[listingId].active, "this token is already active.");

        listings[listingId].active = true;
    }

    receive() external payable {}
}
