import 'package:budget_tracker/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const BalanceTrackerApp()); // Run the BalanceTrackerApp
}

class BalanceTrackerApp extends StatelessWidget {
  const BalanceTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budget Tracker',
      theme: ThemeData(fontFamily: 'Lexend'),
      home: const BalanceTrackerHomePage(),
    );
  }
}

const currtextstyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 16,
  color: Color.fromARGB(255, 255, 60, 10),
);

// ignore: constant_identifier_names
const income_expense = TextStyle(
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

class BalanceTrackerHomePage extends StatefulWidget {
  const BalanceTrackerHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _BalanceTrackerHomePageState createState() => _BalanceTrackerHomePageState();
}

class _BalanceTrackerHomePageState extends State<BalanceTrackerHomePage> {
  List<Transaction> transactions = [];
  double balance = 0.0;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TransactionType selectedType = TransactionType.income;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    CupertinoSegmentedControl<TransactionType>(
                      children: const {
                        TransactionType.income: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Income'),
                        ),
                        TransactionType.expense: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Expense'),
                        ),
                      },
                      groupValue: selectedType,
                      onValueChanged: (TransactionType? value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 60, 10),
                      ),
                      onPressed: () {
                        addTransaction();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Add New',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    CupertinoSegmentedControl<TransactionType>(
                      children: const {
                        TransactionType.income: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Income'),
                        ),
                        TransactionType.expense: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('Expense'),
                        ),
                      },
                      groupValue: selectedType,
                      onValueChanged: (TransactionType? value) {
                        setState(() {
                          selectedType = value!;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            deleteTransaction(index);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 255, 60, 10),
                          ),
                          onPressed: () {
                            modifyTransaction(index);
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
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

  @override
  Widget build(BuildContext context) {
    return scaffold(context);
  }

  Scaffold scaffold(BuildContext context) {
    return _scaffold(context);
  }

  Scaffold _scaffold(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Budget Tracker'),
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
              height: 150,
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
                          '₹ ${balance.toStringAsFixed(2)}',
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
                                Text('Income', style: income_expense),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text('₹ ${totalIncome.toStringAsFixed(2)}',
                                style: income_expense),
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
                    return GestureDetector(
                      onTap: () => showModifyTransactionSheet(context, index),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.298),
                                offset: Offset(0, 10),
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: ListTile(
                            title: Text(transaction.title),
                            subtitle: Text(transaction.description),
                            trailing: Text(
                              '₹ ${transaction.amount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                                color:
                                    transaction.type == TransactionType.income
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : const Color.fromARGB(255, 255, 20, 3),
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
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton(
          onPressed: () => showAddTransactionSheet(context),
          backgroundColor: Colors.white,
          child: const Icon(
            Icons.add,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
