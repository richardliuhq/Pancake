// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

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

import "../pancakeswap/pancake-swap-lib/contracts/math/SafeMath.sol";
import "../pancakeswap/pancake-swap-lib/contracts/token/BEP20/SafeBEP20.sol";

import "../interfaces/IPancakePair.sol";
import "../interfaces/IPancakeRouter02.sol";
import "../openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract ZapBSC is OwnableUpgradeable {
    using SafeMath for uint;
    using SafeBEP20 for IBEP20;

    /* ========== CONSTANT VARIABLES ========== */

/*    address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private constant BUNNY = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;
    address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant VAI = 0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7;
    address private constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address private constant ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;

    IPancakeRouter02 private constant ROUTER = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);*/
    //address private constant CAKE = 0x0E09FaBB73Bd3Ade0a17ECC321fD13a19e81cE82;
    address private constant CAKE = 0x73523F93ac317A4C4F052a7096aA7c8978E4F893;
    //address private constant BUNNY = 0xC9849E6fdB743d08fAeE3E34dd2D1bc69EA11a51;
    address private constant BUNNY = 0x834E71cE5b7895A6b40b17dC69E67a9A7419329D;
    //address private constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private constant WBNB = 0x403738632d7344E32EEd2c26b228F16eEdda84A4;
    //address private constant BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;
    address private constant BUSD = 0xc481F9e9799A60db5a5ea2665E6834c80454189C;
   //address private constant USDT = 0x55d398326f99059fF775485246999027B3197955;
    address private constant USDT =0x5f4d66Ce8F3437d46Be90e11F9E7799d3C571D7C;
   //address private constant DAI = 0x1AF3F329e8BE154074D8769D1FFa4eE058B1DBc3;
    address private constant DAI = 0x37578604b66745308c97d6C7d29c0cE3b6497eA0;
    //address private constant USDC = 0x8AC76a51cc950d9822D68b83fE1Ad97B32Cd580d;
    address private constant USDC =0xE4F141dDd70a452cd7F3fF160144Abe736Fc1c87;
    //address private constant VAI = 0x4BD17003473389A42DAF6a0a729f6Fdb328BbBd7;
    address private constant VAI = 0xd28Ea274fCb48c9ec79BfC40b244246B8526dD7B;
    //adress private constant BTCB = 0x7130d2A12B9BCbFAe4f2634d864A1Ee1Ce3Ead9c;
    address private constant BTCB = 0x89872D5512f633c1f55E17e445008389fA246BFa;
    //address private constant ETH = 0x2170Ed0880ac9A755fd29B2688956BD959F933F8;
    address private constant ETH = 0x4B76B4AdDe227bE825329988b3900a109df41965;

    //IPancakeRouter02 private constant ROUTER = IPancakeRouter02(0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F);
    IPancakeRouter02 private constant ROUTER = IPancakeRouter02(0xAE7CDc8D311Ef3737D3d5E842337cbFE1208b6c6);    
    //private constant ROUTER = IPancakeRouter02(0xf4EB96b5EeAa03826c85f399B1F663028C110A45);    
    /* ========== STATE VARIABLES ========== */

    mapping(address => bool) private notFlip;
    mapping(address => address) private routePairAddresses;
    address[] public tokens;

    /* ========== INITIALIZER ========== */

    function initialize() external initializer {
        __Ownable_init();
        require(owner() != address(0), "Zap: owner must be set");

        setNotFlip(CAKE);
        setNotFlip(BUNNY);
        setNotFlip(WBNB);
        setNotFlip(BUSD);
        setNotFlip(USDT);
        setNotFlip(DAI);
        setNotFlip(USDC);
        setNotFlip(VAI);
        setNotFlip(BTCB);
        setNotFlip(ETH);

        setRoutePairAddress(VAI, BUSD);
    }

    receive() external payable {}


    /* ========== View Functions ========== */

    function isFlip(address _address) public view returns (bool) {
        return !notFlip[_address];
    }

    function routePair(address _address) external view returns(address) {
        return routePairAddresses[_address];
    }

    /* ========== External Functions ========== */

    function zapInToken(address _from, uint amount, address _to) external {
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from);

        if (isFlip(_to)) {
            IPancakePair pair = IPancakePair(_to);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (_from == token0 || _from == token1) {
                // swap half amount for other
                address other = _from == token0 ? token1 : token0;
                _approveTokenIfNeeded(other);
                uint sellAmount = amount.div(2);
                uint otherAmount = _swap(_from, sellAmount, other, address(this));
                ROUTER.addLiquidity(_from, other, amount.sub(sellAmount), otherAmount, 0, 0, msg.sender, block.timestamp);
            } else {
                uint bnbAmount = _swapTokenForBNB(_from, amount, address(this));
                _swapBNBToFlip(_to, bnbAmount, msg.sender);
            }
        } else {
            _swap(_from, amount, _to, msg.sender);
        }
    }

    function zapIn(address _to) external payable {
        _swapBNBToFlip(_to, msg.value, msg.sender);
    }

    function zapOut(address _from, uint amount) external {
        IBEP20(_from).safeTransferFrom(msg.sender, address(this), amount);
        _approveTokenIfNeeded(_from);

        if (!isFlip(_from)) {
            _swapTokenForBNB(_from, amount, msg.sender);
        } else {
            IPancakePair pair = IPancakePair(_from);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (token0 == WBNB || token1 == WBNB) {
                ROUTER.removeLiquidityETH(token0 != WBNB ? token0 : token1, amount, 0, 0, msg.sender, block.timestamp);
            } else {
                ROUTER.removeLiquidity(token0, token1, amount, 0, 0, msg.sender, block.timestamp);
            }
        }
    }

    /* ========== Private Functions ========== */

    function _approveTokenIfNeeded(address token) private {
        if (IBEP20(token).allowance(address(this), address(ROUTER)) == 0) {
            IBEP20(token).safeApprove(address(ROUTER), uint(- 1));
        }
    }

    function _swapBNBToFlip(address flip, uint amount, address receiver) private {
        if (!isFlip(flip)) {
            _swapBNBForToken(flip, amount, receiver);
        } else {
            // flip
            IPancakePair pair = IPancakePair(flip);
            address token0 = pair.token0();
            address token1 = pair.token1();
            if (token0 == WBNB || token1 == WBNB) {
                address token = token0 == WBNB ? token1 : token0;
                uint swapValue = amount.div(2);
                uint tokenAmount = _swapBNBForToken(token, swapValue, address(this));

                _approveTokenIfNeeded(token);
                ROUTER.addLiquidityETH{value : amount.sub(swapValue)}(token, tokenAmount, 0, 0, receiver, block.timestamp);
            } else {
                uint swapValue = amount.div(2);
                uint token0Amount = _swapBNBForToken(token0, swapValue, address(this));
                uint token1Amount = _swapBNBForToken(token1, amount.sub(swapValue), address(this));

                _approveTokenIfNeeded(token0);
                _approveTokenIfNeeded(token1);
                ROUTER.addLiquidity(token0, token1, token0Amount, token1Amount, 0, 0, receiver, block.timestamp);
            }
        }
    }

    function _swapBNBForToken(address token, uint value, address receiver) private returns (uint) {
        address[] memory path;

        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = WBNB;
            path[1] = routePairAddresses[token];
            path[2] = token;
        } else {
            path = new address[](2);
            path[0] = WBNB;
            path[1] = token;
        }

        uint[] memory amounts = ROUTER.swapExactETHForTokens{value : value}(0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swapTokenForBNB(address token, uint amount, address receiver) private returns (uint) {
        address[] memory path;
        if (routePairAddresses[token] != address(0)) {
            path = new address[](3);
            path[0] = token;
            path[1] = routePairAddresses[token];
            path[2] = WBNB;
        } else {
            path = new address[](2);
            path[0] = token;
            path[1] = WBNB;
        }

        uint[] memory amounts = ROUTER.swapExactTokensForETH(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    function _swap(address _from, uint amount, address _to, address receiver) private returns (uint) {
        address intermediate = routePairAddresses[_from];
        if (intermediate == address(0)) {
            intermediate = routePairAddresses[_to];
        }

        address[] memory path;
        if (intermediate != address(0) && (_from == WBNB || _to == WBNB)) {
            // [WBNB, BUSD, VAI] or [VAI, BUSD, WBNB]
            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (intermediate != address(0) && (_from == intermediate || _to == intermediate)) {
            // [VAI, BUSD] or [BUSD, VAI]
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] == routePairAddresses[_to]) {
            // [VAI, DAI] or [VAI, USDC]
            path = new address[](3);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = _to;
        } else if (routePairAddresses[_from] != address(0) && routePairAddresses[_to] != address(0) && routePairAddresses[_from] != routePairAddresses[_to]) {
            // routePairAddresses[xToken] = xRoute
            // [VAI, BUSD, WBNB, xRoute, xToken]
            path = new address[](5);
            path[0] = _from;
            path[1] = routePairAddresses[_from];
            path[2] = WBNB;
            path[3] = routePairAddresses[_to];
            path[4] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_from] != address(0)) {
            // [VAI, BUSD, WBNB, BUNNY]
            path = new address[](4);
            path[0] = _from;
            path[1] = intermediate;
            path[2] = WBNB;
            path[3] = _to;
        } else if (intermediate != address(0) && routePairAddresses[_to] != address(0)) {
            // [BUNNY, WBNB, BUSD, VAI]
            path = new address[](4);
            path[0] = _from;
            path[1] = WBNB;
            path[2] = intermediate;
            path[3] = _to;
        } else if (_from == WBNB || _to == WBNB) {
            // [WBNB, BUNNY] or [BUNNY, WBNB]
            path = new address[](2);
            path[0] = _from;
            path[1] = _to;
        } else {
            // [USDT, BUNNY] or [BUNNY, USDT]
            path = new address[](3);
            path[0] = _from;
            path[1] = WBNB;
            path[2] = _to;
        }

        uint[] memory amounts = ROUTER.swapExactTokensForTokens(amount, 0, path, receiver, block.timestamp);
        return amounts[amounts.length - 1];
    }

    /* ========== RESTRICTED FUNCTIONS ========== */

    function setRoutePairAddress(address asset, address route) public onlyOwner {
        routePairAddresses[asset] = route;
    }

    function setNotFlip(address token) public onlyOwner {
        bool needPush = notFlip[token] == false;
        notFlip[token] = true;
        if (needPush) {
            tokens.push(token);
        }
    }

    function removeToken(uint i) external onlyOwner {
        address token = tokens[i];
        notFlip[token] = false;
        tokens[i] = tokens[tokens.length - 1];
        tokens.pop();
    }

    function sweep() external onlyOwner {
        for (uint i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            if (token == address(0)) continue;
            uint amount = IBEP20(token).balanceOf(address(this));
            if (amount > 0) {
                _swapTokenForBNB(token, amount, owner());
            }
        }
    }

    function withdraw(address token) external onlyOwner {
        if (token == address(0)) {
            payable(owner()).transfer(address(this).balance);
            return;
        }

        IBEP20(token).transfer(owner(), IBEP20(token).balanceOf(address(this)));
    }
}