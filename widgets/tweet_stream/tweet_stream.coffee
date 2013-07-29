class Dashing.TweetStream extends Dashing.Widget

  @accessor 'quote', ->
    "“#{@get('current_comment')?.body}”"

  ready: ->
    @list = []
    @limit = 50

  onData: (data) ->
    @list = (data.tweets.concat @list)[0...@limit]
    @set 'tweets', @list
    console.log(@list.length)

  nextComment: =>
    comments = @get('comments')
    if comments
      @commentElem.fadeOut =>
        @currentIndex = (@currentIndex + 1) % comments.length
        @set 'current_comment', comments[@currentIndex]
        @commentElem.fadeIn()
