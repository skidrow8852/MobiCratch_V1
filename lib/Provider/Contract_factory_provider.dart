import 'dart:convert';

import 'package:cratch/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:web_socket_channel/io.dart';

class ContractFactory extends ChangeNotifier {
  // Connect to blockchain network

  Web3Client? client;
  String? abiCode;
  EthereumAddress? contractAddress;
  var session;

  ContractFactory() {
    setupNetwork();
  }

  setupNetwork() async {
    client = Web3Client(networkHttpsRpc, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(networkWssRpc).cast<String>();
    });
  }

  // Connect With Smart Contract

  Future<void> fetchAbi() async {
    String abiFileRoot = await rootBundle.loadString(contractAbiPath);
    abiCode = jsonDecode(abiFileRoot);

    contractAddress = EthereumAddress.fromHex(tokenContractAddress);
  }

  void setSession(dynamic sess) {
    session = sess;
    notifyListeners();
  }
}
