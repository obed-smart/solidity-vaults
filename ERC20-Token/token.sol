// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20T {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256);

    function transfer(address _recipient, uint256 _amount)
        external
        returns (bool);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256);

    function approve(address _spender, uint256 _amount) external returns (bool);

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract ERC20Token is IERC20T {
    string public tokenName;
    string public tokenSymbol;
    uint256 public tokenDecimal;
    uint256 private tokenTotalSupply;

    mapping(address => uint256) private _ownerBalance;
    mapping(address => mapping(address => uint256)) private _allowance;

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        uint256 _tokenDecimal,
        uint256 _initialSupply
    ) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
        tokenDecimal = _tokenDecimal;
        tokenTotalSupply = _initialSupply * 10**uint256(tokenDecimal);
        _ownerBalance[msg.sender] = tokenTotalSupply;
        emit Transfer(address(0), msg.sender, tokenTotalSupply);
    }

    function totalSupply() public view override returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address _owner) external view returns (uint256) {
        return _ownerBalance[_owner];
    }

    function transfer(address _recipient, uint256 _amount)
        external
        returns (bool)
    {
        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256)
    {
        require(_owner != address(0), "Invalid sender");
        require(_spender != address(0), "Invalid spender");

        return _allowance[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount)
        external
        returns (bool)
    {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool) {
        _transfer(_sender, _recipient, _amount);

        uint256 currentAllowance = _allowance[_sender][msg.sender];
        require(currentAllowance >= _amount, "Insufficient transfer allowance");
        _approve(_sender, msg.sender, _amount);
        return true;
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) internal {
        require(_amount > 0, "Amount must be greater than 0");
        require(_sender != _recipient, "Cannot transfer to self");
        require(_recipient != address(0), "Invalid recipient");
        require(_ownerBalance[msg.sender] >= _amount, "Insufficient balance");

        unchecked {
            _ownerBalance[_sender] -= _amount;
            _ownerBalance[_recipient] += _amount;
        }

        emit Transfer(msg.sender, _recipient, _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) internal {
        require(_amount > 0, "Amount must be greater than 0");
        require(_spender != address(0), "Invalid spender");

        _ownerBalance[_spender] = _amount;

        emit Approval(_owner, _spender, _amount);
    }
}
