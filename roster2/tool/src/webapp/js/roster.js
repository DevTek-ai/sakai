
roster.members = [];
roster.helpers = {};

roster.setupPrintButton = function () {

  document.querySelector(".roster-print-button").addEventListener("click", e => {

    const button = e.target;

    button.disabled = true;

    e.preventDefault();
    roster.renderMembership({
      renderAll: true,
      printMode: true,
      callback: function () {

        const doIt = () => {

          Promise.all(Array.from(document.querySelectorAll("sakai-user-photo"))
            .map(sup => sup.updateComplete)).then(() => {

            imagesLoaded("#roster-members-content", () => {

              button.disabled = false;
              window.print();
            });
          });
        }
        
        if (document.readyState === "loading") {
          document.addEventListener("DOMContentLoaded", () => doIt());
        } else {
          doIt();
        }

      },
    });
  });

  // Exit "printMode" after print is done
  window.addEventListener('afterprint', event => {
    roster.renderMembership({ renderAll: true, printMode: false });
  });
};

/**
 * Renders a handlebars template.
 */
roster.render = function (template, data, outputId) {

  var t = Handlebars.templates[template];
  document.getElementById(outputId).innerHTML = t(data, {helpers: roster.helpers});
};

roster.addViewModeHandlers = function () {

  $('#roster-card-view-radio').click(roster.clickViewCardRadio);
  $('#roster-photo-view-radio').click(roster.clickViewPhotogridRadio);
  $('#roster-spreadsheet-view-radio').click(roster.clickViewSpreadsheetRadio);
};

roster.addPhotoSourceHandlers = function () {

  if (roster.currentUserPermissions.viewOfficialPhoto) {

    $('#roster_official_picture_button').click(function (e) {
      roster.officialPictureMode = true;
      roster.renderMembership({ replace: true});
    });

    $('#roster_profile_picture_button').click(function (e) {
      roster.officialPictureMode = false;
      roster.renderMembership({ replace: true });
    });
  }
};

roster.addHideOptionHandlers = function () {

  $('#roster-hide-pictures-checkbox').click(function (e) {

    if ($(this).prop('checked')) {
      $('.roster-picture-cell').addClass('roster-hide-pictures');
      $('#roster-picture-header-cell').addClass('roster-hide-pictures');
    } else {
      $('.roster-picture-cell').removeClass('roster-hide-pictures');
      $('#roster-picture-header-cell').removeClass('roster-hide-pictures');
    }
  });
  $('#roster-hide-names-checkbox').click(function (e) {

      if (this.checked) {
        document.querySelectorAll(".roster-info-card").forEach(e => e.style.display = "none");
      } else {
        document.querySelectorAll(".roster-info-card").forEach(e => e.style.display = "block");
      }
  });
};

roster.addAdditionalInfoModalHandlers = function () {

  $('button.additional-info').prop("onclick", null).off("click");

  $('button.additional-info').click(function (e) {

    const userId = this.getAttribute("data-user-id");
    roster.renderAdditionalInfoModal(userId)
  });
};

roster.changeActiveTab = function (state) {

  roster.initNavBar();
  var activeID = '';
  if (roster.STATE_OVERVIEW === state) {
    activeID = '#navbar_overview_link';
  } else if (roster.STATE_ENROLLMENT_STATUS === state) {
    activeID = '#navbar_enrollment_status_link';
  } else if (roster.STATE_PERMISSIONS === state) {
    activeID = '#navbar_permissions_link';
  }

  if (activeID !== '') {
    $(activeID + ' > span').addClass('current');
    var tabText = $(activeID + ' > span > a').text();
    $(activeID + ' > span > a').remove();
    $(activeID + ' > span').text(tabText);
  }
};

