pragma solidity ^0.5.10;

import {SafeMath} from "@summa-tx/bitcoin-spv-sol/contracts/SafeMath.sol";
import {DepositOwnerToken} from "./DepositOwnerToken.sol";
import {TBTCToken} from "./TBTCToken.sol";
import {TBTCConstants} from "../deposit/TBTCConstants.sol";
import {DepositUtils} from "../deposit/DepositUtils.sol";

contract VendingMachine {
    using SafeMath for uint256;
    
    TBTCToken tbtcToken;
    DepositOwnerToken depositOwnerToken;

    constructor(
        address _tbtcToken,
        address _depositOwnerToken
    ) public {
        tbtcToken = TBTCToken(_tbtcToken);
        depositOwnerToken = DepositOwnerToken(_depositOwnerToken);
    }

    /// @notice Qualifies a deposit for minting TBTC.
    function qualifyDeposit(
        uint256 _depositId,
        bytes4 _txVersion,
        bytes memory _txInputVector,
        bytes memory _txOutputVector,
        bytes4 _txLocktime,
        uint8 _fundingOutputIndex,
        bytes memory _merkleProof,
        uint256 _txIndexInBlock,
        bytes memory _bitcoinHeaders
    ) public {
        // require(!isQualified(_depositId), "Deposit already qualified");
        // TODO
        // TODO mint the signer fee to the Deposit contract here.
    }

    /// @notice Determines whether a deposit is qualified for minting TBTC.
    function isQualified(uint256 _depositId) public returns (bool) {
        // TODO
        // This is stubbed out for prototyping, separate to the actual qualification logic.
        // However we might remove it later.
        return true;
    }

    /// @notice Pay back the deposit's TBTC and receive the Deposit Owner Token.
    function tbtcToDot(uint256 _dotId) public {
        require(isQualified(_dotId), "Deposit must be qualified");

        require(tbtcToken.balanceOf(msg.sender) >= getDepositValueLessSignerFee(), "Not enough TBTC for DOT exchange");
        tbtcToken.burnFrom(msg.sender, getDepositValueLessSignerFee());

        // TODO do we need the owner check below? transferFrom can be approved for a user, which might be an interesting use case.
        require(depositOwnerToken.ownerOf(_depositId) == address(this), "Deposit is locked");
        depositOwnerToken.transferFrom(address(this), msg.sender, _depositId);
    }

    /// @notice Trade in the Deposit Owner Token and mint TBTC.
    function dotToTbtc(uint256 _dotId) public {
        require(isQualified(_dotId), "Deposit must be qualified");

        depositOwnerToken.transferFrom(msg.sender, address(this), _dotId);
        tbtcToken.mint(msg.sender, getDepositValueLessSignerFee());
    }

    // TODO temporary helper function
    /// @notice Gets the lot size less signer fees
    function getDepositValueLessSignerFee() internal returns (uint) {
        uint256 _multiplier = TBTCConstants.getSatoshiMultiplier();
        uint256 _signerFee = DepositUtils.signerFee();
        uint256 _totalValue = TBTCConstants.getLotSize().mul(_multiplier);
        return _totalValue.sub(_signerFee);
    }
}