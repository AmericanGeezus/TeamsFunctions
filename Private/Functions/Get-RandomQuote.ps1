# Module:   TeamsFunctions
# Function: Lookup
# Author:	  David Eberhardt
# Updated:  19-DEC-2020
# Status:   PreLive




function Get-RandomQuote {
  <#
  .SYNOPSIS
    Returns a quote
  .DESCRIPTION
    Returns a random quote
  .PARAMETER Module
    One or more modules to Check
  .EXAMPLE
    Get-RandomQuote
    Returns a random quote
  .NOTES
    Most are from https://www.keepinspiring.me/funny-quotes/
    Some are added manually.
    All are painstakingly (and manually) reformatted and curated
  .INPUTS
    None
  .OUTPUTS
    System.String
  .FUNCTIONALITY
    Putting the Fun back in Functionality (or Funeral)
  #>

  param ()
  #Show-FunctionStatus -Level Live

  $Quote = `
    #region Added David
    'Thank you for using my Module! (David Eberhardt)', `
    'Ready Player 1  |  Player 2, Insert Coin (Arcade)', `
    'YOU MUST CONSTRUCT ADDITIONAL PYLONS! (Star Craft)', `
    'Houston, we have a problem. (Apollo 13)', `
    'Loading Subtitles...', `
    'Installing Babelfish... Done. Downloading Vogon poetry 1/42', `
    'Would you like to know... more? (Starship Troopers)', `
    'You cannot pass! I am a servant of the Secret Fire, wielder of the Flame of Anor. The Dark Flame will not avail you, Flame of Udun. Go back to the shadow. You shall not pass! (Gandalf)', `
    'May you stand between your crew and harm as you lead them through the empty quarters of the stars (Mass Effect 2, based on an Ancient Egyptian Blessing)', `
    'Forward the Foundation! (Isaac Asimov)', `
    "When live gives you lemons? Don't make lemonade. Make life take the lemons back! Get mad! Say: 'I don't want your damn lemons! What am I supposed to do with these?' Demand to see life's manager! (Portal 2, Cave Johnson)", `
    "I love* when I need to download an update for the updater to install an update. (*I don't love that.) -- It's even more fun when your updater is so out of date you have to manually go get the newest avaliable updater in order to update the product. (unknown)", `
    "The two basic principles of Windows system administration: For minor problems, reboot; For major problems, reinstall (unknown)", `
    "If you want to make an apple pie from scratch, you must first create the universe (Carl Sagan)", `
    'With insufficient data it is easy to go wrong (Carl Sagan)', `
    'We should therefore claim, in the name of tolerance, the right not to tolerate the intolerant. (Sir Charles Popper)', `
    "Activating the Out-of-Office Assistant while being present is the ninja-trick of the office employee (unknown)", `
    "I'd love to be as tired in the evenings as I am in the mornings. My biorhythm is in a different time zone.", `
    "We are all flawed, my dear. Every one of us. And believe me, we've all made mistakes. You've just got to take a good hard look at yourself, change what needs to be changed, and move on, pet. (Lauren Myracle)", `
    'I live in my own little world. But its ok, they know me here. (Lauren Myracle)', `
    "Hey. What is it that famous person said? 'It'll all work out in the end, and if it doesn't, that means it's not the end yet'? (Lauren Myracle)", `
    'If you would be a real seeker after truth, it is necessary that at least once in your life you doubt, as far as possible, all things. (Rene Descartes)', `
    "Plan A is always more effective when the device you are working on understands that Plan B involves either a large hammer or screwdriver... (unknown)", `
    "A programmer is just a tool which converts caffeine into code (unknown)", `
    "The database hates you right now. The entry might exist or it might not exist. We would clear this mystery up for you, if we could get to the database. We tried to look it up, but the database puked up an error:Lost connection to My SQL server at 'reading initial communication packet', system error: 0 (unknown)", `
    'May all things go according to the wishes of those who hear it (Stargate Universe/Cantonese Proverb)', `
    "people who say it cannot be done should not interrupt those who are doing it (George Bernard Shaw)", `
    'Passion is energy. Feel the power that comes from focusing on what excites you. (Oprah Winfrey)', `
    'Doing the best at this moment puts you in the best place for the next moment. (Oprah Winfrey)', `
    "Be thankful for what you have; you'll end up having more. If you concentrate on what you don't have, you will never, ever have enough. (Oprah Winfrey)", `
    'The trouble with having an open mind, of course, is that people will insist on coming along and trying to put things in it. (Terry Pratchett)', `
    "It is often said that before you die your life passes before your eyes. It is in fact true. It's called living. (Terry Pratchett)", `
    "I'll be more enthusiastic about encouraging thinking outside the box when there's evidence of any thinking going on inside it. (Terry Pratchett)", `
    "'Educational' refers to the process, not the object. Although, come to think of it, some of my teachers could easily have been replaced by a cheeseburger. (Terry Pratchett)", `
    'Fantasy is an exercise bicycle for the mind. It might not take you anywhere, but it tones up the muscles that can. Of course, I could be wrong. (Terry Pratchett)', `
    "What is normal? Normal was yesterday. If you lose a leg, one day you're hopping around on one leg, so you know the difference. (Terry Pratchett)", `
    "Do you know that a man is not dead while his name is still spoken? (Terry Pratchett) -- GNU Sir Terry.", `
    #endregion Addded David

    #region Added Julia
    "Give a man a fire and he's warm for a day, but set fire to him and he's warm for the rest of his life. (Terry Pratchett)", `
    'In ancient times cats were worshipped as gods; they have not forgotten this. (Terry Pratchett)', `
    'In the beginning there was nothing, which exploded. (Terry Pratchett)', `
    'Real stupidity beats artificial intelligence every time. (Terry Pratchett)', `
    'Chaos is found in greatest abundance wherever order is being sought. It always defeats order, because it is better organized. (Terry Pratchett)', `
    'In fact, the mere act of opening the box will determine the state of the cat, although in this case there were three determinate states the cat could be in: these being Alive, Dead, and Bloody Furious. (Terry Pratchett)', `
    "Steal five dollars and you're a common thief. Steal thousands and you're either the government or a hero. (Terry Pratchett)", `
    'A witch ought never to be frightened in the darkest forest, Granny Weatherwax had once told her, because she should be sure in her soul that the most terrifying thing in the forest was her. (Terry Pratchett)', `
    'His progress through life was hampered by his tremendous sense of his own ignorance, a disability which affects all too few. (Terry Pratchett)', `
    'There Has Ceased to Be a Difference Between My Awake Clothes and My Asleep Clothes (Mindy Kaling)', `
    "If you don't stick to your values when they're being tested, they're not values: they're hobbies. (Jon Stewart)", `
    #endregion Added Julia

    #region Imported
    'People say nothing is impossible, but I do nothing every day. (A. A. Milne)', `
    'The best thing about the future is that it comes one day at a time. (Abraham Lincoln)', `
    'Light travels faster than sound. This is why some people appear bright until you hear them speak. (Alan Dundes)', `
    'The difference between stupidity and genius is that genius has its limits. (Albert Einstein)', `
    'All the things I really like to do are either immoral, illegal or fattening. (Alexander Woollcott)', `
    'It would be nice to spend billions on schools and roads, but right now that money is desperately needed for political ads. (Andy Borowitz)', `
    'The average dog is a nicer person than the average person. (Andy Rooney)', `
    'If you want your children to listen, try talking softly to someone else. (Ann Landers)', `
    "I don't believe in astrology; I'm a Sagittarius and we're skeptical. (Arthur C. Clarke)", `
    "My opinions may have changed, but not the fact that I'm right. (Ashleigh Brilliant)", `
    'To be sure of hitting the target, shoot first, and call whatever you hit the target. (Ashleigh Brilliant)', `
    "Be who you are and say what you feel, because those who mind don't matter and those who matter don't mind. (Bernard Baruch)", `
    'Most people would sooner die than think; in fact, they do so. (Bertrand Russell)', `
    'The world is full of magical things patiently waiting for our wits to grow sharper. (Bertrand Russell)', `
    'Facebook just sounds like a drag, in my day seeing pictures of peoples vacations was considered a punishment. (Betty White)', `
    "Money won't buy happiness, but it will pay the salaries of a large research staff to study the problem. (Bill Vaughan)", `
    'The surest sign that intelligent life exists elsewhere in the universe is that it has never tried to contact us. (Bill Watterson)', `
    "Before you judge a man, walk a mile in his shoes. After that who cares?… He's a mile away and you've got his shoes! (Billy Connolly)", `
    "I've always wanted to go to Switzerland to see what the army does with those wee red knives. (Billy Connolly)", `
    "Going to church doesn't make you a Christian any more than going to a garage makes you an automobile. (Billy Sunday)", `
    "If you're going to tell people the truth, be funny or they'll kill you. (Billy Wilder)", `
    "A bank is a place that will lend you money if you can prove that you don't need it. (Bob Hope)", `
    "Inside me there's a thin person struggling to get out, but I can usually sedate him with four or five cupcakes. (Bob Thaves)", `
    'We never really grow up, we only learn how to act in public. (Bryan White)', `
    'My favorite machine at the gym is the vending machine. (Caroline Rhea)', `
    'All right everyone, line up alphabetically according to your height. (Casey Stengel)', `
    "He who laughs last didn't get the joke. (Charles de Gaulle)", `
    'I always arrive late at the office, but I make up for it by leaving early. (Charles Lamb)', `
    "Don't worry about the world coming to an end today. It is already tomorrow in Australia. (Charles M. Schulz)", `
    "By the time a man realizes that his father was right, he has a son who thinks he's wrong. (Charles Wadsworth)", `
    "If you love something set it free, but don't be surprised if it comes back with herpes. (Chuck Palahniuk)", `
    "When I was a boy I was told that anybody could become President. I'm beginning to believe it. (Clarence Darrow)", `
    "A stockbroker urged me to buy a stock that would triple its value every year. I told him, 'At my age, I don't even buy green bananas.' (Claude Pepper)", `
    "A study in the Washington Post says that women have better verbal skills than men. I just want to say to the authors of that study: 'Duh.' (Conan O'Brien)", `
    "Starbucks says they are going to start putting religious quotes on cups. The very first one will say, 'Jesus! This cup is expensive!' (Conan O'Brien)", `
    "Laughing at our mistakes can lengthen our own life. Laughing at someone else's can shorten it. (Cullen Hightower)", `
    "If you can't live without me, why aren't you dead already? (Cynthia Heimel)", `
    'If you think you are too small to make a difference, try sleeping with a mosquito. (Dalai Lama)', `
    'Remember, today is the tomorrow you worried about yesterday. (Dale Carnegie)', `
    "Education is learning what you didn't even know you didn't know. (Daniel J. Boorstin)", `
    "It is a scientific fact that your body will not absorb cholesterol if you take it from another person's plate. (Dave Barry)", `
    "Never under any circumstances take a sleeping pill and a laxative on the same night. (Dave Barry)", `
    'I used to jog but the ice cubes kept falling out of my glass. (David Lee Roth)', `
    'The digital camera is a great invention because it allows us to reminisce. Instantly. (Demetri Martin)', `
    'A failure is like fertilizer; it stinks to be sure, but it makes things grow faster in the future. (Denis Waitley)', `
    'As long as people will accept crap, it will be financially profitable to dispense it. (Dick Cavett)', `
    'A pessimist is a person who has had to listen to too many optimists. (Don Marquis)', `
    'The cure for boredom is curiosity. There is no cure for curiosity. (Dorothy Parker)', `
    'Never doubt the courage of the French. They were the ones who discovered that snails are edible. (Doug Larson)', `
    'To err is human; to admit it, superhuman. (Doug Larson)', `
    'Human beings, who are almost unique in having the ability to learn from the experience of others, are also remarkable for their apparent disinclination to do so. (Douglas Adams)', `
    "I refuse to answer that question on the grounds that I don't know the answer. (Douglas Adams)", `
    'There is a theory which states that if ever anyone discovers exactly what the Universe is for and why it is here, it will instantly disappear and be replaced by something even more bizarre and inexplicable.There is another theory which states that this has already happened. (Douglas Adams)', `
    'Analyzing humor is like dissecting a frog. Few people are interested and the frog dies of it. (E. B. White)', `
    "If you think nobody cares if you're alive, try missing a couple of car payments. (Earl Wilson)", `
    'The duty of a patriot is to protect his country from its government. (Edward Abbey)', `
    'Do not take life too seriously. You will never get out of it alive. (Elbert Hubbard)', `
    "My grandmother started walking five miles a day when she was sixty. She's ninety-seven now, and we don't know where the hell she is. (Ellen DeGeneres)", `
    'A computer once beat me at chess, but it was no match for me at kick boxing. (Emo Philips)', `
    'How many people here have telekinetic powers? Raise my hand. (Emo Philips)', `
    "Leave something for someone but don't leave someone for something. (Enid Blyton)", `
    'Never go to a doctor whose office plants have died. (Erma Bombeck)', `
    'Never have more children than you have car windows. (Erma Bombeck)', `
    'I drink to make other people more interesting. (Ernest Hemingway)', `
    'Good advice is something a man gives when he is too old to set a bad example. (Francois de La Rochefoucauld)', `
    'The first time I sang in the church choir; two hundred people changed their religion. (Fred Allen)', `
    'Patriotism is your conviction that this country is superior to all others because you were born in it. (George Bernard Shaw)', `
    'We learn from experience that men never learn anything from experience. (George Bernard Shaw)', `
    "If you live to be one hundred, you've got it made. Very few people die past that age. (George Burns)", `
    "You know you're getting old when you stoop to tie your shoelaces and wonder what else you could do while you're down there. (George Burns)", `
    'Have you ever noticed that anybody driving slower than you is an idiot, and anyone going faster than you is a maniac?  (George Carlin)', `
    "I'm in shape. Round is a shape. (George Carlin)", `
    'If you try to fail, and succeed, which have you done? (George Carlin)', `
    'May the forces of evil become confused on the way to your house. (George Carlin)', `
    'Most people work just hard enough not to get fired and get paid just enough money not to quit. (George Carlin)', `
    'To those of you who received honours, awards and distinctions, I say well done. And to the C students, I say you, too, can be president of the United States. (George W. Bush)', `
    "Whoever said money can't buy happiness didn't know where to shop. (Gertrude Stein)", `
    'A black cat crossing your path signifies that the animal is going somewhere. (Groucho Marx)', `
    'I refuse to join any club that would have me as a member. (Groucho Marx)', `
    'If you find it hard to laugh at yourself, I would be happy to do it for you. (Groucho Marx)', `
    'A judge is a law student who marks his own examination papers. (H. L. Mencken)', `
    'The two most common elements in the universe are hydrogen and stupidity. (Harlan Ellison)', `
    "It's a recession when your neighbor loses his job; it's a depression when you lose yours. (Harry S. Truman)", `
    'Life begins at 40 but so do fallen arches, rheumatism, faulty eyesight, and the tendency to tell a story to the same person, three or four times. (Helen Rowland)', `
    'If I want to knock a story off the front page, I just change my hairstyle. (Hillary Clinton)', `
    "You tried your best and you failed miserably. The lesson is 'never try.' (Homer Simpson)", `
    'My grandfather once told me that there were two kinds of people: those who do the work and those who take the credit. He told me to try to be in the first group; there was much less competition. (Indira Gandhi)', `
    'People who think they know everything are a great annoyance to those of us who do. (Isaac Asimov)', `
    "I'd rather have 1% of the effort of 100 men than 100% of my own effort. (J. Paul Getty)", `
    'My wife Mary and I have been married for forty-seven years and not once have we had an argument serious enough to consider divorce; murder, yes, but divorce, never. (Jack Benny)', `
    'My pessimism extends to the point of even suspecting the sincerity of other pessimists. (Jean Rostand)', `
    "It's amazing that the amount of news that happens in the world every day always just exactly fits the newspaper. (Jerry Seinfeld)", `
    'Laugh a lot. It burns a lot of calories. (Jessica Simpson)', `
    'Avoid fruits and nuts. You are what you eat. (Jim Davis)', `
    'The simple act of opening a bottle of wine has brought more happiness to the human race than all the collective governments in the history of earth. (Jim Harrison)', `
    'Americans are incredibly inpatient. Someone once said that the shortest period of time in America is the time between when the light turns green and when you hear the first horn honk. (Jim Rohn)', `
    "Age is just a number. It's totally irrelevant unless, of course, you happen to be a bottle of wine. (Joan Collins)", `
    'Why is there so much month left at the end of the money? (John Barrymore)', `
    'Forgive your enemies, but never forget their names. (John F. Kennedy)', `
    "I've come to view Jesus much the way I view Elvis. I love the guy but the fan clubs really freak me out. (John Fugelsang)", `
    "Life moves pretty fast. If you don't stop and look around once in a while, you could miss it. (John Hughes)", `
    'The avoidance of taxes is the only intellectual pursuit that still carries any reward. (John Maynard Keynes)', `
    'If life was fair, Elvis would be alive and all the impersonators would be dead. (Johnny Carson)', `
    'Flattery is like cologne water, to be smelt, not swallowed. (Josh Billings)', `
    'The greatest thief this world has ever produced is procrastination, and he is still at large. (Josh Billings)', `
    'The secret of the demagogue is to make himself as stupid as his audience so they believe they are clever as he. (Karl Kraus)', `
    'Life is hard. After all, it kills you. (Katharine Hepburn)', `
    'True terror is to wake up one morning and discover that your high school class is running the country. (Kurt Vonnegut)', `
    "That's the funny thing about life. We're rarely aware of the bullets we dodge. The just-misses. The almost-never-happeneds. We spend so much time worrying about how the future is going to play out and not nearly enough time admiring the precious perfection of the present. (Lauren Miller)", `
    'Originality is the fine art of remembering what you hear but forgetting where you heard it. (Laurence J. Peter)', `
    'I always wanted to be somebody, but now I realize I should have been more specific. (Lily Tomlin)', `
    'The road to success is always under construction. (Lily Tomlin)', `
    "Until you value yourself, you won't value your time. Until you value your time, you will not do anything with it. (M. Scott Peck)", `
    "I'm not for everyone. I'm barely for me. (Marc Maron)", `
    'Cleaning up with children around is like shoveling during a blizzard. (Margaret Culkin Banning)', `
    'Always remember that you are absolutely unique. Just like everyone else. (Margaret Mead)', `
    "Age is an issue of mind over matter. If you don't mind, it doesn't matter. (Mark Twain)", `
    'Be careful about reading health books. You may die of a misprint. (Mark Twain)', `
    'Clothes make the man. Naked people have little or no influence on society. (Mark Twain)', `
    'I am only human, although I regret it. (Mark Twain)', `
    'I would have written a shorter letter, but I did not have the time. (Mark Twain)', `
    'Never put off till tomorrow what you can do the day after tomorrow. (Mark Twain)', `
    "The only way to keep your health is to eat what you don't want, drink what you don't like, and do what you'd rather not. (Mark Twain)", `
    'When we remember we are all mad, the mysteries disappear and life stands explained. (Mark Twain)', `
    "Son, if you really want something in this life, you have to work for it. Now quiet! They're about to announce the lottery numbers. (Matt Groening)", `
    "In the past 10,000 years, humans have devised roughly 100,000 religions based on roughly 2,500 gods. So the only difference between myself and the believers is that I am skeptical of 2,500 gods whereas they are skeptical of 2,499 gods. We're only one God away from total agreement. (Michael Shermer)", `
    'My theory is that all of Scottish cuisine is based on a dare. (Mike Myers)', `
    'Knowledge is knowing a tomato is a fruit; wisdom is not putting it in a fruit salad. (Miles Kington)', `
    'A committee is a group that keeps minutes and loses hours. (Milton Berle)', `
    'My doctor told me that jogging could add years to my life. I think he was right. I feel ten years older already. (Milton Berle)', `
    'I drank some boiling water because I wanted to whistle. (Mitch Hedberg)', `
    "I prefer someone who burns the flag and then wraps themselves up in the Constitution over someone who burns the Constitution and then wraps themselves up in the flag. (Molly Ivins)", `
    "It's just a job. Grass grows, birds fly, waves pound the sand. I beat people up. (Muhammad Ali)", `
    "It's always darkest before the dawn. So if you're going to steal your neighbor's newspaper, that's the time to do it. (Navjot Singh Sidhu)", `
    "When you go into court you are putting your fate into the hands of twelve people who weren't smart enough to get out of jury duty. (Norm Crosby)", `
    "As you get older three things happen. The first is your memory goes, and I can't remember the other two. (Norman Wisdom)", `
    "Ask me no questions, and I'll tell you no lies. (Oliver Goldsmith)", `
    'If you must make a noise, make it quietly. (Oliver Hardy)', `
    'What the world needs is more geniuses with humility; there are so few of us left. (Oscar Levant)', `
    "Always borrow money from a pessimist. He won't expect it back. (Oscar Wilde)", `
    'Always forgive your enemies nothing annoys them so much. (Oscar Wilde)', `
    "I am so clever that sometimes I don't understand a single word of what I am saying. (Oscar Wilde)", `
    'I can resist everything except temptation. (Oscar Wilde)', `
    'I can stand brute force, but brute reason is quite unbearable. There is something unfair about its use. It is hitting below the intellect. (Oscar Wilde)', `
    "Of all the things I've lost I miss my mind the most. (Ozzy Osbourne)", `
    "The only reason some people get lost in thought is because it's unfamiliar territory. (Paul Fix)", `
    'To err is human, but to really foul things up you need a computer. (Paul R. Ehrlich)', `
    'I have learned from my mistakes, and I am sure I can repeat them exactly. (Peter Cook)', `
    "I want my children to have all the things I couldn't afford. Then I want to move in with them. (Phyllis Diller)", `
    'Life is a sexually transmitted disease. (R. D. Laing)', `
    'I dream of a better tomorrow, where chickens can cross the road and not be questioned about their motives. (Ralph Waldo Emerson)', `
    'The less Holy Spirit we have, the more cake and coffee we need to keep the church going. (Reinhard Bonnke)', `
    "If you lived with a roommate as unstable as this economic system, you would've moved out or demanded that your roommate get professional help. (Richard D. Wolff)", `
    'Lead me not into temptation; I can find the way myself. (Rita Mae Brown)', `
    "I love being married. It's so great to find that one special person you want to annoy for the rest of your life. (Rita Rudner)", `
    'If you have a secret, people will sit a little bit closer. (Rob Cordry)', `
    'I have tried to know absolutely nothing about a great many things, and I have succeeded fairly well. (Robert Benchley)', `
    'The man who smiles when things go wrong has thought of someone to blame it on. (Robert Bloch)', `
    "All my life I've wanted, just once, to say something clever without losing my train of thought. (Robert Breault)", `
    'By working faithfully eight hours a day you may eventually get to be boss and work twelve hours a day. (Robert Frost)', `
    "We're all a little weird. And life is a little weird. And when we find someone whose weirdness is compatible with ours, we join up with them and fall into mutually satisfying weirdness - and call it love - true love. (Robert Fulghum)", `
    "Older people shouldn't eat health food, they need all the preservatives they can get. (Robert Orben)", `
    "I'm sorry, if you were right, I'd agree with you. (Robin Williams)", `
    'Why do they call it rush hour when nothing moves? (Robin Williams)', `
    'I looked up my family tree and found out I was the sap. (Rodney Dangerfield)', `
    'I believe that if life gives you lemons, you should make lemonade... And try to find somebody whose life has given them vodka, and have a party. (Ron White)', `
    "It's true hard work never killed anybody, but I figure, why take the chance?  (Ronald Reagan)", `
    "Have no fear of perfection. You'll never reach it. (Salvador Dali)", `
    'Inflation is when you pay fifteen dollars for the ten-dollar haircut you used to get for five dollars when you had hair. (Sam Ewing)', `
    "A verbal contract isn't worth the paper it's written on. (Samuel Goldwyn)", `
    "I don't think anyone should write their autobiography until after they're dead. (Samuel Goldwyn)", `
    "I don't want any yes-men around me. I want everybody to tell me the truth even if it costs them their job. (Samuel Goldwyn)", `
    'I wish I were dumber so I could be more certain about my opinions. It looks fun. (Scott Adams)', `
    'If there are no stupid questions, then what kind of questions do stupid people ask? Do they get smart just in time to ask questions?  (Scott Adams)', `
    'The trouble with telling a good story is that it invariably reminds the other fellow of a dull one. (Sid Caesar)', `
    'Children today are tyrants. They contradict their parents, gobble their food, and tyrannize their teachers. (Socrates)', `
    'You cannot be anything if you want to be everything. (Solomon Schechter)', `
    "If any of you cry at my funeral I'll never speak to you again. (Stan Laurel)", `
    "Folks, I don't trust children. They're here to replace us. (Stephen Colbert)", `
    'Crocodiles are easy. They try to kill and eat you. People are harder. Sometimes they pretend to be your friend first. (Steve Irwin)', `
    'A day without sunshine is like, you know, night. (Steve Martin)', `
    'It does not matter whether you win or lose, what matters is whether I win or lose!  (Steven Weinberg)', `
    'A clear conscience is usually the sign of a bad memory. (Steven Wright)', `
    'I intend to live forever. So far, so good. (Steven Wright)', `
    'The early bird gets the worm, but the second mouse gets the cheese. (Steven Wright)', `
    'To steal ideas from one person is plagiarism; to steal from many is research. (Steven Wright)', `
    "You can't have everything. Where would you put it?  (Steven Wright)", `
    "When I hear somebody sigh, 'Life is hard,' I am always tempted to ask, 'Compared to what?'  (Sydney J. Harris)", `
    'The world is a globe. The farther you sail, the closer to home you are. (Terry Pratchett)', `
    "If you could kick the person in the pants responsible for most of your trouble, you wouldn't sit for a month. (Theodore Roosevelt)", `
    "I have not failed. I've just found 10,000 ways that won't work. (Thomas A. Edison)", `
    'Opportunity is missed by most people because it is dressed in overalls and looks like work. (Thomas A. Edison)', `
    'It takes considerable knowledge just to realize the extent of your own ignorance. (Thomas Sowell)', `
    'Happiness is an imaginary condition, formerly attributed by the living to the dead, now usually attributed by adults to children, and by children to adults. (Thomas Szasz)', `
    'Every man is guilty of all the good he did not do. (Voltaire)', `
    'A rich man is nothing but a poor man with money. (W. C. Fields)', `
    'Always carry a flagon of whiskey in case of snakebite and furthermore always carry a small snake. (W. C. Fields)', `
    "If at first you don't succeed, try, try again. Then quit. There's no point in being a damn fool about it. (W. C. Fields)", `
    "We are all here on earth to help others. What on earth the others are here for I don't know. (W. H. Auden)", `
    'A great pleasure in life is doing what people say you cannot do. (Walter Bagehot)', `
    "My doctor gave me six months to live, but when I couldn't pay the bill he gave me six months more. (Walter Matthau)", `
    'Half our life is spent trying to find something to do with the time we have rushed through life trying to save. (Will Rogers)', `
    'The road to success is dotted with many tempting parking spaces. (Will Rogers)', `
    'Common sense and a sense of humor are the same thing, moving at different speeds. A sense of humor is just common sense, dancing. (William James)', `
    'A lie gets halfway around the world before the truth has a chance to get its pants on.', `
    "If you're going through hell, keep going.", `
    "You have enemies? Good. That means you've stood up for something, sometime in your life.", `
    'Everybody laughs the same in every language because laughter is a universal connection. (Yakov Smirnoff)', `
    "Always go to other people's funerals, otherwise they won't come to yours. (Yogi Berra)", `
    'If you come to a fork in the road, take it. (Yogi Berra)', `
    "You've got to be very careful if you don't know where you are going, because you might not get there. (Yogi Berra)", `
    "People often say that motivation doesn't last. Well, neither does bathing that's why we recommend it daily. (Zig Ziglar)"
  #endregion


  Get-Random -InputObject $Quote
}