roster.switchState = function (state, args) {

  roster.currentState = state;
  roster.changeActiveTab(state);

  // permissions
  if (roster.showPermsToMaintainers) {
    $('#navbar_permissions_link').show();
  } else {
    $('#navbar_permissions_link').hide();
  }

  // don't show enrollments tab if user doesn't have permission, or there's no enrollment sets attached to the site
  if ((roster.currentUserPermissions && !roster.currentUserPermissions.viewEnrollmentStatus) ||
          roster.site.siteEnrollmentSets.length === 0) {

    $('#navbar_enrollment_status_link').hide();

    // this can happen if roster.default.state=3
    if (roster.STATE_ENROLLMENT_STATUS === state) {
      state = roster.DEFAULT_STATE;
    }
  }

  if (roster.STATE_OVERVIEW === state) {

    roster.enrollmentSetToView = null;
    roster.enrollmentStatus = 'all';
    roster.groupToView = (args && args.group) ? args.group : null;
    roster.roleToView = null;
    roster.nextPage = 0;

    roster.render('overview',
        { siteGroups: roster.site.siteGroups,
            membersTotal: roster.i18n.currently_displaying_participants.replace(/\{0\}/, roster.site.membersTotal),
            roleFragments: roster.getRoleFragments(roster.site.roleCounts),
            roles: roster.site.userRoles.sort(),
            checkOfficialPicturesButton: roster.officialPictureMode,
            viewGroup : roster.currentUserPermissions.viewGroup,
            viewOfficialPhoto: roster.currentUserPermissions.viewOfficialPhoto,
            defaultOverviewModeCards: ('cards' === roster.defaultOverviewMode),
            defaultOverviewModeSpreadsheet: ('spreadsheet' === roster.defaultOverviewMode),
            defaultOverviewModePhotogrid: ('photogrid' === roster.defaultOverviewMode)},
        'roster_content');

    $(function () {

      if (args && args.group) {
          $('#roster-group-option-' + args.group).prop('selected', true);
      }

      roster.addPhotoSourceHandlers();
      roster.addHideOptionHandlers();
      roster.addViewModeHandlers();
      roster.addExportHandler();

      if (roster.defaultOverviewMode === 'spreadsheet') {
        roster.clickViewSpreadsheetRadio();
      } else if (roster.defaultOverviewMode === 'photogrid') {
        roster.clickViewPhotogridRadio();
      } else {
        roster.clickViewCardRadio(true);
      }

      roster.setupPrintButton();
      roster.readySearchButton();
      roster.readySearchField();
      roster.readyClearButton(state);

      $('#roster-groups-selector').change(function (e) {

        if (this.value === 'all') {
          roster.groupToView = null;
          roster.renderMembership({ replace: true });
        } else {
          roster.renderGroupMembership(this.value);
        }
      });

      $('#roster-roles-selector').change(function (e) {

        $('#roster-search-field').val('');
        roster.userIds = null;
        roster.roleToView = (this.value === 'all') ? null : this.value;
        roster.renderMembership({ replace: true});
      });
    });

  } else if (roster.STATE_ENROLLMENT_STATUS === state) {

    roster.nextPage = 0;
    roster.roleToView = null;
    roster.groupToView = null;

    if (null === roster.enrollmentSetToView && null !== roster.site.siteEnrollmentSets[0]) {
        roster.enrollmentSetToView = roster.site.siteEnrollmentSets[0].id;
    }

    roster.render('enrollment_status',
      { enrollmentSets: roster.site.siteEnrollmentSets,
          onlyOne: roster.site.siteEnrollmentSets.length === 1,
          enrollmentStatusCodes: roster.site.enrollmentStatusCodes,
          viewOfficialPhoto: roster.currentUserPermissions.viewOfficialPhoto },
      'roster_content');

    $(function () {

      roster.addPhotoSourceHandlers();
      roster.addHideOptionHandlers();
      roster.addViewModeHandlers();
      roster.clickViewSpreadsheetRadio();
      roster.addExportHandler();
      roster.setupPrintButton();
      roster.readySearchButton();
      roster.readySearchField();
      roster.readyClearButton(state);

      $('#roster-enrollmentset-selector').change(function (e) {

        var option = this.options[this.selectedIndex];
        roster.enrollmentSetToView = option.value;
        roster.enrollmentSetToViewText = option.text;
        roster.renderMembership({ replace: true });
      });

      $('#roster-status-selector').change(function (e) {

        roster.enrollmentStatus = this.value;
        if (roster.enrollmentStatus === '') roster.enrollmentStatus = 'all';
        roster.renderMembership({ replace: true });
      });
      roster.renderMembership({ replace: true });
    });
  } else if (roster.STATE_PERMISSIONS === state) {
    roster.render('permissions', { siteTitle: roster.site.title }, 'roster_content');
  }
};

