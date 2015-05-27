angular.module('loomioApp').controller 'ThreadPageController', ($scope, $routeParams, $location, $rootScope, Records, MessageChannelService, CurrentUser, DiscussionFormService, ScrollService) ->
  $rootScope.$broadcast('currentComponent', { page: 'threadPage'})

  @performScroll = ->
    focusedElement = @focusedElement()
    if focusedElement && !@scrolledAlready
      ScrollService.scrollTo focusedElement
      @scrolledAlready = true

  @focusedElement = ->
    if $location.hash().match(/^proposal-\d+$/) and Records.proposals.find(@focusedProposalId)
      "#proposal-#{@focusedProposalId}"
    else if @discussion.lastSequenceId == 0 or @discussion.reader().lastReadSequenceId == -1
      ".thread-context"
    else if Records.events.findByDiscussionAndSequenceId(@discussion, @focusedSequenceId)
      "#sequence-#{@focusedSequenceId}"

  @init = (discussion) =>
    if discussion and !@discussion?
      @discussion = discussion
      @group = @discussion.group()
      
      $rootScope.$broadcast 'setTitle', @discussion.title
      $rootScope.$broadcast 'viewingThread', @discussion

      MessageChannelService.subscribeTo "/discussion-#{@discussion.key}"
      @performScroll()

  @init Records.discussions.find $routeParams.key
  Records.discussions.findOrFetchByKey($routeParams.key).then @init, (error) ->
    $rootScope.$broadcast('pageError', error)

  $scope.$on 'threadPageEventsLoaded',    (event, sequenceId) =>
    @eventsLoaded = true
    @focusedSequenceId = sequenceId
    @performScroll() if @proposalsLoaded
  $scope.$on 'threadPageProposalsLoaded', (event, proposalId) =>
    @proposalsLoaded = true
    @focusedProposalId = proposalId
    @performScroll()

  @showLintel = (bool) ->
    $rootScope.$broadcast('showThreadLintel', bool)

  @editDiscussion = ->
    DiscussionFormService.openEditDiscussionModal(@discussion)

  @showContextMenu = =>
    @canEditDiscussion(@discussion)

  @canEditDiscussion = =>
    CurrentUser.canEditDiscussion(@discussion)

  return
