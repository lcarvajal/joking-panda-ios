#  Joking Panda on iOS

Author: Lukas Carvajal

## About

<img src="https://lcarvajal.github.io/img/haha-panda.jpg" height=200>

An iOS app with an animated panda that says knock-knock jokes out-loud and requires the user to talk back to it.

### Problem

1. While entertaining a 9-year-old at a kids party (filled with adults and no kids), I ran into an issue where I could not tell more than 2-3 knock-knock jokes.
2. When I started looking up some, the 9-year-old wanted to hear about 100 more and I was getting tired.
3. The 9-year-old wanted to practice telling the new knock-knock jokes she learned.

### Developing a Solution

The 9-year-old had an iPhone so I thought I'd develop an iOS app. 

My goal was really to build something that engaged kids in conversation rather than having them tap at a screen or hear a knock-knock joke said outloud the boring way ChatGPT does.

## Support
- Knock knock jokes
- Riddles (coming soon)
- Dad jokes (coming soon) 

## Setup

1. Create a `Keys.plist` file in the `Resources` folder
2. Add the key `mixpanelProjectToken` with the Mixpanel project token
3. Create a `Resources/knockKnockJokeData.json` file and populate it with an array of JSON joke objects in the form `{"id":1001,"lines":["Knock, knock.","Who's there?","Tank.","Tank who?","You’re welcome."]}`
4. Run the app 

## To-dos
1. Add support riddles and dad jokes
2. Allow user to practice telling jokes to the panda
3. Add fun dancing panda animations (requested by 9-year-old)