roster.renderAdditionalInfoModal = function (userId) {

  const member = roster.members.find(member => member.userId === userId);
  const memberName = roster.firstNameLastName ? member.displayName : member.sortName;
  const title = roster.helpers.tr("additionalInfo_modal_title", memberName);

  // Render additional_info_modal_content template to string
  const htmlContent = Handlebars.templates.additional_info_modal_content(member, { helpers: roster.helpers });

  roster.renderModalDialog(title, htmlContent, null);

  (new bootstrap.Modal(document.getElementById("roster-modal"))).show();
};

roster.renderModalDialog = function (title, htmlContent, htmlFooter) {

  roster.render('modal', { title, htmlContent, htmlFooter }, 'roster-modal-wrapper');
};

roster.renderGroupMembership = function (groupId) {

  if (groupId === roster.DEFAULT_GROUP_ID) {
    groupId = null;
  }

  $('#roster-search-field').val('');
  roster.userIds = null;

  roster.groupToView = groupId;
  roster.renderMembership({ replace: true });
};

roster.renderMembership = function (options) {

  const enrollmentsMode = roster.currentState === roster.STATE_ENROLLMENT_STATUS;

  if (roster.currentLayout !== "spreadsheet") {
      const header = document.getElementById("roster-members-table");
      header && header.parentNode.removeChild(header);
  }

  if (options.replace) {
    $('#roster-members').empty();
    roster.nextPage = 0;

    switch (roster.currentLayout) {
      case "spreadsheet":
        roster.render('members_container_table', {
          viewEmail: roster.viewEmail,
          viewUserDisplayId: roster.viewUserDisplayId,
          viewPronouns: roster.viewPronouns,
          viewProfileLink: roster.viewProfileLink,
          viewUserNamePronunciation: roster.viewUserNamePronunciation,
          viewUserProperty: roster.viewUserProperty,
          viewCandidateDetails: roster.viewCandidateDetails,
          anyAdditionalInfoPresent: roster.members.findIndex(m => m.additionalNotes || m.specialNeeds) > -1,
          anyStudentNumberPresent: roster.members.findIndex(m => m.studentNumber) > -1,
          viewProfile: roster.currentUserPermissions.viewProfile,
          viewGroup : roster.currentUserPermissions.viewGroup,
          viewPicture: true,
          viewSiteVisits: roster.currentUserPermissions.viewSiteVisits,
          viewConnections: ((undefined !== window.friendStatus) && roster.viewConnections),
          enrollmentsMode: enrollmentsMode,
          showVisits: roster.showVisits,
          }, 'roster-members-content');
        break;
      case "photogrid":
        roster.render('members_container_photos', {}, "roster-members-content");
        break;
      default:
        roster.render('members_container_cards', {}, "roster-members-content");
    }
  }

  if (options.renderAll) {
    $('#roster-members').empty();
  }

  let url = "/direct/roster-membership/" + roster.siteId;

  if (roster.userIds) {
    url += "/get-users.json?userIds=" + roster.userIds.join(',');
    if (roster.enrollmentSetToView) {
      url += "&enrollmentSetId=" + roster.enrollmentSetToView;
    }
  } else {
    url += '/get-membership.json?';
    if (options.renderAll) {
      url += 'all=true';
    } else {
      url += 'page=' + roster.nextPage;
    }
    if (roster.enrollmentSetToView) {
      url += "&enrollmentSetId=" + roster.enrollmentSetToView;
    }
  }
  
  if (roster.groupToView) {
    url += "&groupId=" + roster.groupToView;
  }
  
  if (roster.roleToView) {
    url += "&roleId=" + encodeURIComponent(roster.roleToView);
  }

  if (roster.enrollmentStatus) {
    url += '&enrollmentStatus=' + roster.enrollmentStatus;
  }

  // Calculate dynamic page sizes if not already set
  if (roster.cardsPageSize === undefined || roster.gridPageSize === undefined) {
    roster.calculatePageSizes();
  }

  if (roster.currentLayout === "cards") {
    roster.pageSize = roster.cardsPageSize;
  } else if ($('#roster_content').hasClass('view_mode_photogrid')) {
    roster.pageSize = roster.gridPageSize;
  } else {
    roster.pageSize = 50;
  }

  url += '&pageSize=' + roster.pageSize;

  var loadImage = $('#roster-loading-image')
  loadImage.show();

  $.ajax({
    url: url,
    dataType: "json",
    cache: false,
    success: function (data) {

      if (data.status && data.status === 'END') {
        loadImage.hide();

        if (roster.nextPage === 0) {
          var membersTotalString = roster.i18n.currently_displaying_participants.replace(/\{0\}/, 0);
          $('#roster-members-total').html(membersTotalString);
          $('#roster-role-totals').html('');
        }

        return;
      }

      var members = data.members;

      if (roster.nextPage === 0) {
        var membersTotalString = roster.i18n.currently_displaying_participants.replace(/\{0\}/, data.membersTotal);
        $('#roster-members-total').html(membersTotalString);
        var roleFragments = roster.getRoleFragments(data.roleCounts);
        $('#roster-role-totals').html(roleFragments);
      }

      members.forEach(function (m) {

        m.siteId = roster.siteId;
        m.official = roster.officialPictureMode;

        var groupIds = Object.keys(m.groups);
        m.hasGroups = groupIds.length > 0;
        m.groups = groupIds.reduce((acc, id) => { acc.push({id: id, title: m.groups[id]}); return acc; }, []);
        m.groups.sort(function (a, b) {
          return a.title.localeCompare(b.title);
        });

        if (m.totalSiteVisits <= 0) {
          m.lastVisitTime = roster.i18n.no_visits_yet;
        }

        m.hasProperties = m.userProperties && Object.keys(m.userProperties).length > 0;

        m.hasSpecialNeeds = m.specialNeeds && m.specialNeeds.length > 0;
        m.hasAdditionalNotes = m.additionalNotes && m.additionalNotes.length > 0;
        
        m.hasAdditionalInfo = m.hasSpecialNeeds || m.hasAdditionalNotes;

        // Append to the roster members the new loaded members.
        if (!roster.members.find(item => item.userId === m.userId)) {
          roster.members.push(m);
        }

      });

      roster.renderMembers(members, $('#roster-members'), enrollmentsMode, options);

      $(function () {

        if ($('#roster-hide-pictures-checkbox').prop('checked')) {
          $('.roster-picture-cell').addClass('roster-hide-pictures');
          $('#roster-picture-header-cell').addClass('roster-hide-pictures');
        }
        if ($('#roster-hide-names-checkbox').prop('checked')) {
          document.querySelectorAll(".roster-info-card").forEach(e => e.style.display = "none");
        }

        $('.roster-group-link').click(function (e) {

          var value = $(this).attr('data-groupid');

          if (roster.currentState === roster.STATE_ENROLLMENT_STATUS) {
            roster.switchState(roster.STATE_OVERVIEW, {group: value});
          } else {
            $('#roster-group-option-' + value).prop('selected', true);
            roster.renderGroupMembership(value);
          }
        });

        $('.roster-groups-selector').off('change').on('change', function(e) {
          var value = this.value;

          if (roster.currentState === roster.STATE_ENROLLMENT_STATUS) {
            roster.switchState(roster.STATE_OVERVIEW, {group: value});
          } else {
            $('#roster-group-option-' + value).prop('selected', true);
            roster.renderGroupMembership(value);
          }
        });

        roster.addAdditionalInfoModalHandlers();

        if (roster.userIds) {
        } else {
          if (!options.renderAll) {
            roster.nextPage += 1;
          }
        }

        loadImage.hide();

        if (options.callback) {
          options.callback();
        }
      });
    },
    error: function (jqXHR, textStatus, errorThrown) {
      if(jqXHR.status === 404){
        loadImage.hide();
        if (roster.nextPage === 0) {
          var membersTotalString = roster.i18n.currently_displaying_participants.replace(/\{0\}/, 0);
          $('#roster-members-total').html(membersTotalString);
          $('#roster-role-totals').html('');
        }
      } else {
        console.error(`Failed to get membership data. textStatus: ${textStatus}. errorThrown: ${errorThrown}`);
      }
    }
  });
};

