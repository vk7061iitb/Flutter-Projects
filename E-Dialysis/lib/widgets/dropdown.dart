import 'package:flutter/material.dart';

class MyDropDownList extends StatefulWidget {
  const MyDropDownList({super.key});

  @override
  State<MyDropDownList> createState() => _MyDropDownListState();
}

class _MyDropDownListState extends State<MyDropDownList> {

  String? valueChoose;
  List states = ['Andhra Pradesh','Arunachal Pradesh','Assam','Bihar','Chhattisgarh', 'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jammu & Kashmir', 'Jharkhand', 'Karnataka', 'Kerala', 'Madhya Pradesh','Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram', 'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim','Tamil Nadu', 'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal'];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromRGBO(246, 82, 19, 0.4)),
        borderRadius: BorderRadius.circular(21),
        color: Colors.grey[200]
      ),
      child: DropdownButton(
        hint: Text('Select your State', style: TextStyle(color: Color.fromRGBO(246, 82, 19, 0.6), fontSize: 16),),
        value: valueChoose,
        onChanged: (newValue){
          setState(() {
            valueChoose = newValue as String;
          });
      },
        items: states.map((valueItem){
          return DropdownMenuItem(
            value: valueItem,
            child: Text(valueItem, style: TextStyle(fontSize: 16),),
          );
        }).toList(),
        underline: Container(), // Remove the default underline
        icon: Icon(Icons.keyboard_arrow_down_sharp), // Add a dropdown arrow icon
        isExpanded: true, // Make the dropdown button fill the width
        style: TextStyle(
          color: Colors.black, // Text color for the selected item
        ),
      ),
    );
  }
}
