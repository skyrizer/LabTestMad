import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:lab_test/Model/BMI.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Controller/sqlite_db.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyCalculator(),
    );
  }
}

class MyCalculator extends StatefulWidget {
  const MyCalculator({super.key});

  @override
  State<MyCalculator> createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  late final TextEditingController bmiController = TextEditingController();
  String gender = "male";
  String bmi_status = "";
  String msg = '';




  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) async {
      final SQLiteDB sqliteDB = SQLiteDB(); // Assuming you have an instance of SQLiteDB
      final Map<String, dynamic>? lastRow = await sqliteDB.fetchLastRow('bmi');

      if (lastRow != null) {
        nameController.text = lastRow['username'];
        heightController.text = lastRow['height'].toString();
        weightController.text = lastRow['weight'].toString();
        bmiController.text = '';
        bmi_status = lastRow['bmi_status'];
      } else {
        print("Table is empty");
      }

      /*final SharedPreferences bmi = await SharedPreferences.getInstance();
      nameController.text = bmi.getString('username')!;
      heightController.text = bmi.getDouble('height')!.toString();
      weightController.text = bmi.getDouble('weight')!.toString();
      bmiController.text = bmi.getDouble('bmi')!.toString();
      bmi_status = bmi.getString('bmi_status')!;*/
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('BMI Calculator'), backgroundColor: Colors.blue,),
        body:
        SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                nameField(),
                heightField(),
                weightField(),
                bmiField(),
                genderButton(),
                saveButton(),
                Text(bmi_status),
              ],
            ),
          ),
        )
    );
  }


  Widget nameField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
          controller: nameController,
          decoration: InputDecoration(
          labelText: 'Your Fullname'
       ),
      ),
    );
  }

  Widget heightField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: heightController,
        decoration: InputDecoration(
            labelText: 'height in cm; 170'
        ),
      ),
    );
  }

  Widget weightField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: weightController,
        decoration: InputDecoration(
            labelText: 'Weight in KG'
        ),
      ),
    );
  }

  Widget bmiField(){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: bmiController,
        decoration: InputDecoration(
            labelText: 'BMI Value'
        ),
        readOnly: true,
      ),
    );
  }



  Widget genderButton(){
    return Center(
      child: Row(
        children: [
          RadioMenuButton(
              value: "MALE",
              groupValue: gender,
              onChanged: (value){
                setState(() {
                  gender = value.toString();
                });
            },
              child: Text("Male")
          ),
          RadioMenuButton(
              value: "FEMALE",
              groupValue: gender,
              onChanged: (value){
                setState(() {
                  gender = value.toString();
                });
              },
              child: Text("Female")
          ),
        ],
      ),
    );
  }

  Widget saveButton(){
    String name = nameController.text.trim();


    return ElevatedButton(onPressed: () async{
      double weight = double.parse(weightController.text.trim());
      double height = double.parse(heightController.text.trim());
      print(weight);
      print(height);

    double bmiTemp = weight /((height/100) * (height/100));

    if (gender == "MALE") {
      if (bmiTemp < 18.5) {
        bmi_status = "Underweight. Careful during strong wind!";
      } else if (bmiTemp >= 18.5 && bmiTemp <= 24.9){
        bmi_status = "That’s ideal! Please maintain";
      }else if (bmiTemp >= 25.0 && bmiTemp <= 29.9){
        bmi_status = "Overweight! Work out please";
      }else if (bmiTemp >= 30){
        bmi_status = "Whoa Obese! Dangerous mate!";
      }
    }else if (gender == "FEMALE") {
        if (bmiTemp < 16) {
          bmi_status = "Underweight. Careful during strong wind!";
        } else if (bmiTemp >= 16 && bmiTemp <= 22){
          bmi_status = "That’s ideal! Please maintain";
        }else if (bmiTemp >= 23 && bmiTemp <= 27){
          bmi_status = "Overweight! Work out please";
        }else if (bmiTemp >= 27){
          bmi_status = "Whoa Obese! Dangerous mate!";
        }
      }

      // Obtain shared preferences.
      final SharedPreferences bmiPrefs = await SharedPreferences.getInstance();

      await bmiPrefs.setString('username', name);
      await bmiPrefs.setDouble('height', height);
      await bmiPrefs.setDouble('weight', weight);
      await bmiPrefs.setString('gender', gender);
      await bmiPrefs.setString('bmi_status', bmi_status);
      await bmiPrefs.setDouble('bmi', bmiTemp);

      BMI bmi =
      BMI(
          name,
          height,
          weight,
          gender,
          bmi_status
      );

    if(await bmi.save()){
      setState(() {
      bmiController.text = bmiTemp.toString();
      });
    }


    },
      child: Text('Calculate BMI and Save'),

    );

  }
}


