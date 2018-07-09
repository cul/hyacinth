Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor = function(containerElementId, options) {

  this.$containerElement = $('#' + containerElementId);
  this.digitalObject = options['digitalObject'];
  this.mode = options['mode'];
  this.assignment = options['assignment'];
  this.init();
};

/*******************************
 *******************************
 * Class methods and variables *
 *******************************
 *******************************/

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS = 'digital-object-annotation-editor';
Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY = 'annotation_editor';

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.getEditorInstanceForElement = function(element) {
  return $(element).closest('.' + Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS).data(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY);
};

/**********************************
 **********************************
 * Instance methods and variables *
 **********************************
 **********************************/

/*******************
 * Setup / Cleanup *
 *******************/

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.init = function() {

  var that = this;

  this.$containerElement.addClass(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_ELEMENT_CLASS); //Add class to container element
  this.$containerElement.data(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY, this); //Assign this editor object as data to the container element so that we can access it later

  if(['MovingImage', 'Sound'].indexOf(this.digitalObject.getDcType()) > -1) {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_annotation_editor/oh_synchronizer.ejs', {
        digitalObject: this.digitalObject,
        mode: that.mode,
        assignment: this.assignment
      })
    );
    this.synchronizerWidget = this.createSynchronizerWidget();
  } else {
    this.$containerElement.html(
      Hyacinth.DigitalObjectsApp.renderTemplate('digital_objects_app/widgets/digital_object_annotation_editor/unsupported_object_type.ejs', {
        digitalObject: this.digitalObject,
        mode: that.mode,
        assignment: this.assignment
      })
    );
  }
};

Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.createSynchronizerWidget = function(){
  var that = this;

  // Don't show the A/V controls, errorBar, or Tag button
	$("#video").hide();
	$("#audio").hide();
	$("#tag-segment-btn").hide();
	$("#tag-controls").hide();
	$("#sync-controls").hide();
	$("#finish-area").hide();
	$("#transcript-preview").hide();

	// Initialize close buttons, tabs, and accordion
	OHSynchronizer.Index.closeButtons();

	// Update the Tag Segment timestamp when the modal opens from Add Segment
	$('.tag-add-segment').click(function () {
		$(".tag-controls").show();
		OHSynchronizer.playerControls.updateTimestamp();
	});

	$('.preview-button').bind('click', function() {
		OHSynchronizer.Export.previewWork('index');
	});

	// Scroll to top function
	$('#working-area').scroll(function() {
		$('#media-playback').css('top', $(this).scrollTop());
	});
	// Here we post success messages for uploaded files
	OHSynchronizer.Events.uploadsuccess = function(event) {
		var file = event.detail;
		var success = "";
		success += '<div class="col-md-6"><i class="fa fa-times-circle-o close"></i><p class="success-bar"><strong>Upload Successful</strong><br />File Name: ' + file.name + "<br />File Size: " + parseInt(file.size / 1024, 10) + "<br />File Type: " + file.type + "<br />Last Modified Date: " + new Date(file.lastModified) + "</div>";
		$("#messagesBar").append(success);
	};
	// Here we post success messages for streaming/hls links
	OHSynchronizer.Events.hlssuccess = function(event) {
		var url = event.detail;
		var success = "";
		success += '<div class="col-md-6"><i class="fa fa-times-circle-o close"></i><p class="success-bar"><strong>Upload Successful</strong><br />The Wowza URL ' + url + " was successfully ingested.</div>";
		$("#messagesBar").append(success);
	};

  var widgetOptions = {
    player: {
      type: 'video',
  		url: '/digital_objects/' + this.digitalObject.getPid() + '/download_access_copy'
    },
    index: {
      id: 'input-index',
      url: '/synchronizer-module/assets/OHMS-Sample-003.metadata.vtt'
    },
    options: {
      previewOnly: false
    }
  };

	var widget = new OHSynchronizer(widgetOptions);
	if (widgetOptions.options.previewOnly) {
		widget.hideFinishingControls();
	} else {
		$('.preview-button').on('click', function() {
			widget.transcript.preview();
		});
	}

  // Manually initialize the widget's player because it normally relies on jQuery's document ready
  that.$containerElement.find('video, audio').each(function (index, element) {
    if ($(element).data('able-player') !== undefined) {
      new AblePlayer($(this),$(element));
    }
  });
};

//Clean up event handlers
Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.prototype.dispose = function() {
  this.$containerElement.removeData(Hyacinth.DigitalObjectsApp.DigitalObjectAnnotationEditor.ANNOTATION_EDITOR_DATA_KEY) // Break this (circular) reference.  This is important!
};
