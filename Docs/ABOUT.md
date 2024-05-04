# MacroMonkey
## About

### Team: 
Alex Alvarez (Role: Full Stack Development)


### Description
MacroMonkey is a macronutrient tracking app that allows users to track their daily macronutrient intake with the foods that they eat on the day to day.
Beyond this, MacroMonkey is beginner friendly and encourages habit building with it's calendar profile. 


### Audience
January Comes around, and everyone swears they're going to change their habits. They're going to start eating healthier, being more active, whatever it may be. However, it always seems that these things often don't work out. 
- One reason people lose interest is because it's difficult to set a goal for yourself. It's difficult to figure out what it is that you want to look like

- I considered several audiences including fitness enthusiasts, long-term dieters, and health beginners. Ultimately, I settled on targeting individuals who are new to health and wellness tracking and often struggle with consistency in maintaining health goals. 
- This choice was driven by the understanding that the prospect of a long health journey can be daunting, this is why I wanted to have an essence of simplicity within the UI of the app. Something that is easy visually to scan and understand.
- My application focuses on simplicity and immediate engagement, designed to help users stay present and motivated without feeling overwhelmed by the complexity of health management.

### App in action
This demonstrates the search functionality of the app, adding and then manipulating the entry.

#### Home/Journal View
This is the main hub of the app where users can enter and display the foods that they've eaten throughtout the day.
![img]("../Assets/logged.png")

##### Macro Row
In a general sense, this image displays an old iteration of the macro-row, it's since been simplified to just take in a serving size rather than an exact milligram amount
![img]("../Assets/macrorow.png")


#### Progress/Streak View
This portion of the app provides users with immediate visual feedback about whether they have been successful in maintiaining a streak of app logins to record their food. 
While this may seem like a simple task, setting the bar relatively low, and gradually increasing and expanding past is a modicum of success
![img]("../Assets/calendar.png")


### Technology highlights:
SpoonacularAPI: A comprehensive food and recipe API that provides access to a vast database of recipes, ingredients, and nutritional information. It allows developers to integrate features like recipe search, meal planning, and nutrition analysis into their applications.
FirebaseFirestore: A cloud-hosted, NoSQL database provided by Firebase, which is a platform developed by Google for creating mobile and web applications. It is designed to store and sync data in real time, making it suitable for applications that require offline support and real-time updates.
I was originally using an untracked `Config.plist` file to hold the api key. However, I've decided to change this instead pasting the api key to the public. 


### acknowledgements/thanks/credits
- ChatGPT
- StackOverflow
- Professor Dionisio
- Keck lab students
