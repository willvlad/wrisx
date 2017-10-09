function registerRiskExpert() {
  address = web3.eth.accounts[0];
  name = $("#name").val();

  contractInstance.registerRiskExpert(name,
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('name').value=''
            }
  )/*.then(function (txHash) {
          console.log('Transaction sent')
          console.dir(txHash)
          waitForTxToBeMined(txHash)
        })*/;
}

function depositRiskKnowledge() {
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
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
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
  amount = $("#amount").val();

  contractInstance.buyTokens({value: amount},
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('amount').value='';
            }
  );
}

function requestRiskKnowledge() {
  ind = $("#riskKnowledgeToRequest").val();
  contractInstance.requestRiskKnowledge.call(ind,
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('riskKnowledgeToRequest').value='';
            }
  );
}

function payForRiskKnowledge() {
  ind = $("#riskKnowledgeToPay").val();
  contractInstance.payForRiskKnowledge(ind,
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('riskKnowledgeToPay').value='';
            }
  );
}

function getRiskKnowledge() {
  ind = $("#riskKnowledgeToGet").val();
  contractInstance.getRiskKnowledge.call(ind,
            function(error, result) {
              if(!error) {
                document.getElementById('result').value=result
              } else {
                console.error(error);
              }
              document.getElementById('riskKnowledgeToGet').value='';
            }
  );
}

function startApp(web3) {
  abi = JSON.parse('[{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"members","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"getBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeExpert","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_price","type":"uint256"},{"name":"_title","type":"string"},{"name":"_keyWords","type":"string"},{"name":"_description","type":"string"},{"name":"_link","type":"string"},{"name":"_hash","type":"string"},{"name":"_password","type":"string"}],"name":"depositRiskKnowledge","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"requestRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_name","type":"string"}],"name":"registerRiskExpert","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgePrice","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"withdrawRiskKnowledge","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertInitialized","outputs":[{"name":"init","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertRating","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"payForRiskKnowledge","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeTitle","outputs":[{"name":"title","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"","type":"address"}],"name":"riskExperts","outputs":[{"name":"name","type":"string"},{"name":"totalRating","type":"uint256"},{"name":"number","type":"uint256"},{"name":"initialized","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"expertAddress","type":"address"}],"name":"getExpertTotalRating","outputs":[{"name":"totalRating","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_newOwner","type":"address"}],"name":"changeOwner","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledgeRating","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"}],"name":"getRiskKnowledge","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"tokenPriceEther","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"member","type":"address"}],"name":"getMemberBalance","outputs":[{"name":"balance","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"buyTokens","outputs":[],"payable":true,"stateMutability":"payable","type":"function"},{"constant":true,"inputs":[],"name":"riskKnowledgeCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"ind","type":"uint256"},{"name":"rate","type":"uint256"}],"name":"rateRiskKnowledge","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"getRiskKnowledgeCount","outputs":[{"name":"c","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[{"name":"_name","type":"string"},{"name":"_symbol","type":"string"},{"name":"_decimals","type":"uint8"},{"name":"_totalSupply","type":"uint256"},{"name":"_tokenPriceEther","type":"uint8"}],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":true,"stateMutability":"payable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"expert","type":"address"},{"indexed":false,"name":"name","type":"string"}],"name":"onRiskExpertRegistered","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"member","type":"address"},{"indexed":false,"name":"tokens","type":"uint256"}],"name":"onTokensBought","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"expert","type":"address"},{"indexed":true,"name":"ind","type":"uint256"}],"name":"onRiskKnowledgeDeposited","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"expert","type":"address"},{"indexed":true,"name":"ind","type":"uint256"}],"name":"onRiskKnowledgeWithdrawn","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"member","type":"address"},{"indexed":true,"name":"ind","type":"uint256"}],"name":"onRiskKnowledgePaid","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"member","type":"address"},{"indexed":true,"name":"ind","type":"uint256"}],"name":"onRiskKnowledgeSent","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"member","type":"address"},{"indexed":true,"name":"ind","type":"uint256"},{"indexed":false,"name":"rate","type":"uint256"}],"name":"onRiskKnowledgeRated","type":"event"}]')
  WrisxContract = web3.eth.contract(abi);
  contractInstance = WrisxContract.at('0x9ff628631de6403d2f1ea670e9937f841433241b');
  console.log(web3.eth.accounts[0]);
}

function getWeb3(callback) {
  if (typeof window.web3 === 'undefined') {
    console.error("Please use a web3 browser");
  } else {
    var myWeb3 = new Web3(window.web3.currentProvider);

    myWeb3.eth.defaultAccount = window.web3.eth.defaultAccount;

    callback(myWeb3);
  }
}

async function waitForTxToBeMined (txHash) {
  let txReceipt
  while (!txReceipt) {
    try {
      txReceipt = await eth.getTransactionReceipt(txHash)
    } catch (err) {
      return console.error(err)
    }
  }
  console.log("Success")
}

window.addEventListener('load', function() {
  getWeb3(startApp);
});
