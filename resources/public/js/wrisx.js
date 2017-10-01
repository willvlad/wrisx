web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
abi = JSON.parse('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"},{"name":"_title","type":"string"},{"name":"_keyWord","type":"string"},{"name":"_description","type":"string"},{"name":"_link","type":"string"},{"name":"_hash","type":"string"},{"name":"_password","type":"string"}],"name":"depositRiskKnowledge","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"requestRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"registerRiskExpert","outputs":[{"name":"success","type":"bool"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"expert","type":"address"}],"name":"getExpertInitialized","outputs":[{"name":"init","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeTitle","outputs":[{"name":"title","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"getRiskExperts","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"expert","type":"address"}],"name":"getExpertTotalRating","outputs":[{"name":"totalRating","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[],"name":"buyToken","outputs":[],"payable":true,"type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"tokenPriceEther","outputs":[{"name":"","type":"uint8"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"member","type":"address"}],"name":"getMemberBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"riskKnowledgeCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"buyRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"riskExpertRatings","outputs":[{"name":"name","type":"string"},{"name":"totalRating","type":"uint256"},{"name":"number","type":"uint256"},{"name":"initialized","type":"uint256"}],"payable":false,"type":"function"},{"constant":true,"inputs":[],"name":"getRiskKnowledgeCount","outputs":[{"name":"c","type":"uint256"}],"payable":false,"type":"function"},{"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_decimals","type":"uint8"},{"name":"_totalSupply","type":"uint256"},{"name":"_tokenPriceEther","type":"uint8"}],"payable":false,"type":"constructor"},{"payable":true,"type":"fallback"}]')
WrisxContract = web3.eth.contract(abi);
contractInstance = WrisxContract.at('0xfa93b679ab2eee5125b38770c0bc681eef758be8');

function registerRiskExpert() {
  address = $("#address").val();
  name = $("#name").val();

  contractInstance.registerRiskExpert(name, {from: address}, function() {
    document.getElementById('address').value=''
    document.getElementById('name').value=''
  });
}

function depositRiskKnowledge() {
  address = $("#address").val();
  price = $("#price").val();
  title = $("#title").val();
  keyWord = $("#keyWord").val();
  description = $("#description").val();
  link = $("#link").val();
  hash = $("#hash").val();
  password = $("#password").val();

  contractInstance.depositRiskKnowledge(price,
                                        title,
                                        keyWord,
                                        description,
                                        link,
                                        hash,
                                        password,
                                        {from: address, gas: 4700000},
                                        function() {
    document.getElementById('address').value=''
    document.getElementById('price').value=''
    document.getElementById('title').value=''
    document.getElementById('keyWord').value=''
    document.getElementById('description').value=''
    document.getElementById('link').value=''
    document.getElementById('hash').value=''
    document.getElementById('password').value=''
  });
}

function buyTokens() {
  address = $("#address").val();
  amount = $("#amount").val();

  contractInstance.buyToken({from: address, value: amount, gas: 4700000},
                             function() {
    document.getElementById('address').value='';
    document.getElementById('amount').value='';
  });
}

function requestRiskKnowledge() {
  address = $("#address").val();
  ind = $("#riskKnowledgeToRequest").val();
  res = contractInstance.requestRiskKnowledge.call(ind, {from: address, gas: 4700000});
  console.log("res: " + res);
  document.getElementById('address').value='';
  document.getElementById('riskKnowledgeToRequest').value='';
  document.getElementById('result').value=res
}

function buyRiskKnowledge() {
  address = $("#address").val();
  ind = $("#riskKnowledgeToBuy").val();
  res = contractInstance.buyRiskKnowledge.call(ind, {from: address, gas: 4700000});
  console.log("res: " + res);
  document.getElementById('address').value='';
  document.getElementById('riskKnowledgeToBuy').value='';
  document.getElementById('result').value=res
}

$(document).ready(function() {

});