roster.readyClearButton = function (state) {

  $('#roster_form_clear_button').click(function (e) {

    roster.roleToView = null;
    roster.groupToView = null;
    roster.userIds = null;
    roster.switchState(state);
  });
};

roster.search = function (query) {

  if (query !== roster.i18n.roster_search_text && query !== "") {
    var userIds = [];
    var i = 0;
    roster.searchIndexValues.forEach(function (displayName) {

      var regex = new RegExp(query, 'i');
      if (regex.test(displayName)) {
        userIds.push(roster.searchIndexKeys[i]);
      }
      i++;
    });
    //if query string is too short, show 20 users as much
    if (query.length < 3 && userIds.length > 20) {
      userIds = userIds.slice(0, 20);
    }

    if (userIds.length > 0) {
      roster.userIds = userIds;
      roster.renderMembership({ replace: true });
    } else {
      $('#roster-members').html('<div id="roster-information">' + roster.i18n.no_participants + '</div>');
      $('#roster-members-total').hide();
      $('#roster_type_selector').hide();
    }
  }
};

roster.readySearchButton = function () {

  let button = $('#roster-search-button');
  button.prop("disabled", true);

  this.searchIndexPromise.then(() => {

    button.prop("disabled", false).off('click').on('click', function (e) {

      var searchFieldValue = $('#roster-search-field').val();
      roster.search(searchFieldValue);
    });
  });
};

