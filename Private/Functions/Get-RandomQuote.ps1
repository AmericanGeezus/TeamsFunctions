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

  $Quote = 'Thank you for using my Module! (David Eberhardt)', `
    'Ready Player 1  |  Player 2, Insert Coin', 'YOU MUST CONSTRUCT ADDITIONAL PYLONS!', 'Houston, we have a problem.', `
    'I solemnly swear that I am up to no good', 'Loading Subtitles...', 'Installing Babelfish... Done. Downloading Vogon poetry 1/42', 'Would you like to know... more?', `
    'You cannot pass! I am a servant of the Secret Fire, wielder of the Flame of Anor. The Dark Flame will not avail you, Flame of Udun. Go back to the shadow. You shall not pass!', `
    'May you stand between your crew and harm in every empty place that you must go', 'Forward the Foundation!', `
    "When live gives you lemons? Don't make lemonade. Make life take the lemons back! Get mad! Say: 'I don't want your damn lemons! What am I supposed to do with these?' Demand to see life's manager! (Cave Johnson)", `
    #region Imported
    'People say nothing is impossible, but I do nothing every day. (A. A. Milne)', `
    'Better to remain silent and be thought a fool than to speak out and remove all doubt. (Abraham Lincoln)', `
    'If I were two-faced, would I be wearing this one? (Abraham Lincoln)', `
    'The best thing about the future is that it comes one day at a time. (Abraham Lincoln)', `
    'The only mystery in life is why the kamikaze pilots wore helmets. (Al McGuire)', `
    'Light travels faster than sound. This is why some people appear bright until you hear them speak. (Alan Dundes)', `
    'Nobody realizes that some people expend tremendous energy merely to be normal. (Albert Camus)', `
    'Men marry women with the hope they will never change. Women marry men with the hope they will change. Invariably they are both disappointed. (Albert Einstein)', `
    'The difference between stupidity and genius is that genius has its limits. (Albert Einstein)', `
    'All the things I really like to do are either immoral, illegal or fattening. (Alexander Woollcott)', `
    "War is God's way of teaching Americans geography. (Ambrose Bierce)", `
    'It would be nice to spend billions on schools and roads, but right now that money is desperately needed for political ads. (Andy Borowitz)', `
    'The average dog is a nicer person than the average person. (Andy Rooney)', `
    "At every party there are two kinds of people those who want to go home and those who don't. The trouble is, they are usually married to each other. (Ann Landers)", `
    'If you want your children to listen, try talking softly to someone else. (Ann Landers)', `
    'Doctors are just the same as lawyers; the only difference is that lawyers merely rob you, whereas doctors rob you and kill you too. (Anton Chekhov)', `
    "I don't believe in astrology; I'm a Sagittarius and we're skeptical. (Arthur C. Clarke)", `
    "My opinions may have changed, but not the fact that I'm right. (Ashleigh Brilliant)", `
    'To be sure of hitting the target, shoot first, and call whatever you hit the target. (Ashleigh Brilliant)', `
    'Trouble knocked at the door, but, hearing laughter, hurried away. (Benjamin Franklin)', `
    'Wine is constant proof that God loves us and loves to see us happy. (Benjamin Franklin)', `
    'Have you noticed that all the people in favor of birth control are already born? (Benny Hill)', `
    "Be who you are and say what you feel, because those who mind don't matter and those who matter don't mind. (Bernard Baruch)", `
    'Most people would sooner die than think; in fact, they do so. (Bertrand Russell)', `
    'The world is full of magical things patiently waiting for our wits to grow sharper. (Bertrand Russell)', `
    'Facebook just sounds like a drag, in my day seeing pictures of peoples vacations was considered a punishment. (Betty White)', `
    'Everything that used to be a sin is now a disease. (Bill Maher)', `
    "If there is anything the nonconformist hates worse than a conformist, it's another nonconformist who doesn't conform to the prevailing standard of nonconformity. (Bill Vaughan)", `
    "Money won't buy happiness, but it will pay the salaries of a large research staff to study the problem. (Bill Vaughan)", `
    'The surest sign that intelligent life exists elsewhere in the universe is that it has never tried to contact us. (Bill Watterson)', `
    "Before you judge a man, walk a mile in his shoes. After that who cares?… He's a mile away and you've got his shoes! (Billy Connolly)", `
    "I've always wanted to go to Switzerland to see what the army does with those wee red knives. (Billy Connolly)", `
    "Going to church doesn't make you a Christian any more than going to a garage makes you an automobile. (Billy Sunday)", `
    "If you're going to tell people the truth, be funny or they'll kill you. (Billy Wilder)", `
    "A bank is a place that will lend you money if you can prove that you don't need it. (Bob Hope)", `
    "Inside me there's a thin person struggling to get out, but I can usually sedate him with four or five cupcakes. (Bob Thaves)", `
    'We never really grow up, we only learn how to act in public. (Bryan White)', `
    "As a child my family's menu consisted of two choices: take it or leave it. (Buddy Hackett)", `
    'My favorite machine at the gym is the vending machine. (Caroline Rhea)', `
    'All right everyone, line up alphabetically according to your height. (Casey Stengel)', `
    "He who laughs last didn't get the joke. (Charles de Gaulle)", `
    'I always arrive late at the office, but I make up for it by leaving early. (Charles Lamb)', `
    "Don't worry about the world coming to an end today. It is already tomorrow in Australia. (Charles M. Schulz)", `
    "By the time a man realizes that his father was right, he has a son who thinks he's wrong. (Charles Wadsworth)", `
    'High heels were invented by a woman who had been kissed on the forehead. (Christopher Morley)', `
    "If you love something set it free, but don't be surprised if it comes back with herpes. (Chuck Palahniuk)", `
    "When I was a boy I was told that anybody could become President. I'm beginning to believe it. (Clarence Darrow)", `
    "A stockbroker urged me to buy a stock that would triple its value every year. I told him, 'At my age, I don't even buy green bananas.' (Claude Pepper)", `
    "I'm too drunk to taste this chicken. (Colonel Sanders)", `
    "A study in the Washington Post says that women have better verbal skills than men. I just want to say to the authors of that study: 'Duh.' (Conan O'Brien)", `
    "Starbucks says they are going to start putting religious quotes on cups. The very first one will say, 'Jesus! This cup is expensive!' (Conan O'Brien)", `
    "Laughing at our mistakes can lengthen our own life. Laughing at someone else's can shorten it. (Cullen Hightower)", `
    "If you can't live without me, why aren't you dead already? (Cynthia Heimel)", `
    'If you think you are too small to make a difference, try sleeping with a mosquito. (Dalai Lama)', `
    'Remember, today is the tomorrow you worried about yesterday. (Dale Carnegie)', `
    "Education is learning what you didn't even know you didn't know. (Daniel J. Boorstin)", `
    "It is a scientific fact that your body will not absorb cholesterol if you take it from another person's plate. (Dave Barry)", `
    'Never under any circumstances take a sleeping pill and a laxative on the same night. (Dave Barry)', `
    'I used to jog but the ice cubes kept falling out of my glass. (David Lee Roth)', `
    'Everyone has a purpose in life. Perhaps yours is watching television. (David Letterman)', `
    'The digital camera is a great invention because it allows us to reminisce. Instantly. (Demetri Martin)', `
    'A failure is like fertilizer; it stinks to be sure, but it makes things grow faster in the future. (Denis Waitley)', `
    "Biologically speaking, if something bites you it's more likely to be female. (Desmond Morris)", `
    'As long as people will accept crap, it will be financially profitable to dispense it. (Dick Cavett)', `
    'A pessimist is a person who has had to listen to too many optimists. (Don Marquis)', `
    'The cure for boredom is curiosity. There is no cure for curiosity. (Dorothy Parker)', `
    'Never doubt the courage of the French. They were the ones who discovered that snails are edible. (Doug Larson)', `
    'To err is human; to admit it, superhuman. (Doug Larson)', `
    'Human beings, who are almost unique in having the ability to learn from the experience of others, are also remarkable for their apparent disinclination to do so. (Douglas Adams)', `
    "I refuse to answer that question on the grounds that I don't know the answer. (Douglas Adams)", `
    'There is a theory which states that if ever anyone discovers exactly what the Universe is for and why it is here, it will instantly disappear and be replaced by something even more bizarre and inexplicable.There is another theory which states that this has already happened. (Douglas Adams)', `
    "Don't cry because it's over. Smile because it happened. (Dr. Seuss)", `
    'I was born to make mistakes, not to fake perfection. (Drake)', `
    "An alcoholic is someone you don't like who drinks as much as you do. (Dylan Thomas)", `
    'Analyzing humor is like dissecting a frog. Few people are interested and the frog dies of it. (E. B. White)', `
    "If you think nobody cares if you're alive, try missing a couple of car payments. (Earl Wilson)", `
    'The duty of a patriot is to protect his country from its government. (Edward Abbey)', `
    'Do not take life too seriously. You will never get out of it alive. (Elbert Hubbard)', `
    "A woman is like a tea bag you can't tell how strong she is until you put her in hot water. (Eleanor Roosevelt)", `
    "My grandmother started walking five miles a day when she was sixty. She's ninety-seven now, and we don't know where the hell she is. (Ellen DeGeneres)", `
    'A computer once beat me at chess, but it was no match for me at kick boxing. (Emo Philips)', `
    'How many people here have telekenetic powers? Raise my hand. (Emo Philips)', `
    "I asked God for a bike, but I know God doesn't work that way. So I stole a bike and asked for forgiveness. (Emo Philips)", `
    'Leave something for someone but dont leave someone for something. (Enid Blyton)', `
    'Never go to a doctor whose office plants have died. (Erma Bombeck)', `
    'Never have more children than you have car windows. (Erma Bombeck)', `
    'I drink to make other people more interesting. (Ernest Hemingway)', `
    'Great art is the contempt of a great man for small art. (F. Scott Fitzgerald)', `
    "You're only as good as your last haircut. (Fran Lebowitz)", `
    'Good advice is something a man gives when he is too old to set a bad example. (Francois de La Rochefoucauld)', `
    'Marriage is the only war in which you sleep with the enemy. (Francois de La Rochefoucauld)', `
    "I can't understand why a person will take a year to write a novel when he can easily buy one for a few dollars. (Fred Allen)", `
    'The first time I sang in the church choir; two hundred people changed their religion. (Fred Allen)', `
    'Patriotism is your conviction that this country is superior to all others because you were born in it. (George Bernard Shaw)', `
    'We learn from experience that men never learn anything from experience. (George Bernard Shaw)', `
    'Happiness is having a large, loving, caring, close-knit family in another city. (George Burns)', `
    "If you live to be one hundred, you've got it made. Very few people die past that age. (George Burns)", `
    "You know you're getting old when you stoop to tie your shoelaces and wonder what else you could do while you're down there. (George Burns)", `
    'Have you ever noticed that anybody driving slower than you is an idiot, and anyone going faster than you is a maniac?  (George Carlin)', `
    "I was thinking about how people seem to read the Bible a whole lot more as they get older; then it dawned on me they're cramming for their final exam. (George Carlin)", `
    "I'm in shape. Round is a shape. (George Carlin)", `
    'If you try to fail, and succeed, which have you done? (George Carlin)', `
    'May the forces of evil become confused on the way to your house. (George Carlin)', `
    'Most people work just hard enough not to get fired and get paid just enough money not to quit. (George Carlin)', `
    'One tequila, two tequila, three tequila, floor. (George Carlin)', `
    'To those of you who received honours, awards and distinctions, I say well done. And to the C students, I say you, too, can be president of the United States. (George W. Bush)', `
    "Whoever said money can't buy happiness didn't know where to shop. (Gertrude Stein)", `
    'A black cat crossing your path signifies that the animal is going somewhere. (Groucho Marx)', `
    'Behind every successful man is a woman, behind her is his wife. (Groucho Marx)', `
    "Here's to our wives and girlfriends…may they never meet! (Groucho Marx)", `
    'I refuse to join any club that would have me as a member. (Groucho Marx)', `
    'I was married by a judge. I should have asked for a jury. (Groucho Marx)', `
    'If you find it hard to laugh at yourself, I would be happy to do it for you. (Groucho Marx)', `
    'Marriage is the chief cause of divorce. (Groucho Marx)', `
    'A judge is a law student who marks his own examination papers. (H. L. Mencken)', `
    'The two most common elements in the universe are hydrogen and stupidity. (Harlan Ellison)', `
    "It's only when you look at an ant through a magnifying glass on a sunny day that you realize how often they burst into flames. (Harry Hill)", `
    "It's a recession when your neighbor loses his job; it's a depression when you lose yours. (Harry S. Truman)", `
    "Before marriage, a man declares that he would lay down his life to serve you; after marriage, he won't even lay down his newspaper to talk to you. (Helen Rowland)", `
    'Life begins at 40 but so do fallen arches, rheumatism, faulty eyesight, and the tendency to tell a story to the same person, three or four times. (Helen Rowland)', `
    "I've got all the money I'll ever need, if I die by four o'clock. (Henny Youngman)", `
    "If you're going to do something tonight that you'll be sorry for tomorrow morning, sleep late. (Henny Youngman)", `
    'All men are equal before fish. (Herbert Hoover)', `
    'If I want to knock a story off the front page, I just change my hairstyle. (Hillary Clinton)', `
    "You tried your best and you failed miserably. The lesson is 'never try.' (Homer Simpson)", `
    'My grandfather once told me that there were two kinds of people: those who do the work and those who take the credit. He told me to try to be in the first group; there was much less competition. (Indira Gandhi)', `
    'People who think they know everything are a great annoyance to those of us who do. (Isaac Asimov)', `
    "I'd rather have 1% of the effort of 100 men than 100% of my own effort. (J. Paul Getty)", `
    'My wife Mary and I have been married for forty-seven years and not once have we had an argument serious enough to consider divorce; murder, yes, but divorce, never. (Jack Benny)', `
    'Money is not the most important thing in the world. Love is. Fortunately, I love money. (Jackie Mason)', `
    'Women are wiser than men because they know less and understand more. (James Thurber)', `
    "When we talk to God, we're praying. When God talks to us, we're schizophrenic. (Jane Wagner)", `
    "Men are like shoes. Some fit better than others. And sometimes you go out shopping and there's nothing you like. And then, as luck would have it, the next week you find two that are perfect, but you don't have the money to buy both. (Janet Evanovich)", `
    "According to a new survey, 90% of men say their lover is also their best friend. Which is really kind of disturbing when you consider man's best friend is his dog. (Jay Leno)", `
    "Here's something to think about: How come you never see a headline like 'Psychic Wins Lottery'? (Jay Leno)", `
    'My pessimism extends to the point of even suspecting the sincerity of other pessimists. (Jean Rostand)', `
    "Haters are just confused admirers because they can't figure out the reason why everyone loves you. (Jeffree Star)", `
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
    "Life is hard; it's harder if you're stupid. (John Wayne)", `
    'If life was fair, Elvis would be alive and all the impersonators would be dead. (Johnny Carson)', `
    'Flattery is like cologne water, to be smelt, not swallowed. (Josh Billings)', `
    'The greatest thief this world has ever produced is procrastination, and he is still at large. (Josh Billings)', `
    'The secret of the demagogue is to make himself as stupid as his audience so they believe they are clever as he. (Karl Kraus)', `
    'Life is hard. After all, it kills you. (Katharine Hepburn)', `
    'The safe way to double your money is to fold it over once and put it in your pocket. (Kin Hubbard)', `
    'True terror is to wake up one morning and discover that your high school class is running the country. (Kurt Vonnegut)', `
    "That's the funny thing about life. We're rarely aware of the bullets we dodge. The just-misses. The almost-never-happeneds. We spend so much time worrying about how the future is going to play out and not nearly enough time admiring the precious perfection of the present. (Lauren Miller)", `
    "A man doesn't know what he knows until he knows what he doesn't know. (Laurence J. Peter)", `
    'Originality is the fine art of remembering what you hear but forgetting where you heard it. (Laurence J. Peter)', `
    "If you're too open-minded; your brains will fall out. (Lawrence Ferlinghetti)", `
    'I always wanted to be somebody, but now I realize I should have been more specific. (Lily Tomlin)', `
    'The road to success is always under construction. (Lily Tomlin)', `
    "Until you value yourself, you won't value your time. Until you value your time, you will not do anything with it. (M. Scott Peck)", `
    "Don't keep a man guessing too long - he's sure to find the answer somewhere else. (Mae West)", `
    "I'm not for everyone. I'm barely for me. (Marc Maron)", `
    'Cleaning up with children around is like shoveling during a blizzard. (Margaret Culkin Banning)', `
    'Always remember that you are absolutely unique. Just like everyone else. (Margaret Mead)', `
    "Age is an issue of mind over matter. If you don't mind, it doesn't matter. (Mark Twain)", `
    'Be careful about reading health books. You may die of a misprint. (Mark Twain)', `
    'Clothes make the man. Naked people have little or no influence on society. (Mark Twain)', `
    'I am an old man and have known a great many troubles, but most of them never happened. (Mark Twain)', `
    'I am only human, although I regret it. (Mark Twain)', `
    'I would have written a shorter letter, but I did not have the time. (Mark Twain)', `
    'Never put off till tomorrow what you can do the day after tomorrow. (Mark Twain)', `
    "The only way to keep your health is to eat what you don't want, drink what you don't like, and do what you'd rather not. (Mark Twain)", `
    'When we remember we are all mad, the mysteries disappear and life stands explained. (Mark Twain)', `
    "Worrying is like paying a debt you don't owe. (Mark Twain)", `
    'Do not make the mistake of treating your dogs like humans or they will treat you like dogs. (Martha Scott)', `
    "Son, if you really want something in this life, you have to work for it. Now quiet! They're about to announce the lottery numbers. (Matt Groening)", `
    "God is at home, it's we who have gone out for a walk. (Meister Eckhart)", `
    "In the past 10,000 years, humans have devised roughly 100,000 religions based on roughly 2,500 gods. So the only difference between myself and the believers is that I am skeptical of 2,500 gods whereas they are skeptical of 2,499 gods. We're only one God away from total agreement. (Michael Shermer)", `
    'My theory is that all of Scottish cuisine is based on a dare. (Mike Myers)', `
    'Knowledge is knowing a tomato is a fruit; wisdom is not putting it in a fruit salad. (Miles Kington)', `
    'A committee is a group that keeps minutes and loses hours. (Milton Berle)', `
    'If evolution really works, how come mothers only have two hands? (Milton Berle)', `
    'My doctor told me that jogging could add years to my life. I think he was right. I feel ten years older already. (Milton Berle)', `
    'I drank some boiling water because I wanted to whistle. (Mitch Hedberg)', `
    'I prefer someone who burns the flag and then wraps themselves up in the Constitution over someone who burns the Constitution and then wraps themselves up in the flag. (Molly Ivins)', `
    "It's just a job. Grass grows, birds fly, waves pound the sand. I beat people up. (Muhammad Ali)", `
    'God did not intend religion to be an exercise club. (Naguib Mahfouz)', `
    'The only time a woman really succeeds in changing a man is when he is a baby. (Natalie Wood)', `
    "It's always darkest before the dawn. So if you're going to steal your neighbor's newspaper, that's the time to do it. (Navjot Singh Sidhu)", `
    'The only thing that stops God from sending another flood is that the first one was useless. (Nicolas Chamfort)', `
    "When you go into court you are putting your fate into the hands of twelve people who weren't smart enough to get out of jury duty. (Norm Crosby)", `
    "As you get older three things happen. The first is your memory goes, and I can't remember the other two. (Norman Wisdom)", `
    "Ask me no questions, and I'll tell you no lies. (Oliver Goldsmith)", `
    'If you must make a noise, make it quietly. (Oliver Hardy)', `
    "A woman's mind is cleaner than a man's: She changes it more often. (Oliver Herford)", `
    'Man has his will, but woman has her way. (Oliver Wendell Holmes Sr.)', `
    "Roses are red, violets are blue, I'm schizophrenic, and so am I. (Oscar Levant)", `
    "There's a fine line between genius and insanity. I have erased this line. (Oscar Levant)", `
    'What the world needs is more geniuses with humility; there are so few of us left. (Oscar Levant)', `
    "Always borrow money from a pessimist. He won't expect it back. (Oscar Wilde)", `
    'Always forgive your enemies nothing annoys them so much. (Oscar Wilde)', `
    "I am so clever that sometimes I don't understand a single word of what I am saying. (Oscar Wilde)", `
    'I can resist everything except temptation. (Oscar Wilde)', `
    'I can stand brute force, but brute reason is quite unbearable. There is something unfair about its use. It is hitting below the intellect. (Oscar Wilde)', `
    #"Women are meant to be loved, not to be understood. (Oscar Wilde)", `
    "Of all the things I've lost I miss my mind the most. (Ozzy Osbourne)", `
    "The only reason some people get lost in thought is because it's unfamiliar territory. (Paul Fix)", `
    'To err is human, but to really foul things up you need a computer. (Paul R. Ehrlich)', `
    'I have learned from my mistakes, and I am sure I can repeat them exactly. (Peter Cook)', `
    "I want my children to have all the things I couldn't afford. Then I want to move in with them. (Phyllis Diller)", `
    "We spend the first twelve months of our children's lives teaching them to walk and talk and the next twelve telling them to sit down and shut up. (Phyllis Diller)", `
    "When a man opens a car door for his wife, it's either a new car or a new wife. (Prince Philip)", `
    'Life is a sexually transmitted disease. (R. D. Laing)', `
    'I dream of a better tomorrow, where chickens can cross the road and not be questioned about their motives. (Ralph Waldo Emerson)', `
    'Health nuts are going to feel stupid someday, lying in hospitals dying of nothing. (Redd Foxx)', `
    'The less Holy Spirit we have, the more cake and coffee we need to keep the church going. (Reinhard Bonnke)', `
    "If you lived with a roommate as unstable as this economic system, you would've moved out or demanded that your roommate get professional help. (Richard D. Wolff)", `
    "When you're in love it's the most glorious two and a half days of your life. (Richard Lewis)", `
    'Lead me not into temptation; I can find the way myself. (Rita Mae Brown)', `
    "I love being married. It's so great to find that one special person you want to annoy for the rest of your life. (Rita Rudner)", `
    'When I eventually met Mr. Right I had no idea that his first name was Always. (Rita Rudner)', `
    'If you have a secret, people will sit a little bit closer. (Rob Cordry)', `
    'I have tried to know absolutely nothing about a great many things, and I have succeeded fairly well. (Robert Benchley)', `
    'The man who smiles when things go wrong has thought of someone to blame it on. (Robert Bloch)', `
    "All my life I've wanted, just once, to say something clever without losing my train of thought. (Robert Breault)", `
    'By working faithfully eight hours a day you may eventually get to be boss and work twelve hours a day. (Robert Frost)', `
    'Love is an irresistible desire to be irresistibly desired. (Robert Frost)', `
    "We're all a little weird. And life is a little weird. And when we find someone whose weirdness is compatible with ours, we join up with them and fall into mutually satisfying weirdness - and call it love - true love. (Robert Fulghum)", `
    "Older people shouldn't eat health food, they need all the preservatives they can get. (Robert Orben)", `
    "I'm sorry, if you were right, I'd agree with you. (Robin Williams)", `
    'Why do they call it rush hour when nothing moves? (Robin Williams)', `
    #"I found there was only one way to look thin: hang out with fat people. (Rodney Dangerfield)", `
    'I looked up my family tree and found out I was the sap. (Rodney Dangerfield)', `
    "My psychiatrist told me I was crazy and I said I want a second opinion. He said okay, you're ugly too. (Rodney Dangerfield)", `
    "We sleep in separate rooms, we have dinner apart, we take separate vacations we're doing everything we can to keep our marriage together. (Rodney Dangerfield)", `
    'I believe that if life gives you lemons, you should make lemonade... And try to find somebody whose life has given them vodka, and have a party. (Ron White)', `
    "It's true hard work never killed anybody, but I figure, why take the chance?  (Ronald Reagan)", `
    'Recession is when a neighbor loses his job. Depression is when you lose yours. (Ronald Reagan)', `
    "Have no fear of perfection. You'll never reach it. (Salvador Dali)", `
    'Inflation is when you pay fifteen dollars for the ten-dollar haircut you used to get for five dollars when you had hair. (Sam Ewing)', `
    "A verbal contract isn't worth the paper it's written on. (Samuel Goldwyn)", `
    "I don't think anyone should write their autobiography until after they're dead. (Samuel Goldwyn)", `
    "I don't want any yes-men around me. I want everybody to tell me the truth even if it costs them their job. (Samuel Goldwyn)", `
    'I wish I were dumber so I could be more certain about my opinions. It looks fun. (Scott Adams)', `
    'If there are no stupid questions, then what kind of questions do stupid people ask? Do they get smart just in time to ask questions?  (Scott Adams)', `
    'I live by my own rules  (reviewed, revised, and approved by my wife).. but still my own. (Si Robertson)', `
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
    'I know that there are people who do not love their fellow man, and I hate people like that!  (Tom Lehrer)', `
    'Every man is guilty of all the good he did not do. (Voltaire)', `
    'I hate women because they always know where things are. (Voltaire)', `
    'A rich man is nothing but a poor man with money. (W. C. Fields)', `
    'Always carry a flagon of whiskey in case of snakebite and furthermore always carry a small snake. (W. C. Fields)', `
    "If at first you don't succeed, try, try again. Then quit. There's no point in being a damn fool about it. (W. C. Fields)", `
    "We are all here on earth to help others. What on earth the others are here for I don't know. (W. H. Auden)", `
    'A great pleasure in life is doing what people say you cannot do. (Walter Bagehot)', `
    "My doctor gave me six months to live, but when I couldn't pay the bill he gave me six months more. (Walter Matthau)", `
    'Give me a woman who loves beer and I will conquer the world. (Wilhelm II)', `
    'Half our life is spent trying to find something to do with the time we have rushed through life trying to save. (Will Rogers)', `
    'The road to success is dotted with many tempting parking spaces. (Will Rogers)', `
    'When I die, I want to die like my grandfather who died peacefully in his sleep. Not screaming like all the passengers in his car. (Will Rogers)', `
    'Common sense and a sense of humor are the same thing, moving at different speeds. A sense of humor is just common sense, dancing. (William James)', `
    'A lie gets halfway around the world before the truth has a chance to get its pants on.', `
    "If you're going through hell, keep going.", `
    "You have enemies? Good. That means you've stood up for something, sometime in your life.", `
    "I don't want to achieve immortality through my work. I want to achieve it through not dying. (Woody Allen)", `
    'Marriage is like mushrooms: we notice too late if they are good or bad. (Woody Allen)', `
    'Everybody laughs the same in every language because laughter is a universal connection. (Yakov Smirnoff)', `
    "Always go to other people's funerals, otherwise they won't come to yours. (Yogi Berra)", `
    'If you come to a fork in the road, take it. (Yogi Berra)', `
    "You've got to be very careful if you don't know where you are going, because you might not get there. (Yogi Berra)", `
    "People often say that motivation doesn't last. Well, neither does bathing that's why we recommend it daily. (Zig Ziglar)", `
    "A man in love is incomplete until he has married. Then he's finished.  (Zsa Zsa Gabor)"
  #endregion


  Get-Random -InputObject $Quote
}
