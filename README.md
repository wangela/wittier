# wittier

A simpler Twitter client for iOS

Time spent [week 1](https://github.com/wangela/wittier/tree/v1): 33 hours<br>
Time spent week 2: 20 hours

## User Stories

The following **required** functionality is completed:
- [x] User can sign in using OAuth login flow
- [x] The current signed in user will be persisted across restarts
- [x] User can view last 20 tweets from their home timeline
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
#### Week 2
- [x] Hamburger menu reveals by dragging anywhere on the screen.
- [x] Hamburger reveals links to several timelines
- [x] Profile page with header view, user stats, and user's tweets
- [x] Tap on any profile pic in the home timeline to go to that user's profile page


The following **optional** features are implemented:

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [x] Replies should be prefixed with the username and the reply_id should be set when posting the tweet.
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
#### Week 2
- [ ] Fancy profile page effects like blurring and resizing the background banner image when panning
- [ ] Allow user to switch between accounts
- [ ] Allow user to add an account, or swipe to delete an account


The following **additional** features are implemented:
- [x] Timestamps are displayed with relative date formatting
- [x] Label retweets and display the original tweet as primary in a RT, in both Home timeline and Detail screen
- [x] Button to easily return to the top
- [x] Compose page has placeholder text to encourage text entry
- [x] Countdown label turns red within 20 characters of limit
- [x] Enable buttons in timeline for each tweet cell to retweet, favorite, and reply.
#### Week 2
- [x] Tap on any profile pic in **any** timeline to go to that user's profile page
- [x] Add "Follow" button to profile page views of users who are not the logged in user
- [x] If user is already following the profile being displayed, change "Follow" button appearance and allow user to unfollow the profile
- [ ] Make "jump to top" button slowing appear (alpha 0 -> 1) as you scroll down the timeline
- [ ] Display hyperlinks, mentions, and hashtags in blue
- [ ] Display media in a tweet detail view

## Video Walkthrough

Here's a walkthrough of implemented user stories:

| [v1](https://github.com/wangela/wittier/tree/v1) walkthrough |  |
|:----:|:----:|
| <img src='anim_wittier_v1.gif' title='Week 1 Walkthrough' width='' alt='Week 1 Walkthrough Video' /> |  |
| v2 walkthrough of new features | v2 walkthrough (Following feature) |
| <img src='anim_wittier_v2.gif' title='Week 2 Walkthrough' width='' alt='Week 2 Walkthrough Video' /> | <img src='anim_wittier_v2following.gif' title='Week 2 Following Walkthrough' width='' alt='Week 2 Following Walkthrough Video' /> |

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Much of the time during this second week was spent on refactoring to make for more efficient code (reduce duplication, increase encapsulation, make code more readable). I implemented each feature 2-3 times because I would implement it naively or inefficiently first just to get it working, then I would refactor it to reuse existing code or existing viewcontrollers and views.

The foundation for displaying entities is in there, but I haven't completed the translation of entities into hyperlinks or rich media display yet. This will be on the backlog for a post-bootcamp sprint.

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
