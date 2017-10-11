###
#    Copyright 2015-2017 ppy Pty. Ltd.
#
#    This file is part of osu!web. osu!web is distributed with the hope of
#    attracting more community contributions to the core ecosystem of osu!.
#
#    osu!web is free software: you can redistribute it and/or modify
#    it under the terms of the Affero GNU General Public License version 3
#    as published by the Free Software Foundation.
#
#    osu!web is distributed WITHOUT ANY WARRANTY; without even the implied
#    warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#    See the GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with osu!web.  If not, see <http://www.gnu.org/licenses/>.
###

export class StoreCentili
  widget = '#c-mobile-payment-widget'

  ####################################################
  # This junk is stupid hack for a loading overlay
  # while the Centili script loads EVEN MORE SCRIPTS
  ####################################################
  clicked = false
  observer = new MutationObserver (mutations) ->
    mutations.forEach (mutation) ->
      $nodes = $(mutation.addedNodes)
      console.log($nodes)
      frame = $.grep $nodes, (elem) ->
        elem.id == 'fancybox-frame'

      content = $.grep $nodes, (elem) ->
        elem.id == 'fancybox-content'

      frame.length && window.LoadingOverlay.hide()
      if content.length && clicked
        # Queue up a click event
        Timeout.set 0, ->
          window.centiliJQuery(widget).trigger('click')

  $(document).on 'turbolinks:load', ->
    if document.querySelector(widget)
      observer.observe document.body, childList: true, subtree: true
  ####################################################
  # End stupid
  ####################################################

  @promiseInit: ->
    # Load Centili scripts and css async.
    Promise.all([
      StoreCentili.fetchScript('w_o-0.4.js'),
      StoreCentili.fetchScript('postmessage2.js'),
      StoreCentili.fetchStyle('fancybox/jquery.fancybox-1.3.4.css'),
    ])

  @fetchScript: (name) ->
    new Promise (resolve, reject) ->
      loading = window.turbolinksReload.load "https://www.centili.com/widget/js/#{name}", resolve
      resolve() unless loading

  @fetchStyle: (name) ->
    new Promise (resolve, reject) ->
      link = document.createElement('link')
      link.rel = 'stylesheet'
      link.type = 'text/css'
      link.href = "https://www.centili.com/widget/#{name}"
      link.media = 'screen'
      link.addEventListener 'load', resolve, false

      document.body.appendChild(link)

  @fakeClick: ->
    window.LoadingOverlay.show()
    window.LoadingOverlay.show.flush()
    if window.centiliJQuery
      window.centiliJQuery(widget).trigger('click')
      clicked = true
