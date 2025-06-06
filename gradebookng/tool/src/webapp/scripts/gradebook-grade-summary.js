/**************************************************************************************
 *                    Gradebook Grade Summary  Javascript                                      
 *************************************************************************************/

/**************************************************************************************
 * A GradebookGradeSummary to encapsulate all the grade summary content behaviours 
 */
function GradebookGradeSummary($content, blockout, modalTitle) {
  var self = this;
  this.$content = $content;

  this.blockout = blockout || false;

  this.modalTitle = modalTitle || false;

  this.studentId = this.$content.find("[data-studentid]").data("studentid");

  this.setupCategoryToggles();
  this.setupPopovers();

  this.$modal = this.$content.closest(".wicket-modal");

  if (this.$modal.length > 0 && this.$modal.is(":visible")) {
    this.setupWicketModal();
  } else {
    setTimeout($.proxy(function() {
      this.$modal = this.$content.closest(".wicket-modal");
      if (this.$modal.length > 0 && this.$modal.is(":visible")) {
        this.setupWicketModal();
      } else {
        this.setupStudentView();
      }
    }, this));
  }

  $("body").on("DOMNodeInserted", ".wicket-top-modal", function() {
    self.positionModalAtTop($(this));
  });
};


GradebookGradeSummary.prototype.setupWicketModal = function() {
    this.updateTitle();
    this.setupTabs();
    this.setupStudentNavigation();
    this.setupFixedFooter();
    this.setupTableSorting();
    this.setupMask();
    this.setupModalPrint();
    this.bindModalClose();
};


GradebookGradeSummary.prototype.updateTitle = function() {
  if (this.modalTitle) {
    this.$modal.find("h3[class='w_captionText']").html(this.modalTitle);
  }
};


GradebookGradeSummary.prototype.setupTabs = function() {
  // if blockout, then confirmation required when changing tabs
  if (this.blockout) {
    var $otherTab = this.$content.find(".nav.nav-tabs li:not(.active) a");
    var $cloneOfTab = $otherTab.clone();

    $otherTab.hide();
    $cloneOfTab.attr("href", "javascript:void(0)").removeAttr("id");
    $cloneOfTab.insertAfter($otherTab);
    $cloneOfTab.click(function(event) {
      event.stopPropagation();

      var $confirmationModal = $($("#studentGradeSummaryCloseConfirmationTemplate").html());
      $confirmationModal.on("click", ".btn-student-summary-continue", function() {
        $otherTab.trigger("click");
      });
      $(document.body).append($confirmationModal);
      const modal = new bootstrap.Modal($confirmationModal).toggle();
      $confirmationModal.on("hidden.bs.modal", function() {
        $confirmationModal.remove();
        $cloneOfTab.focus();
      });
      $confirmationModal.on("shown.bs.modal", function() {
        $confirmationModal.find(".btn-student-summary-cancel").focus();
      });
    });
  }
};


GradebookGradeSummary.prototype.setupCategoryToggles = function() {
  this.$content.find(".gb-summary-category-toggle").click(function() {
    var $toggle = $(this);
    if ($toggle.is(".collapsed")) {
      $toggle.closest("tbody").next(".gb-summary-assignments-tbody").find(".gb-summary-grade-row").show();
    } else {
      $toggle.closest("tbody").next(".gb-summary-assignments-tbody").find(".gb-summary-grade-row").hide();
    }
    $toggle.toggleClass("collapsed");
  });

  this.$content.find(".gb-summary-expand-all").click(function() {
    $(".gb-summary-category-toggle.collapsed").trigger("click");
  });
  this.$content.find(".gb-summary-collapse-all").click(function() {
    $(".gb-summary-category-toggle:not(.collapsed)").trigger("click");
  });
};