roster.readySearchField = function () {

  var field = $('#roster-search-field');
  field.prop("disabled", true);

  this.searchIndexPromise.then(() => {

    field.keydown(function (e) {

      if (e.which === 13) {
        e.preventDefault();
        $('#roster-search-button').click();
      }
    });

    field.autocomplete({
      source: roster.searchIndexValues,
      select: function (e, ui) {

        if (e.originalEvent && e.originalEvent.originalEvent && e.originalEvent.originalEvent.type === "click") {
          roster.search(ui.item.value);
        }
      }
    });
    field.prop("disabled", false);
  });
};

roster.renderMembers = function (members, target, enrollmentsMode, options) {

  const templateData = {
      members: members,
      groupToView :roster.groupToView,
      firstNameLastName: roster.firstNameLastName,
      viewEmail: roster.viewEmail,
      viewUserDisplayId: roster.viewUserDisplayId,
      viewPronouns: roster.viewPronouns,
      viewProfileLink: roster.viewProfileLink,
      viewUserNamePronunciation: roster.viewUserNamePronunciation,
      viewUserProperty: roster.viewUserProperty,
      viewCandidateDetails: roster.viewCandidateDetails,
      anyAdditionalInfoPresent: roster.members.findIndex(m => m.additionalNotes || m.specialNeeds) > -1,
      anyStudentNumberPresent: roster.members.findIndex(m => m.studentNumber) > -1,
      viewProfile: roster.currentUserPermissions.viewProfile,
      viewGroup : roster.currentUserPermissions.viewGroup,
      viewPicture: true,
      currentUserId: roster.userId,
      viewOfficialPhoto: roster.currentUserPermissions.viewOfficialPhoto,
      enrollmentsMode: enrollmentsMode,
      viewSiteVisits: roster.currentUserPermissions.viewSiteVisits,
      viewConnections: ((undefined !== window.friendStatus) && roster.viewConnections),
      showVisits: roster.showVisits,
      profileNamePronunciationLink: roster.profileNamePronunciationLink,
      printMode: options && options.printMode,
    };

  let t = null;
  switch (roster.currentLayout) {
    case "cards":
      t = Handlebars.templates['members_cards'];
      break;
    case "spreadsheet":
      t = Handlebars.templates['members_table'];
      break;
    case "photogrid":
      t = Handlebars.templates['members_photogrid'];
      break;
    default:
      t = Handlebars.templates['members_cards'];
  }

  target.append(t(templateData, {helpers: roster.helpers}));

  roster.observer.disconnect();
  if (!roster.userIds) {
    roster.observer.observe(document.querySelector(".roster-entry:last-child"));
  }
};

