//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

contract UniswapAdapter {
    using SafeERC20 for IERC20;

    event AddLiquidity(
        address indexed to,
        uint256 amountA,
        uint256 amountB,
        uint256 liquidity
    );
    event RemoveLiquidity(uint256 amountA, uint256 amountB);
    event CreatePair(address indexed pair);
    event Swap(uint256[] amounts);

    address private constant FACTORY =
        0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    address private constant ROUTER =
        0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    address private constant WETH = 0xc778417E063141139Fce010982780140Aa0cD5Ab;

    function getLiquidity(address pair)
        public
        view
        returns (uint256 liquidity)
    {
        liquidity = IERC20(pair).balanceOf(address(this));
    }

    function getPair(address tokenA, address tokenB)
        external
        view
        returns (address pair)
    {
        pair = IUniswapV2Factory(FACTORY).getPair(tokenA, tokenB);
    }

    function createPair(address tokenA, address tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).createPair(tokenA, tokenB);
        
        emit CreatePair(pair);
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired
    ) external {
        IERC20(tokenA).safeTransferFrom(
            msg.sender,
            address(this),
            amountADesired
        );
        IERC20(tokenB).safeTransferFrom(
            msg.sender,
            address(this),
            amountBDesired
        );

        IERC20(tokenA).approve(ROUTER, amountADesired);
        IERC20(tokenB).approve(ROUTER, amountBDesired);

        (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        ) = IUniswapV2Router02(ROUTER).addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit AddLiquidity(msg.sender, amountA, amountB, liquidity);
    }

    function removeLiquidity(address tokenA, address tokenB) external {
        address pair = IUniswapV2Factory(FACTORY).getPair(tokenA, tokenB);
        uint256 liquidity = getLiquidity(pair);

        IERC20(pair).approve(ROUTER, liquidity);

        (uint256 amountA, uint256 amountB) = IUniswapV2Router02(ROUTER)
            .removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                1,
                1,
                address(this),
                block.timestamp
            );

        emit RemoveLiquidity(amountA, amountB);
    }

    function swap(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external {
        IERC20(tokenIn).safeTransferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(ROUTER, amountIn);

        address[] memory path;
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        uint256[] memory amounts = IUniswapV2Router02(ROUTER)
            .swapExactTokensForTokens(
                amountIn,
                1,
                path,
                msg.sender,
                block.timestamp
            );

        emit Swap(amounts);
    }
}
