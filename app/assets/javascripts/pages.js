var requesting = false;
var attributes;
var HIGHLIGHTS_DELIMITER = '|';

function canRequest() {
  if (requesting) {
    return false;
  } else {
    requesting = true;
    return true;
  }
}

function undo() {
  if (canRequest()) {
    $.ajax({
      type:'DELETE',
      url:'/annotations/undo',
      data: { task_id: getTaskId() }
    })
      .done(function() {
        location.reload();
      })
      .always(function() {
        requesting = false;
      });
  }
}

function redo() {
  if (canRequest()) {
    $.ajax({
      type:'PUT',
      url:'/annotations/redo', data: { task_id: getTaskId() }
    })
      .done(function() {
        location.reload();
      })
      .always(function() {
        requesting = false;
      });
  }
}

function getTaskId() {
  var path = window.location.pathname.split('/');
  return path[path.length - 1];
}

function getSelectedAttributeId() {
  var radios = document.getElementsByName('attribute');

  for (var i = 0, length = radios.length; i < length; i++) {
    if (radios[i].checked) {
      return radios[i].id;
    }
  }
}

function getSelectedAttributeName() {
  var radios = document.getElementsByName('attribute');

  for (var i = 0, length = radios.length; i < length; i++) {
    if (radios[i].checked) {
      return radios[i].getAttribute('data-screenname');
    }
  }
}

function toggleView(plain) {
  var mainY = window.pageYOffset;
  var attributeId = getSelectedAttributeId();
  var search = $.query.set('plain', plain.toString()).set('main_y', mainY).set('attribute_id', attributeId);
  window.location.search = search;
}

function toggleHighlight(v) {
  var mainY = window.pageYOffset;
  var attributeId = getSelectedAttributeId();
  var highlights = $.query.get('highlights');
  if (typeof(highlights) != "boolean") {
    highlights = highlights.split(HIGHLIGHTS_DELIMITER);
  } else {
    highlights = [];
  }
  i = highlights.indexOf("");
  if (i > -1) {
    highlights.splice(i, 1);
  }
  i = highlights.indexOf(v);
  if (i > -1) {
    highlights.splice(i, 1);
  } else {
    highlights.push(v);
  }
  var search = $.query.set('main_y', mainY).set('attribute_id', attributeId);
  if (highlights.length > 0) {
    search = search.set('highlights', highlights.join(HIGHLIGHTS_DELIMITER));
  } else {
    search = search.remove('highlights');
  }
  window.location.search = search;
}

function disableHighlights() {
  var mainY = window.pageYOffset;
  var attributeId = getSelectedAttributeId();
  var search = $.query.remove('highlights').set('main_y', mainY).set('attribute_id', attributeId);
  window.location.search = search;
}

function annotateSelectedTextWithSelectedAttr() {
  var attributeId = getSelectedAttributeId();
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
      offset += current.length;
      text   += current.textContent;
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
    endOffset = offset + value.length;
    origText += value;
  } else {
    // selection
    var nodeText;
    if (range.startContainer == range.endContainer) {
      // no multiple container
      nodeText = range.startContainer.textContent;
      value = nodeText.substr(range.startOffset, range.endOffset - range.startOffset);
      endOffset = offset + range.endOffset;
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
      endOffset = offset + range.startContainer.textContent.length + middleContainersTextContent.length + range.endOffset;
    }
    origText += nodeText;
    startOffset = offset + range.startOffset;
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
    url:'/annotations',
    data: { annotation:
      {
        paragraph_id: paragraphId,
        annotation_attribute_id: attributeId,
        start_offset: startOffset,
        end_offset: endOffset,
        value: value,
        text: origText
      }
    }})
    .done(function(data) {
      var mainY = window.pageYOffset;
      var highlights = $.query.get('highlights');
      if (typeof(highlights) != "boolean") {
        highlights = highlights.split(HIGHLIGHTS_DELIMITER);
        i = highlights.indexOf("");
        if (i > -1) {
          highlights.splice(i, 1);
        }
      } else {
        highlights = [];
      }
      value = data.value;
      if (highlights.indexOf(value) < 0) {
        highlights.push(value);
      }

      var search = $.query.set('highlights', highlights.join(HIGHLIGHTS_DELIMITER)).set('plain', 'false').set('main_y', mainY).set('attribute_id', attributeId);
      window.location.search = search;
    })
    .always(function() {
      requesting = false;
    });
}

function deleteAnnotationOnCursor() {
  var selection = window.getSelection();
  if (selection.rangeCount) {
    var node = selection.focusNode.parentNode;
    var annotationId = node.getAttribute('data-annotationid');
    if (annotationId) {
      deleteAnnotation(annotationId);
    }
  }
}

