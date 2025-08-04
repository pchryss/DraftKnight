# 🏈 DraftKnight

## 📱 Description
During my internship with Emory University's AppHatchery, I have been able to really focus on the design side of product development for the first time. I wanted to reinforce the design principles I have been learning, and so I decided to use it as an opportunity to explore something else I have been extremely interested in; iOS development!

DraftKnight is essentially a mobile version of a popular web-based game amongst NFL fans (https://nflperry.com/game-mode). The objective is to reach the highest # of fantasy points by picking a player from a given randomized team without knowing which teams you will get in the future. 

## 🎮 How To Play! (only local in xcode currently :/)
```bash
git clone https://github.com/pchryss/DraftKnight
``` 
Open DraftKnight in XCode and load the project into your iOS device

## 🛠️ Tools
* Design : Figma
* Development : Swift, SwiftUI, Python (web scraping for player db)
* Database : Firestore

## 🗺️ Roadmap
* Cleaning up UI / Functionality
* Launch to App Store!
* Global Leaderboards
* Multiplayer Support

## 📸 Dev Log

### August 3, 2025
A bunch of updates today
* Designed and implemented a "Play Again" / "Return to Lobby" post game state
* Designed and implemented a lightweight profile page with logout + top 5 scores functionality
* Finished games are now saved to firestore
* Implemented tab navigation
There are a few things I need to clean up, but outside of that the base functionality of the app is finished (e.g. the floating point bug on the last image😅)
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/8_design1.png" alt="post game design" height="200"/>
  <img src="images/8_design2.png" alt="profile design" height="200"/>
  <img src="images/8_tab.png" alt="tab implementation" height="200"/>
  <img src="images/8_playagain.png" alt="post game implementation" height="200"/>
  <img src="images/8_profile.png" alt="profile implementation" height="200"/>
</div>

### August 2, 2025
Designed and implemented auth pages 🔐
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/7_design.png" alt="auth Screens design" height="200"/>
  <img src="images/7_auth1.png" alt="log in implementation" height="200"/>
  <img src="images/7_auth2.png" alt="sign up implementation" height="200"/>
</div>

### July 13, 2025
Implemented the redesign  
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/6_home.PNG" alt="Home Screen Implementation" height="200"/>
  <img src="images/6_start.PNG" alt="Start Screen Implementation" height="200"/>
  <img src="images/6_game.PNG" alt="Game Screen Implementation" height="200"/>
</div>

### July 12, 2025
Redesign! Decided on the name "DraftKnight" (play on words with draft night😅) and a much more visually appealing color scheme  
<img src="images/5_redesign.png" alt="Redesign" height="200"/>

### July 3, 2025
Designed and implemented the incremental search feature needed to play the game  
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/4_design.png" alt="Search Design" height="200"/>
  <img src="images/4_search.jpeg" alt="Search Implementation" height="200"/>
</div>

### July 2, 2025
Created a web scraping script that scrapes some fantasy data from the internet.
After cleaning the data a little bit, I now have a database of every NFL players best fantasy season with each team they played for since 2000

### June 23, 2025
Began development! Development went pretty slow as it was my first time working with Swift / mobile development, but I was able to implement the three screens I had designed.  
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/3_home.PNG" alt="Home Screen Implementation" height="200"/>
  <img src="images/3_start.PNG" alt="Start Screen Implementation" height="200"/>
  <img src="images/3_game.PNG" alt="Game Screen Implementation" height="200"/>
</div>

### June 20, 2025
I figured out a ~decent~ color scheme and went brandless to focus on functionality. I designed the three screens needed for the main gameplay flow.  
<img src="images/2_design.png" alt="Three Screen Designs" height="200"/>

### June 18, 2025
Starting design with a simple auth screen to get comfortable with Figma and get a feel for the color scheme I wanted.  
<div style="display: flex; gap: 10px; align-items: flex-start;">
  <img src="images/1_colors.png" alt="Color Scheme and Notes" height="200"/>
  <img src="images/1_auth.png" alt="Auth Design" height="200"/>
</div>