roster.getRoleFragments = function (roleCounts) {

  return Object.keys(roleCounts).sort().map(function (key) {

    var frag = roster.i18n.role_breakdown_fragment.replace(/\{0\}/, roleCounts[key]);
    return frag.replace(/\{1\}/, '<span class="role">' + key + '</span>');
  }).join(", ");
};

roster.addExportHandler = function () {

  var button = $('#roster-export-button');

  if (!roster.currentUserPermissions.rosterExport) {
    button.hide();
  } else {
    button.show().click(function (e) {

      e.preventDefault();

      var baseUrl = "/direct/roster-export/" + roster.siteId +
        "/export-to-excel?viewType=" + roster.currentState;

      if (roster.STATE_OVERVIEW === roster.currentState) {
        var groupId = null;
        if (null !== roster.groupToView) {
          groupId = roster.groupToView;
        } else {
          groupId = roster.DEFAULT_GROUP_ID;
        }

        if (null !== roster.roleToView) {
          baseUrl += "&roleId=" + roster.roleToView;
        }

        window.location.href = baseUrl + "&groupId=" + groupId;
      } else if (roster.STATE_ENROLLMENT_STATUS === roster.currentState) {

        window.location.href = baseUrl +
          "&enrollmentSetId=" + roster.enrollmentSetToView +
          "&enrollmentStatus=" + roster.enrollmentStatus;
      }
    });
  }
};

roster.clickViewCardRadio = function (render) {

  // Hide and unapply both 'hide photos', and 'hide names' settings
  if ($('#roster-hide-pictures-checkbox').is(':checked')) {
    $('#roster-hide-pictures-checkbox').trigger('click');
  }
  if ($('#roster-hide-names-checkbox').is(':checked')) {
    $('#roster-hide-names-checkbox').trigger('click');
  }
  $('#roster_hide_options').hide();

  $('#roster_content').removeClass('view_mode_spreadsheet view_mode_photogrid');

  //document.querySelector(".roster-print-button").style.display = "initial";

  roster.currentLayout = "cards";

  // Re-render table with dynamic page size for card view
  if (render) {
    roster.renderMembership({ replace: true });
  }
};

roster.clickViewSpreadsheetRadio = function() {

  // Hide and unapply 'hide names' setting
  $('#roster_hide_options').show();
  if ($('#roster-hide-names-checkbox').is(':checked')) {
    $('#roster-hide-names-checkbox').trigger('click');
  }
  $('label[for=roster-hide-names-checkbox], #roster-hide-names-checkbox').hide();

  // Show 'hide photos' setting
  $('label[for=roster-hide-pictures-checkbox], #roster-hide-pictures-checkbox').show();

  $('#roster_content').removeClass('view_mode_cards view_mode_photogrid');
  $('#roster_content').addClass('view_mode_spreadsheet');

  //document.querySelector(".roster-print-button").style.display = "none";

  roster.currentLayout = "spreadsheet";
  roster.renderMembership({ replace: true });
};

roster.clickViewPhotogridRadio = function() {

  // Hide and unapply 'hide photos' setting
  $('#roster_hide_options').show();
  if ($('#roster-hide-pictures-checkbox').is(':checked')) {
    $('#roster-hide-pictures-checkbox').trigger('click');
  }
  $('label[for=roster-hide-pictures-checkbox], #roster-hide-pictures-checkbox').hide();

  // Show 'hide names' setting
  $('label[for=roster-hide-names-checkbox], #roster-hide-names-checkbox').show();

  $('#roster_content').removeClass('view_mode_cards view_mode_spreadsheet');
  $('#roster_content').addClass('view_mode_photogrid');

  //document.querySelector(".roster-print-button").style.display = "initial";

  roster.currentLayout = "photogrid";

  // Re-render table with dynamic page size for grid view
  roster.renderMembership({ replace: true });
};

