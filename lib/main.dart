import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  int energyLevel = 100;
  Timer? hungerTimer;
  String mood = "Neutral";
  Color petColor = Colors.yellow;
  String selectedActivity = "Rest";

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
  }

  // Automatically increase hunger over time
  void _startHungerTimer() {
    hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      setState(() {
        hungerLevel = (hungerLevel + 5).clamp(0, 100);
        _updateHappiness();
        _updateMood();
        _updatePetColor();
      });

      // Check for loss condition
      if (hungerLevel == 100 && happinessLevel <= 10) {
        _showGameOverDialog();
      }
    });
  }

  // Function to increase happiness and update hunger when playing
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      energyLevel = (energyLevel - 10).clamp(0, 100);
      _updateMood();
      _updatePetColor();
    });
  }

  // Function to decrease hunger and update happiness when feeding
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      happinessLevel = (happinessLevel + 5).clamp(0, 100);
      _updateMood();
      _updatePetColor();
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel > 70) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else if (hungerLevel < 30) {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
  }

  // Update mood based on happiness level
  void _updateMood() {
    if (happinessLevel > 70) {
      mood = "Happy 😊";
    } else if (happinessLevel >= 30) {
      mood = "Neutral 😐";
    } else {
      mood = "Unhappy 😢";
    }
  }

  // Update pet color based on happiness level
  void _updatePetColor() {
    if (happinessLevel > 70) {
      petColor = Colors.green;
    } else if (happinessLevel >= 30) {
      petColor = Colors.yellow;
    } else {
      petColor = Colors.red;
    }
  }

  // Handle activity selection
  void _selectActivity(String activity) {
    setState(() {
      selectedActivity = activity;
      if (activity == "Rest") {
        energyLevel = (energyLevel + 20).clamp(0, 100);
      } else if (activity == "Run") {
        happinessLevel = (happinessLevel + 10).clamp(0, 100);
        energyLevel = (energyLevel - 15).clamp(0, 100);
      }
      _updateMood();
      _updatePetColor();
    });
  }

  // Show Game Over dialog
  void _showGameOverDialog() {
    hungerTimer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Game Over"),
        content: Text("Your pet is too hungry and sad! Try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetGame();
            },
            child: Text("Restart"),
          ),
        ],
      ),
    );
  }

  // Reset the game
  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      energyLevel = 100;
      mood = "Neutral 😐";
      petColor = Colors.yellow;
      _startHungerTimer();
    });
  }

  @override
  void dispose() {
    hungerTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Pet Name Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(labelText: "Enter Pet Name"),
                onSubmitted: (name) {
                  setState(() {
                    petName = name;
                  });
                },
              ),
            ),
            SizedBox(height: 16.0),
            
            // Display Pet Name
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),

            // Display Pet Happiness & Hunger Levels
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: petColor,
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(mood, style: TextStyle(fontSize: 24))),
            ),
            SizedBox(height: 16.0),

            Text('Happiness Level: $happinessLevel',
                style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),

            Text('Hunger Level: $hungerLevel',
                style: TextStyle(fontSize: 20.0)),
            SizedBox(height: 16.0),

            // Energy Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: LinearProgressIndicator(
                value: energyLevel / 100,
                backgroundColor: Colors.grey,
                color: Colors.blue,
              ),
            ),
            Text("Energy Level: $energyLevel", style: TextStyle(fontSize: 20)),
            SizedBox(height: 16.0),

            // Play & Feed Buttons
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),

            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            SizedBox(height: 16.0),

            // Activity Selection
            DropdownButton<String>(
              value: selectedActivity,
              items: ["Rest", "Run"].map((String activity) {
                return DropdownMenuItem<String>(
                  value: activity,
                  child: Text(activity),
                );
              }).toList(),
              onChanged: (activity) {
                if (activity != null) {
                  _selectActivity(activity);
                }
              },
            ),
            SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }
}
