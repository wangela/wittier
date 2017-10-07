# wittier

A simpler Twitter client for iOS

Time spent: 33 hours spent week 1
Time spent: 9 hours spent week 2

## User Stories

The following **required** functionality is completed:
- [x] User can sign in using OAuth login flow
- [x] The current signed in user will be persisted across restarts
- [x] User can view last 20 tweets from their home timeline
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] Hamburger menu reveals by dragging anywhere on the screen.
- [x] Hamburger reveals links to several timelines
- [x] Profile page with header view, user stats, and user's tweets
- [ ] Tap on any profile pic in any timeline to go to that user's profile page

The following **optional** features are implemented:

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [x] Replies should be prefixed with the username and the reply_id should be set when posting the tweet.
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [ ] Allow user to switch between accounts

The following **additional** features are implemented:
- [x] Timestamps are displayed with relative date formatting
- [x] Label retweets and display the original tweet as primary in a RT, in both Home timeline and Detail screen
- [x] Button to easily return to the top
- [x] Compose page has placeholder text to encourage text entry
- [x] Countdown label turns red within 20 characters of limit
- [x] Enable buttons in timeline for each tweet cell to retweet, favorite, and reply.
- [ ] Display hyperlinks, mentions, and hashtags in blue
- [ ] Display media in a tweet detail view

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='anim_wittier_v1.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

The foundation for displaying entities is in there, but since we haven't implemented timelines based on search or profile views yet I will defer the entities hyperlinking and displaying until next week.

I would like to learn better documentation patterns in comments.
I felt I could have done better with deferring logic to models; the VC code is...a medium amount of bulky.

## License
Credits:
- Compose action icon from [https://iconmonstr.com/edit-4/]
- Reply action icon from [https://iconmonstr.com/speech-bubble-16/]
- Retweet action icon from [https://iconmonstr.com/retweet-1/]
- Favorite action icon from [https://iconmonstr.com/favorite-4/]
- Favorited icon from [https://iconmonstr.com/favorite-3/]
- Cancel action icon from [https://iconmonstr.com/x-mark-9/]

  MIT License

  Copyright (c) 2017 Angela Yu

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.