GradebookGradeSummary.prototype.setupStudentNavigation = function() {
  var $showPrevious = this.$content.find(".gb-summary-previous-student");
  var $showNext = this.$content.find(".gb-summary-next-student");
  var $done = this.$content.find(".gb-summary-close");

  var currentStudentIndex = GbGradeTable.rowForStudent(this.studentId);

  // get the students as they are currently rendered so the sorting/filtering is accurately reflected
  const studentsAsRendered = GbGradeTable.instance.getDataAtCol(0);

  var previousStudentId, nextStudentId;
  if (currentStudentIndex > 0) {
    previousStudentId = studentsAsRendered[currentStudentIndex - 1].userId;
  }
  if (currentStudentIndex < studentsAsRendered.length - 1) {
    nextStudentId = studentsAsRendered[currentStudentIndex + 1].userId;
  } 

  if (previousStudentId) {
    $showPrevious.click(function() {
      GbGradeTable.viewGradeSummary(previousStudentId);
    });
  } else {
    $showPrevious.hide();
  }

  if (nextStudentId) {
    $showNext.click(function() {
      GbGradeTable.viewGradeSummary(nextStudentId);
    });    
  } else {
    $showNext.hide();
  }
};


GradebookGradeSummary.prototype.setupFixedFooter = function() {
  // do this by setting the height of the tab content to leave room for the navigation
  var $tabPane = this.$content.find(".gb-summary-grade-panel");

  // reset height
  $tabPane.removeAttr("style");

  if (this.$modal.height() > $(window).height()) {
    var $contentPane =  this.$modal.find(".gb-grade-summary-content");

    var paddingSize = 100; // modal padding and modal content padding/margins (yep... fudged)

    var height = $tabPane.height() - (this.$modal.height() - $(window).height()) - ($contentPane.height() - this.$modal.height()) - paddingSize;

    $tabPane.height(Math.max(200, height));
  }
};


GradebookGradeSummary.prototype.setupMask = function() {
  var $mask = this.$modal.siblings(".wicket-mask-transparent, .wicket-mask-dark");
  if (this.blockout) {
    // Darken the mask
    $mask.removeClass("wicket-mask-transparent").addClass("wicket-mask-dark");
    // Add a blur effect to the main page container
    $("#pageBody").addClass("gb-blur");
  } else {
    $mask.removeClass("wicket-mask-dark").addClass("wicket-mask-transparent");
    GradebookGradeSummaryUtils.clearBlur();
  }
};


GradebookGradeSummary.prototype.bindModalClose = function() {
  var self = this;

  if (self.blockout) {
    self.$content.find(".gb-summary-fake-close").show();
    self.$content.find(".gb-summary-close").hide();
  } else {
    self.$content.find(".gb-summary-fake-close").hide();
    self.$content.find(".gb-summary-close").show();
  }

  function showConfirmation(event) {
    if (self.blockout) {
      event.preventDefault();
      event.stopPropagation();

      var $confirmationModal = $($("#studentGradeSummaryCloseConfirmationTemplate").html());
      $confirmationModal.on("click", ".btn-student-summary-continue", function() {
        self.$modal.find(".gb-summary-close").trigger("click");
      });
      $(document.body).append($confirmationModal);
      const modal = new bootstrap.Modal($confirmationModal).toggle();
      $confirmationModal.on("hidden.bs.modal", function() {
        $confirmationModal.remove();
        self.$content.find(".gb-summary-fake-close").focus();
      });
      $confirmationModal.on("shown.bs.modal", function() {
        $confirmationModal.find(".btn-student-summary-cancel").focus();
      });

      return false;
    } else {
      if ($(this).data("clickCallback")) {
        $(this).data("clickCallback")();
      }

      return true;
    }
  }

  self.$modal.find(".w_close, .gb-summary-fake-close").each(function() {
    if (this.onclick) {
      $(this).data("clickCallback", this.onclick);
      this.onclick = null;
    }
  });

  self.$modal.find(".w_close, .gb-summary-fake-close").off("click").on("click", showConfirmation);
};


GradebookGradeSummary.prototype.setupPopovers = function() {

  this.$content[0].querySelectorAll('[data-bs-toggle="popover"]').forEach(el => {
    (new bootstrap.Popover(el));
  });
};


