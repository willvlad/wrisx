web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));
abi = JSON.parse('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"},{"name":"_title","type":"string"},{"name":"_keyWord","type":"string"},{"name":"_description","type":"string"},{"name":"_link","type":"string"},{"name":"_hash","type":"string"},{"name":"_password","type":"string"}],"name":"depositRiskKnowledge","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"requestRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"registerRiskExpert","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgePrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertInitialized","outputs":[{"name":"init","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertRating","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeTitle","outputs":[{"name":"title","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertTotalRating","outputs":[{"name":"totalRating","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"buyToken","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeRating","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"tokenPriceEther","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"member","type":"address"}],"name":"getMemberBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"riskKnowledgeCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"buyRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"},{"name":"rate","type":"uint256"}],"name":"rateRiskKnowledge","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"riskExpertRatings","outputs":[{"name":"name","type":"string"},{"name":"totalRating","type":"uint256"},{"name":"number","type":"uint256"},{"name":"initialized","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getRiskKnowledgeCount","outputs":[{"name":"c","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_decimals","type":"uint8"},{"name":"_totalSupply","type":"uint256"},{"name":"_tokenPriceEther","type":"uint8"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"}]')
WrisxContract = web3.eth.contract(abi);
contractInstance = WrisxContract.at('0x613cdc0433be93050c6787afc444779aaa35cec4');

function registerRiskExpert() {
  address = $("#address").val();
  name = $("#name").val();

  contractInstance.registerRiskExpert(name, {from: address, gas: 4700000},
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('address').value=''
              document.getElementById('name').value=''
            }
  );
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
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('address').value=''
              document.getElementById('price').value=''
              document.getElementById('title').value=''
              document.getElementById('keyWord').value=''
              document.getElementById('description').value=''
              document.getElementById('link').value=''
              document.getElementById('hash').value=''
              document.getElementById('password').value=''
            }
  );
}

function buyTokens() {
  address = $("#address").val();
  amount = $("#amount").val();

  contractInstance.buyToken({from: address, value: amount, gas: 4700000},
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('address').value='';
              document.getElementById('amount').value='';
            }
  );
}

function requestRiskKnowledge() {
  address = $("#address").val();
  ind = $("#riskKnowledgeToRequest").val();
  contractInstance.requestRiskKnowledge.call(ind, {from: address, gas: 4700000},
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('address').value='';
              document.getElementById('riskKnowledgeToRequest').value='';
            }
  );
}

function buyRiskKnowledge() {
  address = $("#address").val();
  ind = $("#riskKnowledgeToBuy").val();
  contractInstance.buyRiskKnowledge.call(ind, {from: address, gas: 4700000},
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('address').value='';
              document.getElementById('riskKnowledgeToBuy').value='';
            }
  );
}

$(document).ready(function() {

});