roster.calculatePageSizes = function () {

  // width of card = width + left and right margin
  // height of card = height + top and bottom margin
  var bigCardWidth = 345; // 340px width + 5px margin-right
  var bigCardHeight = 133; // 128px width + 5px margin-bottom
  var smallCardWidth = 160; // 155px width + 5px margin-right
  var smallCardHeight = 177; // 172px width + 5px margin-bottom

  // width of container = width + left and right padding
  var containerWidth = parseInt($('#roster-members-content').width());

  if (containerWidth < bigCardWidth) {
    containerWidth = bigCardWidth;
  }

  // number of cards per row = containerWidth / cardWith, rounded down to nearest whole number
  var numBigCardsPerRow = Math.floor(containerWidth / bigCardWidth);
  var numSmallCardsPerRow = Math.floor(containerWidth / smallCardWidth);

  // height of container = height + top and bottom padding;
  // #roster-members-content has no height at load, so we approximate using the morpheus page container
  const containerHeight = parseInt($('div.portal-main-container').height());

  // number of rows per page = containerHeight / cardHeight, rounded down up nearest whole number
  var numBigRowsPerPage = Math.ceil(containerHeight / bigCardHeight);
  var numSmallRowsPerPage = Math.ceil(containerHeight / smallCardHeight);

  roster.cardsPageSize = numBigRowsPerPage * numBigCardsPerRow;
  roster.gridPageSize = numSmallRowsPerPage * numSmallCardsPerRow;
};

// Functions and attributes added. All the code from hereon is executed
// after load.

if (!roster.siteId) {
  alert('The site id  MUST be supplied as a bootstrap parameter.');
}

if (!roster.userId) {
  alert("No current user. Have you logged in?");
}

Handlebars.registerHelper('translate', function (key) {
  return roster.i18n[key];
});

Handlebars.registerHelper('getName', function (firstNameLastName) {
  return (firstNameLastName) ? this.displayName : this.sortName;
});

Handlebars.registerHelper('ifCond', function(v1, v2, options) {
  if(v1 === v2) {
    return options.fn(this);
  }
  return options.inverse(this);
});

roster.init = function () {

  roster.currentLayout = roster.defaultOverviewMode;

  roster.i18n.months = roster.i18n.months.split(',');

  roster.ADMIN = 'admin';

  roster.STATE_OVERVIEW = 'overview';
  roster.STATE_ENROLLMENT_STATUS = 'status';
  roster.STATE_PERMISSIONS = 'permissions';

  roster.DEFAULT_GROUP_ID = 'all';
  roster.DEFAULT_ENROLLMENT_STATUS = 'All';
  roster.DEFAULT_STATE = roster.STATE_OVERVIEW;

  /* Stuff that we always expect to be setup */
  roster.language = null;

  // so we can return to the previous state after viewing permissions
  roster.rosterLastStateNotPermissions = null;

  // These are default behaviours, and are global so the tool remembers
  // the user's choices.
  roster.hideNames = false;
  roster.viewSingleColumn = false;
  roster.groupToView = null;
  roster.groupToViewText = roster.i18n.roster_sections_all;
  roster.enrollmentSetToView = null;
  roster.enrollmentSetToViewText = null;
  roster.enrollmentStatusToViewText = roster.i18n.roster_enrollment_status_all;
  roster.nextPage = 0;
  roster.currentState = null;

  this.searchIndexPromise = new Promise((resolve, reject) => {

    $.ajax({
      url: '/direct/roster-membership/' + roster.siteId + '/get-search-index.json',
      dataType: "json",
      success: function (data) {

        roster.searchIndex = data.data;
        roster.searchIndexKeys = Object.keys(data.data);
        roster.searchIndexValues = roster.searchIndexKeys.map(function (k) { return data.data[k] });
        resolve();
      },
      error: () => reject()
    });
  });

  roster.switchState(roster.state, roster);
};