function deleteAnnotation(annotationId) {
  if (canRequest()) {
    $.ajax({
      type:'DELETE',
      url:'/annotations',
      data: { annotation:
        {
          annotation_id: annotationId,
        }
      }})
      .done(function(data) {
        var value = data.value;

        var highlights = $.query.get('highlights');
        if (typeof(highlights) != "boolean") {
          highlights = highlights.split(HIGHLIGHTS_DELIMITER);
          i = highlights.indexOf("");
          if (i > -1) {
            highlights.splice(i, 1);
          }
        } else {
          highlights = [];
        }
        i = highlights.indexOf(value);
        if (i > -1) {
          highlights.splice(i, 1);
        }

        var mainY = window.pageYOffset;
        var attributeId = getSelectedAttributeId();
        var search = $.query.set('main_y', mainY).set('attribute_id', attributeId);

        if (highlights.length > 0) {
          search = search.set('highlights', highlights.join(HIGHLIGHTS_DELIMITER));
        } else {
          search = search.remove('highlights');
        }

        window.location.search = search;
      })
      .always(function() {
        requesting = false;
      });
  }
}

$(document).ready(function () {
  $("#sidebar").mCustomScrollbar({
    theme: "minimal"
  });
  var mainY = $.query.get('main_y')
  if (mainY) {
    window.scrollTo(0, mainY);
  }

  $('mark').click(function(e) {
    $('mark.bold').removeClass('bold');
    $(this).addClass('bold');
  });
  $('span.tag').click(function(e) {
    $('span.tag.bold').removeClass('bold');
    var annotationId = this.getAttribute('data-annotationid');
    $('span.tag[data-annotationid=' + annotationId + ']').addClass('bold');
  });
  $('input.highlight-attribute').click(function(e) {
    if (canRequest()) {
      var attributeId = this.getAttribute('data-attributeid');
      var mainY = window.pageYOffset;
      var checked = this.getAttribute('checked');

      $.ajax({
        type: 'GET',
        url: '/tasks/' + getTaskId() + '/values_for/' + attributeId,
        success: function(data) {
          var values = data.map (x => x.value);

          var highlights = $.query.get('highlights');
          if (typeof(highlights) != "boolean") {
            highlights = highlights.split(HIGHLIGHTS_DELIMITER);
          } else {
            highlights = [];
          }
          i = highlights.indexOf("");
          if (i > -1) {
            highlights.splice(i, 1);
          }

          if (checked == "") {
            // check removed
            for (var i = 0; i < values.length; i++) {
              var j = highlights.indexOf(values[i]);
              if (j > -1) {
                highlights.splice(j, 1);
              }
            }
          } else {
            // checked
            for (var i = 0; i < values.length; i++) {
              var j = highlights.indexOf(values[i]);
              if (j < 0) {
                highlights.push(values[i]);
              }
            }
          }
          var search = $.query.set('main_y', mainY).set('attribute_id', attributeId);
          if (highlights.length > 0) {
            search = search.set('highlights', highlights.join(HIGHLIGHTS_DELIMITER));
          } else {
            search = search.remove('highlights');
          }
          window.location.search = search;
        },
        complete: function() {
          requesting = false;
        }
      })
    }
  });

  $('input.highlight-value').click(function(e) {
    var value = this.getAttribute('data-value');
    toggleHighlight(value);
  });

  $.ajax({
    type:'GET',
    url:'/tasks/' + getTaskId() + '/attributes'
  })
    .done(function(data) {
      attributes = data;
    });

  $.contextMenu({
    selector: "span.tag",
    callback: function(key, opt) {
      var annotationId = opt.$trigger[0].getAttribute('data-annotationid');
      deleteAnnotation(annotationId);
    },
    items: {
      remove: { name: 'このタグを消去' }
    }
  });

  $.contextMenu({
    selector: ".taggable",
    position: function(opt, x, y) {
      opt.$menu.css({top: y, left: x});
    },
    build: function($trigger, e) {
      return {
        callback: function(key, opt) {
          annotateSelectedText(key);
        },
        items: attributes.reduce(function(h, a) {
          h[a.id] = {
            name: '[' + a.screenname + ']タグをつける'
          };
          return h;
        }, {})
      };
    }
  });
});
$(document).bind('keydown', 'z', annotateSelectedTextWithSelectedAttr);
$(document).bind('keydown', 'm', annotateSelectedTextWithSelectedAttr);
$(document).bind('keydown', 'd', deleteAnnotationOnCursor);
