import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

const currtextstyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 16,
  color: Color.fromARGB(255, 255, 60, 10),
);

const incomeExpense = TextStyle(
  fontWeight: FontWeight.w800,
  fontSize: 16,
  color: Color.fromARGB(255, 40, 40, 40),
);

class Transaction {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;

  Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
  });
}

enum TransactionType {
  income, // Represents an income transaction
  expense, // Represents an expense transaction
}

class BudgetTrackerHomePage extends StatefulWidget {
  const BudgetTrackerHomePage({super.key});

  @override
  BudgetTrackerHomePageState createState() => BudgetTrackerHomePageState();
}

class BudgetTrackerHomePageState extends State<BudgetTrackerHomePage> {
  List<Transaction> transactions = [];
  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TransactionType selectedType = TransactionType.income;

  void logOut() async {
    await FirebaseAuth.instance.signOut();
    // ignore: use_build_context_synchronously
    Navigator.popUntil(context, (route) => route.isFirst);
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (context) => const LoginPage(),
      ),
    );
  }

  void addTransaction() {
    String title = titleController.text;
    String description = descriptionController.text;
    double amount = double.tryParse(amountController.text) ?? 0.0;

    if (title.isNotEmpty) {
      setState(() {
        final transaction = Transaction(
          id: DateTime.now().toString(),
          title: title,
          description: description,
          amount: amount,
          type: selectedType,
        );
        if (transaction.type == TransactionType.income) {
          transactions.add(transaction);
          balance += transaction.amount;
        } else {
          transactions.add(transaction);
          balance -= transaction.amount;
        }

        if (transaction.type == TransactionType.income) {
          totalIncome += transaction.amount;
        } else {
          totalExpenses += transaction.amount;
        }
      });
    }
  }

  void showAddTransactionSheet(BuildContext context) {
    titleController.text = ''; // Reset the text fields
    descriptionController.text = '';
    amountController.text = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Add Transaction",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.title_sharp,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              titleController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Title',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.description,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              titleController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Description',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.currency_rupee,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              amountController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Amount',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = TransactionType.income;
                              addTransaction();
                              saveUser();
                              Navigator.pop(context);
                            });
                          },
                          child: const Text(
                            'Income',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = TransactionType.expense;
                              addTransaction();
                              saveUser();
                              Navigator.pop(context);
                            });
                          },
                          child: const Text(
                            'Expense',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
/*                     ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 60, 10),
                      ),
                      onPressed: () {
                        addTransaction();
                        Navigator.pop(context);
                        saveUser();
                      },
                      child: const Text(
                        'Add New',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ), */
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void showModifyTransactionSheet(BuildContext context, int index) {
    final transaction = transactions[index];
    titleController.text = transaction.title;
    descriptionController.text = transaction.description;
    amountController.text = transaction.amount.toString();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      "Modify Transaction",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 16, left: 16, right: 16),
                      child: TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.title_sharp,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              titleController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Title',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.description,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              titleController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Description',
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 16, left: 16, right: 16),
                      child: TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: const Icon(Icons.currency_rupee,
                              color: Colors.black),
                          suffixIcon: IconButton(
                            onPressed: () {
                              amountController.clear();
                            },
                            icon:
                                const Icon(Icons.clear, color: Colors.black54),
                          ),
                          labelText: 'Amount',
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = TransactionType.income;
                              modifyTransaction(index);
                              saveUser();
                              Navigator.pop(context);
                            });
                          },
                          child: const Text(
                            'Income',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(80.0),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedType = TransactionType.expense;
                              modifyTransaction(index);
                              saveUser();
                              Navigator.pop(context);
                            });
                          },
                          child: const Text(
                            'Expense',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void deleteTransaction(int index) {
    setState(() {
      final transaction = transactions[index];
      transactions.removeAt(index);
      if (transaction.type == TransactionType.income) {
        balance -= transaction.amount;
        totalIncome -= transaction.amount;
      } else {
        balance += transaction.amount;
        totalExpenses -= transaction.amount;
      }
    });
  }

  void modifyTransaction(int index) {
    setState(() {
      deleteTransaction(index);
      addTransaction();
    });
  }

  void updateTransaction(
      Transaction transaction, Transaction editedTransaction) {
    if (transaction.type == TransactionType.income) {
      balance = balance - transaction.amount + editedTransaction.amount;
      totalIncome = totalIncome - transaction.amount + editedTransaction.amount;
    } else {
      balance = balance + transaction.amount - editedTransaction.amount;
      totalExpenses =
          totalExpenses - transaction.amount + editedTransaction.amount;
    }
  }

  void saveUser() {
    double totalBalance = balance;
    double totalIncomes = totalIncome;
    double totalExpense = totalExpenses;

    Map<String, dynamic> userData = {
      'totalBalance': totalBalance,
      'totalExpense': totalExpense,
      'totalIncomes': totalIncomes,
    };

    FirebaseFirestore.instance.collection("users").add(userData);
    log("User Created");
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(context);
  }

  Scaffold scaffold(BuildContext context) {
    return _scaffold(context);
  }

  Scaffold _scaffold(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 230, 85, 85),
        title: const Text(
          "Budget Tracker",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            onPressed: () {
              logOut();
            },
            icon: const Icon(Icons.exit_to_app_sharp),
          )
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 230, 85, 85),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 15),
            Expanded(
              child: Image.asset(
                "assets/images/Tax-amico.png",
              ),
            ),
            const SizedBox(height: 15),
            Container(
              width: 325,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.298),
                    offset: Offset(0, 10),
                    blurRadius: 12,
                    spreadRadius: 6,
                  )
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Balance', style: currtextstyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Row(
                      children: [
                        Text(
                          String.fromCharCode(Icons.currency_rupee
                              .codePoint), // Convert icon to character
                          style: TextStyle(
                            fontSize: 30, // Increase the size
                            fontWeight: FontWeight.bold, // Make it bold
                            color: Colors.red,
                            fontFamily: Icons.currency_rupee.fontFamily,
                          ),
                        ),
                        Text(
                          balance.toStringAsFixed(2),
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 30,
                            color: Color.fromARGB(255, 255, 60, 10),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            const Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      Color.fromARGB(255, 40, 40, 40),
                                  child: Icon(
                                    Icons.arrow_upward,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text('Income', style: incomeExpense),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('₹ ${totalIncome.toStringAsFixed(2)}',
                                style: incomeExpense),
                          ],
                        ),
                        Column(
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor:
                                      Color.fromARGB(255, 255, 60, 10),
                                  child: Icon(
                                    Icons.arrow_downward,
                                    color: Colors.white,
                                    size: 19,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Text('Expenses', style: currtextstyle),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              '₹ ${totalExpenses.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Color.fromARGB(255, 255, 60, 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ListView.separated(
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return Dismissible(
                      key: Key(transaction.id), // Unique key for each item
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        deleteTransaction(index);
                        saveUser();
                        setState(() {
                          transactions.removeAt(index);
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Transaction deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                // Add the item back to the list (undo)
                                setState(() {
                                  transactions.insert(index, transaction);
                                });
                              },
                            ),
                          ),
                        );
                      },
                      child: GestureDetector(
                        onTap: () {
                          showModifyTransactionSheet(context, index);
                          saveUser();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(500),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 0),
                              child: ListTile(
                                title: Text(transaction.title),
                                subtitle: Text(transaction.description),
                                trailing: Text(
                                  '₹ ${transaction.amount.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: transaction.type ==
                                            TransactionType.income
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(255, 255, 20, 3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: FloatingActionButton(
          onPressed: () {
            showAddTransactionSheet(context);
          },
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add_outlined,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