roster.initNavBar = function() {

  // We need the toolbar in a template so we can swap in the translations
  roster.render('navbar', {}, 'roster_navbar');

  $('#navbar_overview_link > span > a').click(function (e) {
    return roster.switchState(roster.STATE_OVERVIEW);
  });

  $('#navbar_enrollment_status_link > span > a').on('click', function (e) {
    return roster.switchState(roster.STATE_ENROLLMENT_STATUS);
  });

  $('#navbar_permissions_link > span > a').click(function (e) {
    return roster.switchState(roster.STATE_PERMISSIONS);
  });
};

roster.loadSiteDataAndInit = function () {

  $.ajax({
    url: "/direct/roster-membership/" + roster.siteId + "/get-site.json",
    dataType: "json",
    cache: false,
    success: function (data) {

      roster.site = data || {};
      if (!roster.site.siteGroups) roster.site.siteGroups = [];
      if (!roster.site.userRoles) roster.site.userRoles = [];
      if (!roster.site.siteEnrollmentSets) roster.site.siteEnrollmentSets = [];

      // Setup the current user's permissions
      if (roster.userId === roster.ADMIN) {
        // Admin user. Give the full set.
        var data = ['roster.export',
              'roster.viewallmembers',
              'roster.viewenrollmentstatus',
              'roster.viewgroup',
              'roster.viewhidden',
              'roster.viewprofile',
              'site.upd'];

        roster.currentUserPermissions = new roster.RosterPermissions(data);
        roster.init();
      } else {
        $.ajax({
          url: "/direct/site/" + roster.siteId + "/userPerms.json",
          dataType: "json",
          cache: false,
          success: function (perms, status) {

            roster.currentUserPermissions = new roster.RosterPermissions(perms.data);
            if (!roster.currentUserPermissions.viewOfficialPhoto) {
              // The official photo permission should always override the
              // roster.display.officialPicturesByDefault property
              roster.officialPictureMode = false;
            }
            roster.init();
          },
          error : function(xmlHttpRequest, stat, error) {
            alert("Failed to get the current user permissions. Status: " + stat + ". Error: " + error);
          }
        });
      }
    }
  });
};

roster.RosterPermissions = function (permissions) {

  var self = this;

  permissions.forEach(function (p) {

    // roster permissions
    if ('roster.export' === p) {
      self.rosterExport = true;
    } else if ('roster.viewallmembers' === p) {
      self.viewAllMembers = true;
    } else if ('roster.viewenrollmentstatus' === p) {
      self.viewEnrollmentStatus = true;
    } else if ('roster.viewgroup' === p) {
      self.viewGroup = true;
    } else if ('roster.viewhidden' === p) {
      self.viewHidden = true;
    } else if ('roster.viewprofile' === p) {
      self.viewProfile = true;
    } else if ('roster.viewofficialphoto' === p) {
      self.viewOfficialPhoto = true;
    } else if ('roster.viewsitevisits' === p) {
      self.viewSiteVisits = true;
    } else if ('roster.viewemail' === p) {
      self.viewEmail = true;
    } else if ('site.upd' === p) { // sakai permissions
      self.siteUpdate = true;
    }
  });
};

var loadRoster = function () {

  loadProperties({bundle: "roster"}).then(i18n => {

    roster.i18n = i18n;
    roster.helpers["tr"] =  (key, ...insertions) => {
      let translation = roster.i18n[key];
      insertions?.forEach((insertion, index) => translation = translation?.replace(`{${index}}`, insertion));
      return translation;
    };

    const callback = entries => {

      if (entries.filter(entry => entry.isIntersecting).length > 0) {
        roster.renderMembership({});
      }
    };

    roster.observer = new IntersectionObserver(callback);

    roster.loadSiteDataAndInit();
  });
};

export {loadRoster};
// # vim: softtabstop=2 sw=2 expandtab
