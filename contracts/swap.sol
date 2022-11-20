//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol"; // security against transactions for multiple requests
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./interface/IUniswapRouter02.sol";
contract SwapTest is Ownable,ReentrancyGuard {
    address[] public routers;  //it may be address of routers(pancakeswap,uniswap,)

    address[] public connectors;   //I think This is not neccessary to swap //let's discuss about this in detail

    constructor(){}
    
    /**
        get suitable router that has best price 
        @param amountIn   input amount
        @param tokenIn    source token
        @param tokenOut   destination token
        @return amountOut amount of out token that has best price to swap
        @return router    amount of out token to swap
        @return path      path* - token list to swap
     */
    function quote(
        uint amountIn,
        address tokenIn,
        address tokenOut
    ) external view returns (uint256 amountOut, address router, address[] memory path) {
        // TODO
        require(address(tokenIn) != address(0),"Invalid Input Address");
        require(address(tokenOut) != address(0),"Invalid Output Address");
        require(address(tokenIn) != address(tokenOut),"In token And Out Token is same");
        uint256 _maxOut=0;
        uint256 _i=0;
        for(uint256 i = 0; i < routers.length; i++){
            uint256 tmp = _getOutAmountByRouter(routers[i],amountIn,tokenIn,tokenOut);
            if(_maxOut < tmp){
                _maxOut = tmp;
                _i =i;
            }
        }
        path = new address[](2);
        path[0] = tokenIn;
        path[1] = tokenOut;

        amountOut = _maxOut;

        router = routers[_i];
    }

    /**
        Swaps tokens on router with path, should check slippage
        @param amountIn input amount
        @param amountOutMin minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path tokens list to swap
        @param to address that have to receive token
        @return amountOut output amount
     */
    function _swapTokenForExactTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address router,
        address[] memory path,
        address to
    ) external returns (uint256 amountOut) {
        require(address(to) != address(0),"Invalid receive address");
        require(address(router) != address(0),"Router is invalid");    
        require(path.length >= 2,"Invalid path");
        require(IERC20(path[0]).approve(address(router), amountIn),"approve failed");
        _checkSlipage(amountIn , amountOutMin , router, path);
        uint256[] memory retAmounts=IUniswapRouter02(router).swapExactTokensForTokens(amountIn,amountOutMin,path,address(to),block.timestamp);
        return retAmounts[1];
    }

    /**
        Swaps ETH To Token on router with path, should check slippage This function should be payable funtion
        @param amountOutMin minumum output amount
        @param router Uniswap-like router to swap tokens on
        @param path tokens list to swap
        @return amountOut output amount
    */

    function _swapETHForExactTokens(
        uint256 amountOutMin,
        address router,
        address[] memory path,
        address to
    )public  payable returns (uint256 amountOut) {
        require(address(to) != address(0),"Invalid Receive address");
        require(address(router) != address(0),"Router is invalid");
        require(path.length >= 2,"Invalid path");
        require(path[0] == IUniswapRouter02(router).WETH(),"Invalid path");
        _checkSlipage(msg.value , amountOutMin , router, path);
        
        uint256[] memory retAmounts=IUniswapRouter02(router).swapExactETHForTokens{value:msg.value}(amountOutMin,path,address(this),block.timestamp);
        return retAmounts[1];
    }

    /**
        add router* address for Uniswap,Pancakeswap,Sushiswap,Biswap,Bakery,Baby
        @param _addr //address or router for each swap;
    */
    function addRouter(
        address _addr
    ) external  onlyOwner{
        // TODO
        require(_checkRouters(_addr)==false,"Router is in Router list already");
        routers.push(_addr);       
    }
     
    /**
        get minOutAmount of token for each router
        @param _router Uniswap-like router to swap tokens on
        @param _amountIn input amount
        @param _tokenIn source token
        @param _tokenOut destination token
        @return actual output amount
    */

    function _getOutAmountByRouter(address _router , uint256 _amountIn , address _tokenIn , address _tokenOut) internal view returns (uint256){
            address[] memory path = new address[](2);
            path[0] = address(_tokenIn);
            path[1] = address(_tokenOut);
            uint256 amountOut = IUniswapRouter02(_router).getAmountsOut(_amountIn,path)[1];
            uint256 amountMinout = amountOut*(1000-5)/1000; //slipage 0.5%
            return amountMinout;
    }

    /**
        check if router is in routes list
        @param _addr address of router 
        @return actual if it is in list true else false
    */
    function _checkRouters(address _addr) internal view returns(bool){
        for(uint256 i=0;i<routers.length;i++){
            if(routers[i]==address(_addr)){
                return true;
            }
        }
        return false;
    }
     
    /**
        check if slipage less than 0.5% because any swap has 0.5% slipage
        @param _amountIn input amount
        @param amountOutMin min amount of token that expect
        @param router router like uniswap
        @param path* - token list to swap
     */   
    
    function _checkSlipage(uint256 _amountIn, uint256 amountOutMin, address router,address[] memory path) internal view {
            uint256 amountMinout =_getOutAmountByRouter(router , _amountIn , path[0] , path[1]);
            require(amountOutMin <= amountMinout,"slipage is less than 0.5%");
    }   
}