GradebookGradeSummary.prototype.setupModalPrint = function() {
    var self = this;
    self.setupTableSorting();

    var $button = this.$content.find(".gb-summary-print");
    $button.off("click").on("click", function() {
      self._print(
        self.$modal.find("h3[class*='w_captionText']")[0].outerHTML,
        self.$content.find(".gb-summary-grade-panel")[0].outerHTML,
        self.$content);
    });
};


GradebookGradeSummary.prototype.setupStudentView = function() {
  var self = this;
  self.setupTableSorting();

  var $button = $("body").find(".portletBody .gb-summary-print");
  $button.off("click").on("click", function() {
    self._print(
      $("body").find(".portletBody h2:first")[0].outerHTML,
      $("body").find("#studentGradeSummary")[0].outerHTML,
      $("body"));
  });
};


GradebookGradeSummary.prototype._print = function(headerHTML, contentHTML) {
  const printWindow = window.open("", "_blank");

  if (!printWindow) {
    alert("Please allow popups for this website to print the document.");
    return;
  }

  printWindow.document.open();
  printWindow.document.write(`
    <!DOCTYPE html>
    <html lang="en">
      <head>
        <title>${document.title}</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
      </head>
      <body>
        ${headerHTML}
        ${contentHTML}
      </body>
    </html>
  `);
  printWindow.document.close();

  const href = $("link[rel='stylesheet'][href*='tool.css']").attr("href");
  if (href) {
    printWindow.document.head.insertAdjacentHTML(
      "beforeend",
      `<link rel="stylesheet" type="text/css" href="${href.startsWith("http") ? href : window.location.origin + href}">`
    );
  }

  printWindow.onload = function () {
    setTimeout(() => {
      printWindow.focus();
      printWindow.print();
      printWindow.close();
    }, 100);
  };
};

GradebookGradeSummary.prototype.setupTableSorting = function() {
  var $table = this.$content.find(".gb-summary-grade-panel table");

  var stickyHeaderContainer = null;
  if ($(".tab-pane.active .gb-summary-grade-panel").length == 1) {
    stickyHeaderContainer = $(".tab-pane.active .gb-summary-grade-panel");
  }

  $table.tablesorter({
    theme : "bootstrap",
    widthFixed: false,
    headerTemplate : '{content} {icon}',
    widgets : [ "uitheme", "zebra", "stickyHeaders" ],
    widgetOptions : {
      zebra : ["even", "odd"],
      //filter_reset : ".reset",
      filter_hideFilters : true,
      stickyHeaders_offset : 0,
      stickyHeaders_cloneId : '-sticky',
      stickyHeaders_addResizeEvent : true,
      stickyHeaders_zIndex : 2,
      stickyHeaders_attachTo : stickyHeaderContainer,
      stickyHeaders_xScroll : null,
      stickyHeaders_yScroll : null,
      stickyHeaders_filteredToTop: true
    },
    sortReset   : true,
    textExtraction: function(node) {
      var $node = $(node);
      // sort dates by data-sort-key
      if ($node.is(".gb-summary-grade-duedate")) {
        var time = $node.data("sort-key");
        if (time == 0) {
          // max integer value so assignments with no due date
          // appear after those with due dates (to match GB1)
          return Math.pow(2, 53)-1;
        }
        return time;
      // sort grades by their raw grade
      } else if ($node.is(".gb-summary-grade-score")) {
        var grade = $node.find(".gb-summary-grade-score-raw").text().trim();
        if (grade == "") {
          return -1;
        } else {
          return grade;
        }
      }

      return $(node).text().trim();
    },
    cssInfoBlock: "gb-summary-category-tbody"
  });
};


GradebookGradeSummary.prototype.positionModalAtTop = function($modal) {
    // position the modal at the top of the viewport
    // taking into account the current scroll offset
    $modal.closest('.wicket-modal').css('top', 30 + $(window).scrollTop() + "px");
};


var GradebookGradeSummaryUtils = {
  clearBlur: function() {
    $(".gb-blur").removeClass("gb-blur");
  }
};
