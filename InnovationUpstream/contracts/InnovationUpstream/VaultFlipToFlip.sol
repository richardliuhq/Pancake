// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
pragma experimental ABIEncoderV2;

/*
  ___                      _   _
 | _ )_  _ _ _  _ _ _  _  | | | |
 | _ \ || | ' \| ' \ || | |_| |_|
 |___/\_,_|_||_|_||_\_, | (_) (_)
                    |__/

*
* MIT License
* ===========
*
* Copyright (c) 2020 BunnyFinance
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*/

import "../pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";
import "../openzeppelin/contracts/math/Math.sol";

import {PoolConstant} from "../library/PoolConstant.sol";
import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeFactory.sol";
import "../interfaces/IStrategy.sol";
import "../interfaces/IMasterChef.sol";
import "../interfaces/IBunnyMinter.sol";

import "../zap/ZapBSC.sol";
import "./VaultController.sol";


contract VaultFlipToFlip is VaultController, IStrategy {
    using SafeBEP20 for IBEP20;
    using SafeMath for uint256;

    /* ========== CONSTANTS ============= */

    //IBEP20 private constant CAKE = IBEP20(0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82);
    IBEP20 private constant CAKE = IBEP20(0x73523F93ac317A4C4F052a7096aA7c8978E4F893);
    //IBEP20 private constant WBNB = IBEP20(0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c);
    IBEP20 private constant WBNB = IBEP20(0x403738632d7344E32EEd2c26b228F16eEdda84A4);
    //IMasterChef private constant CAKE_MASTER_CHEF = IMasterChef(0x73feaa1eE314F8c655E354234017bE2193C9E24E);
    IMasterChef private constant CAKE_MASTER_CHEF = IMasterChef(0xd709E225F052e23B95Bb01ADfa378E4facEF128E);
    PoolConstant.PoolTypes public constant override poolType = PoolConstant.PoolTypes.FlipToFlip;

    //ZapBSC public constant zapBSC = ZapBSC(0xdC2bBB0D33E0e7Dea9F5b98F46EDBaC823586a0C);
    //ZapBSC public constant zapBSC = ZapBSC(0x1aC0749EaF96a907717EcDf09C4eC5afAfd25187);
    //ZapBSC public constant zapBSC = ZapBSC(0x56761292Ac683C0327E6e84d46b8f5A0512E805f);
    ZapBSC public constant zapBSC = ZapBSC(0x9487d9F88A3dE5c3a6b1585D3572b4237e20e7b2);
    

/*    IPancakeRouter02 private constant ROUTER_V1 = IPancakeRouter02(0x2AD2C5314028897AEcfCF37FD923c079BeEb2C56);
    IPancakeRouter02 private constant ROUTER_V2 = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);

    IPancakeFactory private constant FACTORY_V1 = IPancakeFactory(0x877Fe7F4e22e21bE397Cd9364fAFd4aF4E15Edb6);
*/
    IPancakeRouter02 private constant ROUTER_V1 = IPancakeRouter02(0xAE94DafEc4c9f9bD6659C002E95494B8B845e41d);
    IPancakeRouter02 private constant ROUTER_V2 = IPancakeRouter02(0xAE7CDc8D311Ef3737D3d5E842337cbFE1208b6c6);

    IPancakeFactory private constant FACTORY_V1 = IPancakeFactory(0x1A9051a0951C76aF866d5a631a796590abaC7b33);


    uint private constant DUST = 1000;

    /* ========== STATE VARIABLES ========== */

    uint public override pid;

    address private _token0;
    address private _token1;

    uint public totalShares;
    mapping (address => uint) private _shares;
    mapping (address => uint) private _principal;
    mapping (address => uint) private _depositedAt;

    uint public cakeHarvested;

    /* ========== MODIFIER ========== */

    modifier updateCakeHarvested {
        uint before = CAKE.balanceOf(address(this));
        _;
        uint _after = CAKE.balanceOf(address(this));
        cakeHarvested = cakeHarvested.add(_after).sub(before);
    }

    /* ========== INITIALIZER ========== */

    function initialize(uint _pid, address _token) external initializer {
        __VaultController_init(IBEP20(_token));

        _stakingToken.safeApprove(address(CAKE_MASTER_CHEF), uint(- 1));
        pid = _pid;

        CAKE.safeApprove(address(zapBSC), uint(- 1));
    }

    /* ========== VIEW FUNCTIONS ========== */

    function totalSupply() external view override returns (uint) {
        return totalShares;
    }

    function balance() public view override returns (uint amount) {
        (amount,) = CAKE_MASTER_CHEF.userInfo(pid, address(this));
    }

    function balanceOf(address account) public view override returns(uint) {
        if (totalShares == 0) return 0;
        return balance().mul(sharesOf(account)).div(totalShares);
    }

    function withdrawableBalanceOf(address account) public view override returns (uint) {
        return balanceOf(account);
    }

    function sharesOf(address account) public view override returns (uint) {
        return _shares[account];
    }

    function principalOf(address account) public view override returns (uint) {
        return _principal[account];
    }

    function earned(address account) public view override returns (uint) {
        if (balanceOf(account) >= principalOf(account) + DUST) {
            return balanceOf(account).sub(principalOf(account));
        } else {
            return 0;
        }
    }

    function depositedAt(address account) external view override returns (uint) {
        return _depositedAt[account];
    }

    function rewardsToken() external view override returns (address) {
        return address(_stakingToken);
    }

    function priceShare() external view override returns(uint) {
        if (totalShares == 0) return 1e18;
        return balance().mul(1e18).div(totalShares);
    }

    /* ========== MUTATIVE FUNCTIONS ========== */

    function deposit(uint _amount) public override {
        _depositTo(_amount, msg.sender);
    }

    function depositAll() external override {
        deposit(_stakingToken.balanceOf(msg.sender));
    }

    function withdrawAll() external override {
        uint amount = balanceOf(msg.sender);
        uint principal = principalOf(msg.sender);
        uint depositTimestamp = _depositedAt[msg.sender];

        totalShares = totalShares.sub(_shares[msg.sender]);
        delete _shares[msg.sender];
        delete _principal[msg.sender];
        delete _depositedAt[msg.sender];

        amount = _withdrawTokenWithCorrection(amount);
        uint profit = amount > principal ? amount.sub(principal) : 0;

        uint withdrawalFee = canMint() ? _minter.withdrawalFee(principal, depositTimestamp) : 0;
        uint performanceFee = canMint() ? _minter.performanceFee(profit) : 0;
        if (withdrawalFee.add(performanceFee) > DUST) {
            _minter.mintForV2(address(_stakingToken), withdrawalFee, performanceFee, msg.sender, depositTimestamp);

            if (performanceFee > 0) {
                emit ProfitPaid(msg.sender, profit, performanceFee);
            }
            amount = amount.sub(withdrawalFee).sub(performanceFee);
        }

        _stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, withdrawalFee);
    }

    function harvest() external override onlyKeeper {
        _harvest();

        uint before = _stakingToken.balanceOf(address(this));
        zapBSC.zapInToken(address(CAKE), cakeHarvested, address(_stakingToken));
        uint harvested = _stakingToken.balanceOf(address(this)).sub(before);

        CAKE_MASTER_CHEF.deposit(pid, harvested);
        emit Harvested(harvested);

        cakeHarvested = 0;
    }

    function _harvest() private updateCakeHarvested {
        CAKE_MASTER_CHEF.withdraw(pid, 0);
    }

    function withdraw(uint shares) external override onlyWhitelisted {
        uint amount = balance().mul(shares).div(totalShares);
        totalShares = totalShares.sub(shares);
        _shares[msg.sender] = _shares[msg.sender].sub(shares);

        amount = _withdrawTokenWithCorrection(amount);
        _stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, 0);
    }

    // @dev underlying only + withdrawal fee + no perf fee
    function withdrawUnderlying(uint _amount) external {
        uint amount = Math.min(_amount, _principal[msg.sender]);
        uint shares = Math.min(amount.mul(totalShares).div(balance()), _shares[msg.sender]);
        totalShares = totalShares.sub(shares);
        _shares[msg.sender] = _shares[msg.sender].sub(shares);
        _principal[msg.sender] = _principal[msg.sender].sub(amount);

        amount = _withdrawTokenWithCorrection(amount);
        uint depositTimestamp = _depositedAt[msg.sender];
        uint withdrawalFee = canMint() ? _minter.withdrawalFee(amount, depositTimestamp) : 0;
        if (withdrawalFee > DUST) {
            _minter.mintForV2(address(_stakingToken), withdrawalFee, 0, msg.sender, depositTimestamp);
            amount = amount.sub(withdrawalFee);
        }

        _stakingToken.safeTransfer(msg.sender, amount);
        emit Withdrawn(msg.sender, amount, withdrawalFee);
    }

    // @dev profits only (underlying + bunny) + no withdraw fee + perf fee
    function getReward() external override {
        uint amount = earned(msg.sender);
        uint shares = Math.min(amount.mul(totalShares).div(balance()), _shares[msg.sender]);
        totalShares = totalShares.sub(shares);
        _shares[msg.sender] = _shares[msg.sender].sub(shares);
        _cleanupIfDustShares();

        amount = _withdrawTokenWithCorrection(amount);
        uint depositTimestamp = _depositedAt[msg.sender];
        uint performanceFee = canMint() ? _minter.performanceFee(amount) : 0;
        if (performanceFee > DUST) {
            _minter.mintForV2(address(_stakingToken), 0, performanceFee, msg.sender, depositTimestamp);
            amount = amount.sub(performanceFee);
        }

        _stakingToken.safeTransfer(msg.sender, amount);
        emit ProfitPaid(msg.sender, amount, performanceFee);
    }

    /* ========== PRIVATE FUNCTIONS ========== */

    function _depositTo(uint _amount, address _to) private notPaused updateCakeHarvested {
        uint _pool = balance();
        uint _before = _stakingToken.balanceOf(address(this));
        _stakingToken.safeTransferFrom(msg.sender, address(this), _amount);
        uint _after = _stakingToken.balanceOf(address(this));
        _amount = _after.sub(_before); // Additional check for deflationary tokens
        uint shares = 0;
        if (totalShares == 0) {
            shares = _amount;
        } else {
            shares = (_amount.mul(totalShares)).div(_pool);
        }

        totalShares = totalShares.add(shares);
        _shares[_to] = _shares[_to].add(shares);
        _principal[_to] = _principal[_to].add(_amount);
        _depositedAt[_to] = block.timestamp;

        CAKE_MASTER_CHEF.deposit(pid, _amount);
        emit Deposited(_to, _amount);
    }

    function _withdrawTokenWithCorrection(uint amount) private updateCakeHarvested returns (uint) {
        uint before = _stakingToken.balanceOf(address(this));
        CAKE_MASTER_CHEF.withdraw(pid, amount);
        return _stakingToken.balanceOf(address(this)).sub(before);
    }

    function _cleanupIfDustShares() private {
        uint shares = _shares[msg.sender];
        if (shares > 0 && shares < DUST) {
            totalShares = totalShares.sub(shares);
            delete _shares[msg.sender];
        }
    }

    /* ========== SALVAGE PURPOSE ONLY ========== */

    // @dev stakingToken must not remain balance in this contract. So dev should salvage staking token transferred by mistake.
    function recoverToken(address token, uint amount) external override onlyOwner {
        if (token == address(CAKE)) {
            uint cakeBalance = CAKE.balanceOf(address(this));
            require(amount <= cakeBalance.sub(cakeHarvested), "VaultFlipToFlip: cannot recover lp's harvested cake");
        }

        IBEP20(token).safeTransfer(owner(), amount);
        emit Recovered(token, amount);
    }

    /* ========== MIGRATE PANCAKE V1 to V2 ========== */

    function migrate(address account, uint amount) public {
        if (amount == 0) return;
        _depositTo(amount, account);
    }

    function migrateToken(uint amount) public onlyOwner {
        _stakingToken.safeTransferFrom(msg.sender, address(this), amount);
        CAKE_MASTER_CHEF.deposit(pid, amount);
    }

    function setPidToken(uint _pid, address token) external onlyOwner {
        require(totalShares == 0);
        pid = _pid;
        _stakingToken = IBEP20(token);

        _stakingToken.safeApprove(address(CAKE_MASTER_CHEF), 0);
        _stakingToken.safeApprove(address(CAKE_MASTER_CHEF), uint(- 1));

        _stakingToken.safeApprove(address(_minter), 0);
        _stakingToken.safeApprove(address(_minter), uint(- 1));
    }

    function approveZap() external onlyOwner {
        //CAKE.safeApprove(address(zapBSC), uint(- 1));
        CAKE.approve(address(zapBSC), uint(- 1));
        

        IPancakePair pair = IPancakePair(address(_stakingToken));
        address token0 = pair.token0();
        address token1 = pair.token1();

       // _flipOutV1(token0, token1);
        _flipInV2(token0, token1);
       // _dustInV2(address(_stakingToken), token0, token1);

        uint lpAmount = IBEP20(_stakingToken).balanceOf(address(this));
        CAKE_MASTER_CHEF.deposit(pid, lpAmount);
    }

    function _flipOutV1(address token0, address token1) private {
        address flipV1 = FACTORY_V1.getPair(token0, token1);
        _approveTokenIfNeededV1(flipV1);
        uint amount = IBEP20(flipV1).balanceOf(address (this));
        ROUTER_V1.removeLiquidity(token0, token1, amount, 0, 0, address(this), block.timestamp);
    }

    function _flipInV2(address token0, address token1) private {
        uint tokenAmount0 = IBEP20(token0).balanceOf(address(this));
        uint tokenAmount1 = IBEP20(token1).balanceOf(address(this));
        if (token0 == address(CAKE)) {
            tokenAmount0 = tokenAmount0.sub(cakeHarvested);
        }
        if (token1 == address(CAKE)) {
            tokenAmount1 = tokenAmount1.sub(cakeHarvested);
        }

        _approveTokenIfNeededV2(token0);
        _approveTokenIfNeededV2(token1);

        ROUTER_V2.addLiquidity(token0, token1, tokenAmount0, tokenAmount1, 0, 0, address(this), block.timestamp);
    }

    function _dustInV2(address flipV2, address token0, address token1) private {
        uint bnbBalance = address(this).balance;
        if (bnbBalance > DUST) {
            zapBSC.zapIn{value : bnbBalance}(flipV2);
        }

        uint tokenAmount0 = IBEP20(token0).balanceOf(address(this));
        if (token0 == address(CAKE)) {
            tokenAmount0 = tokenAmount0.sub(cakeHarvested);
        }
        if (tokenAmount0 > DUST) {
            if (IBEP20(token0).allowance(address(this), address(zapBSC)) == 0) {
                //IBEP20(token0).safeApprove(address(zapBSC), uint(- 1));
                IBEP20(token0).approve(address(zapBSC), uint(- 1));
            }
            zapBSC.zapInToken(token0, tokenAmount0, flipV2);
        }

        uint tokenAmount1 = IBEP20(token1).balanceOf(address(this));
        if (token1 == address(CAKE)) {
            tokenAmount1 = tokenAmount1.sub(cakeHarvested);
        }
        if (tokenAmount1 > DUST) {
            if (IBEP20(token1).allowance(address(this), address(zapBSC)) == 0) {
                //IBEP20(token1).safeApprove(address(zapBSC), uint(- 1));
                IBEP20(token1).approve(address(zapBSC), uint(- 1));
            }
            zapBSC.zapInToken(token1, tokenAmount1, flipV2);
        }
    }

    function _approveTokenIfNeededV1(address token) private {
        if (IBEP20(token).allowance(address(this), address(ROUTER_V1)) == 0) {
            //IBEP20(token).safeApprove(address(ROUTER_V1), uint(- 1));
            IBEP20(token).approve(address(ROUTER_V1), uint(- 1));
        }
    }

    function _approveTokenIfNeededV2(address token) private {
        if (IBEP20(token).allowance(address(this), address(ROUTER_V2)) == 0) {
            //IBEP20(token).safeApprove(address(ROUTER_V2), uint(- 1));
            IBEP20(token).approve(address(ROUTER_V2), uint(- 1));
        }
    }

//Debug Only
    function approveTokenIfNeededV1(address token) external onlyOwner {
           if (IBEP20(token).allowance(address(this), address(ROUTER_V1)) == 0) {
            //IBEP20(token).safeApprove(address(ROUTER_V1), uint(- 1));
            IBEP20(token).approve(address(ROUTER_V1), uint(- 1));
        }
    }    
    function approveTokenIfNeededV2(address token) external onlyOwner {
        if (IBEP20(token).allowance(address(this), address(ROUTER_V2)) == 0) {
            //IBEP20(token).safeApprove(address(ROUTER_V2), uint(- 1));
            IBEP20(token).approve(address(ROUTER_V2), uint(- 1));
        }
    }  
    //this is needed based in "zapInToken" function
    function approvezapBSCIfNeeded(address token) external onlyOwner {
        if (IBEP20(token).allowance(address(this), address(zapBSC)) == 0) {
            IBEP20(token).approve(address(zapBSC), uint(- 1));
        }
    }     
       

}