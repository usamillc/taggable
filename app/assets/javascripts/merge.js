var requesting = false;

function canRequest() {
  if (requesting) {
    return false;
  } else {
    requesting = true;
    return true;
  }
}

function annotateSelectedTextWithSelectedAttr() {
  var attributeId = getAttributeId();
  annotateSelectedText(attributeId);
}

function getRootNode(range) {
  var node = range.startContainer.parentNode;

  while (node.tagName != "SPAN" || node.className != "paragraph") {
    node = node.parentNode;
  }

  return node;
}

function calcOffsetAndText(root, node) {
  var offset = 0;
  var text = '';

  var stack = Array.prototype.slice.call(root.childNodes).reverse();

  console.log(stack);
  while (stack.length > 0) {
    var current = stack.pop();
    console.log(current.nodeName);
    if (current == node) {
      console.log('match');
      break;
    }
    if (current.nodeName == "SPAN" && current.className == "tag") {
      continue;
    } else if (current.nodeName != "#text") {
      var children = Array.prototype.slice.call(current.childNodes).reverse();
      stack = stack.concat(children);
    } else {
      var s = current.textContent;
      offset += [...s].length;
      text   += s;
    }
  }
  return [offset, text];
}

function noSelection(selection, range) {
  return selection.type == "Caret" && range.startContainer.parentNode.nodeName != "MARK";
}

function selectedHighlight(selection, range) {
  return selection.type == "Caret" && range.startContainer.parentNode.nodeName == "MARK";
}

function annotateSelectedText(attributeId) {
  if (!canRequest()) {
    return;
  }

  var selection = window.getSelection();
  var range = selection.getRangeAt(0);

  if (noSelection(selection, range)) {
    console.log("no selection");
    requesting = false;
    return;
  }

  var root = getRootNode(range);
  var paragraphId = root.getAttribute('data-paragraphid');

  console.log(root);
  console.log(range);
  console.log(range.startContainer);
  console.log("paragraphId: " + paragraphId);

  var offsetAndText = calcOffsetAndText(root, range.startContainer);

  var offset = offsetAndText[0];
  var origText = offsetAndText[1];

  console.log("offset: " + offset);

  var startOffset;
  var endOffset;
  var value;

  if (selectedHighlight(selection, range)) {
    value = range.startContainer.textContent;
    startOffset = offset;
    endOffset = offset + [...value].length;
    origText += value;
  } else {
    // selection
    var nodeText;
    if (range.startContainer == range.endContainer) {
      // no multiple container
      console.log('single');
      nodeText = range.startContainer.textContent;
      value = nodeText.substr(range.startOffset, range.endOffset - range.startOffset);
      var s = nodeText.slice(0, range.endOffset);
      endOffset = offset + [...s].length;
      console.log("range.endOffset: " + range.endOffset);
      console.log("UTF8 Offset: " + [...s].length);
    } else {
      var middleContainersTextContent = '';

      var stack = Array.prototype.slice.call(range.commonAncestorContainer.childNodes).reverse();

      var middle = false;

      console.log(stack);
      while (stack.length > 0) {
        var current = stack.pop();
        console.log(current.nodeName);
        if (current == range.startContainer) {
          console.log('start');
          middle = true;
          continue;
        }
        if (current == range.endContainer) {
          console.log('end');
          middle = false;
          break;
        }
        if (current.nodeName == "SPAN" && current.className == "tag") {
          continue;
        } else if (current.nodeName != "#text") {
          var children = Array.prototype.slice.call(current.childNodes).reverse();
          stack = stack.concat(children);
        } else if (middle) {
          console.log(current);
          middleContainersTextContent += current.textContent;
        }
      }

      console.log(middleContainersTextContent);

      nodeText = range.startContainer.textContent + middleContainersTextContent + range.endContainer.textContent;
      console.log(nodeText);
      value = nodeText.substr(range.startOffset, range.startContainer.textContent.length + middleContainersTextContent.length + range.endOffset - range.startOffset);
      var s = range.endContainer.textContent.slice(0, range.endOffset);
      endOffset = offset + [...range.startContainer.textContent].length + [...middleContainersTextContent].length + [...s].length;
    }
    origText += nodeText;
    var s = range.startContainer.textContent.slice(0, range.startOffset);

    startOffset = offset + [...s].length;
  }

  console.log("origText: " + origText);
  console.log("startOffset: " + startOffset);
  console.log("endOffset: " + endOffset);
  console.log("value: " + value);

  postAnnotation(paragraphId, attributeId, startOffset, endOffset, value, origText);
}

function postAnnotation(paragraphId, attributeId, startOffset, endOffset, value, origText) {
  $.ajax({
    type:'POST',
    url:'/merge_attributes/' + attributeId + '/merge_tags',
    data: { merge_tag:
      {
        paragraph_id: paragraphId,
        start_offset: startOffset,
        end_offset: endOffset,
        value: value,
        text: origText
      }
    }})
    .done(function(data) {
      var mainY = window.pageYOffset;

      var search = $.query.set('main_y', mainY);
      window.location.search = search;
    })
    .always(function() {
      requesting = false;
    });
}

$(document).ready(function () {
  var mainY = $.query.get('main_y')
  if (mainY) {
    window.scrollTo(0, mainY);
  }

  $('[data-toggle="tooltip"]').tooltip();

  $('mark').click(function(e) {
    $('mark.bold').removeClass('bold');
    $(this).addClass('bold');
  });

  $('span.tag')
    .mouseover(function(e) {
      var mergeTagId = this.getAttribute('data-mergeTagId');
      $('span.tag[data-mergeTagId=' + mergeTagId + ']').addClass('bold');
    })
    .mouseleave(function(e) {
      var mergeTagId = this.getAttribute('data-mergeTagId');
      $('span.tag[data-mergeTagId=' + mergeTagId + ']').removeClass('bold');
    })
    .click(function(e) {
      var mergeTagId = this.getAttribute('data-mergeTagId');
      $('#deleteTagModal-' + mergeTagId).modal({});
    });

  // approve action
  $('span.spinner-border').hide();
  $('span.approved').hide();
  $('a.btn.btn-success.complete-hidden').hide();

  $('span.dropdown-item.approve')
    .click(function(e) {
      var mergeTagId = this.getAttribute('data-mergeTagId');
      $('span.spinner-border[data-mergeTagId=' + mergeTagId + ']').show();
      $.ajax({
        type: 'PUT',
        url: '/merge_tags/' + mergeTagId + '/approve'
      })
        .done(function(d) {
          // approve animation
          $('span.approved[data-mergeTagId=' + mergeTagId + ']').show();
          $('div.approve-dropdown[data-mergeTagId=' + mergeTagId + ']').hide();
          $('span.approved[data-mergeTagId=' + mergeTagId + ']').show();
          $('span.badge.approved[data-mergeTagId=' + mergeTagId + ']').delay(1000).fadeOut(400);

          // update count
          var count = parseInt($('span.badge.active-count').text()) - 1;
          if (count == 0) {
            $('span.badge.active-count').hide();
            $('a.btn.btn-success.complete-hidden').show();
          } else {
            $('span.badge.active-count').text(count);
          }
        })
        .always(function(d) {
          $('span.spinner-border').hide();
        });
    });
});

$(document).bind('keydown', 'z', annotateSelectedTextWithSelectedAttr);
$(document).bind('keydown', 'm', annotateSelectedTextWithSelectedAttr);
