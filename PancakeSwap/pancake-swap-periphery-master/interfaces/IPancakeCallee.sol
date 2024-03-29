pragma solidity >=0.5.0;

/*
 * PancakeSwapFinance 
 * App:             https://apeswap.finance
 * Medium:          https://medium.com/@ape_swap    
 * Twitter:         https://twitter.com/ape_swap 
 * Telegram:        https://t.me/ape_swap
 * Announcements:   https://t.me/ape_swap_news
 * GitHub:          https://github.com/PancakeSwapFinance
 */

interface IPancakeCallee {
    function pancakeCall(address sender, uint amount0, uint amount1, bytes calldata data) external;
}