<%@ page import="java.util.*, javax.faces.context.*, javax.faces.application.*,
                 javax.faces.el.*, org.sakaiproject.tool.messageforums.*"%>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t"%>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<%@ taglib uri="http://sakaiproject.org/jsf/messageforums" prefix="mf" %>
<jsp:useBean id="msgs" class="org.sakaiproject.util.ResourceLoader" scope="session">
   <jsp:setProperty name="msgs" property="baseName" value="org.sakaiproject.api.app.messagecenter.bundle.Messages"/>
</jsp:useBean>
<f:view>
<sakai:view title="#{msgs.cdfm_discussion_topic_settings}" toolCssHref="/messageforums-tool/css/msgcntr.css">
	<script>includeLatestJQuery("msgcntr");</script>
	<script>includeWebjarLibrary("momentjs");</script>
	<script src="/messageforums-tool/js/sak-10625.js"></script>
	<script src="/messageforums-tool/js/jquery.charcounter.js"> </script>
	<script src="/messageforums-tool/js/permissions_header.js"></script>
	<script src="/messageforums-tool/js/forum.js"></script>
	<script src="/messageforums-tool/js/messages.js"></script>
	<script src="/messageforums-tool/js/datetimepicker.js"></script>
	<script src="/library/js/lang-datepicker/lang-datepicker.js"></script>
	<script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{ForumTool.CDNQuery}" />"></script>
	
	<%
	  	String thisId = request.getParameter("panel");
		if (thisId == null) {
    		thisId = "Main" + org.sakaiproject.tool.cover.ToolManager.getCurrentPlacement().getId();
  		}
	%>
	<script>
		function resize() {
  			mySetMainFrameHeight('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
  		}
	</script>
	<script type="text/javascript">
		function setDatesEnabled(radioButton){
			$(".calWidget, .lockForumAfterCloseDateSpan").fadeToggle('slow');
		}

		window.onload = function(){
			const sendCheckbox = document.getElementById("revise:sendOpenCloseDateToCalendar");
			sendCheckbox?.disabled && (sendCheckbox.checked = false);	//make sure that Calendar sending is not checked when it's disabled/when the site has no calendar
		};

		function openDateCal() {
			NewCal('revise:openDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
		}

		function closeDateCal() {
			NewCal('revise:closeDate','MMDDYYYY',true,12, '<h:outputText value="#{ForumTool.defaultAvailabilityTime}"/>');
		}

		function updateGradeAssignment() {
			const topicAssignments = document.getElementById("revise:topic_assignments");

			if (topicAssignments?.value === undefined || topicAssignments.value === "Default_0") return;

			const associations = document.querySelectorAll('sakai-rubric-association');
			const createTaskGroup = document.getElementById("revise:createTaskGroup");
			const createTaskEmptyPanel = document.getElementById("revise:createTaskEmptyPanel");
			if (!!document.querySelector("sakai-tasks")) {
				associations.forEach(a => {
					a.setAttribute("entity-id", topicAssignments.value);
					a.style.display = 'inline';
				});
				createTaskGroup && (createTaskGroup.style.display = 'inline');
				createTaskEmptyPanel && (createTaskEmptyPanel.style.display = 'inline');
			} else {
				associations.forEach(a => a.style.display = 'none');
				createTaskGroup && (createTaskGroup.style.display = 'none');
				createTaskEmptyPanel && (createTaskEmptyPanel.style.display = 'none');
			}
		}

		function setAutoCreatePanel(radioButton) {

			$(".createOneTopicPanel").slideToggle("fast");
			$(".createTopicsForGroupsPanel").slideToggle("fast");
		}

		function togglePostAnonymousOption(checked) {

			var revealIDsToRoles = $("#revise\\:revealIDsToRolesContainer");
			if (checked) {
				revealIDsToRoles.css("display", "");
			} else {
				revealIDsToRoles.css("display", "none");
			}
		}

		function toggleIncludeContentsInEmailsOption(checked) {

			var includeContentsInEmails = $("#revise\\:includeContentsInEmailsContainer");
			if (checked) {
				includeContentsInEmails.css("display", "");
			} else {
				includeContentsInEmails.css("display", "none");
			}
		}
	</script>
	<!-- RUBRICS VARIABLES -->
	<%
		FacesContext fcontext = FacesContext.getCurrentInstance();
		Application appl = fcontext.getApplication();
		ValueBinding vbinding = appl.createValueBinding("#{ForumTool}");
		DiscussionForumTool forumTool = (DiscussionForumTool) vbinding.getValue(fcontext);
		String entityId = "top." + forumTool.getSelectedTopic().getTopic().getId();
	%>
	<!-- END RUBRICS VARIABLES -->

	<!--jsp/dfReviseTopicSettingsAttach.jsp-->
	<h:form id="revise">
		<%@ include file="/jsp/discussionForum/menu/forumsMenu.jsp" %>
		<sakai:tool_bar_message value="#{msgs.cdfm_discussion_topic_settings}" />
		<h3 class="specialLink">
			<h:commandLink immediate="true" action="#{ForumTool.processActionHome}" value="#{msgs.cdfm_message_forums}" title=" #{msgs.cdfm_message_forums}"
				rendered="#{ForumTool.messagesandForums}" />
			<h:commandLink immediate="true" action="#{ForumTool.processActionHome}" value="#{msgs.cdfm_discussions}" title=" #{msgs.cdfm_discussions}"
				rendered="#{ForumTool.forumsTool}" />
			<h:outputText value=" " /><h:outputText value=" / " /><h:outputText value=" " />
			<h:commandLink immediate="true" action="#{ForumTool.processActionDisplayForum}" title=" #{ForumTool.selectedForum.forum.title}" rendered="#{ForumTool.showForumLinksInNav}">
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
				<h:outputText value="#{ForumTool.selectedForum.forum.title}"/>
			</h:commandLink>
			<h:outputText value="#{ForumTool.selectedForum.forum.title}" rendered="#{!ForumTool.showForumLinksInNav}"/>
			<h:outputText value=" " /><h:outputText value=" / " /><h:outputText value=" " />
			<h:outputText value="#{ForumTool.selectedTopic.topic.title}" />
		</h3>

		<div class="instruction">
			<h:outputText id="instruction"  value="#{msgs.cdfm_settings_instruction}"/>
			<h:outputText value="#{msgs.cdfm_info_required_sign}" styleClass="reqStarInline" />
		</div>
		<h:messages errorClass="sak-banner-error" infoClass="sak-banner-success" id="errorMessages" rendered="#{! empty facesContext.maximumSeverity}"/>

		<h:panelGrid styleClass="jsfFormTable" columns="1"  columnClasses="shorttext">
			<h:panelGroup>
				<h:outputLabel id="outputLabel" for="topic_title" styleClass="strong" style="padding-bottom:.3em;display:block;clear:both;float:none;">
					<h:outputText id="req_star"  value="#{msgs.cdfm_info_required_sign}" styleClass="reqStarInline" style="padding-right:3px"/>
					<h:outputText value="#{msgs.cdfm_topic_title}" />
				</h:outputLabel>	 
				<h:inputText size="50" id="topic_title"  maxlength="250" value="#{ForumTool.selectedTopic.topic.title}" validatorMessage="#{msgs.topics_revise_title_validation}">
					<f:validateLength minimum="1" maximum="255"/>
				</h:inputText>
			</h:panelGroup>	
		</h:panelGrid>
		<%-- //designNote: rendered attr below should resolve to false only if there is no prior short description
				and if there is server property (TBD) saying not to use it  - below just checking for pre-existing short description--%>
		<h:panelGrid columns="1"  columnClasses="longtext" rendered="#{ForumTool.showTopicShortDescription}">
			<h:panelGroup>
				<h:outputLabel id="outputLabel1" for="topic_shortDescription"  value="#{msgs.cdfm_shortDescription}" styleClass="strong"/>
				<h:outputText value="#{msgs.cdfm_shortDescriptionCharsRem}"  styleClass="charRemFormat" style="display:none"/>
				<%--
				<h:outputText value="%1 chars remain"  styleClass="charRemFormat" style="display:none"/>
				--%>
				<h:outputText value="" styleClass="charsRemaining" style="padding-left:3em;font-size:.85em;" />
				<h:outputText value=""  style="display:block"/>
				<h:inputTextarea rows="3" cols="45" id="topic_shortDescription"  value="#{ForumTool.selectedTopic.topic.shortDescription}" styleClass="forum_shortDescriptionClass" style="float:none"/>
			</h:panelGroup>
		</h:panelGrid>
		<%--RTEditor area - if enabled--%>
		<h:panelGroup rendered="#{! ForumTool.disableLongDesc}">
			<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="forums_dfReviseTopicSettingsAttach" /></f:verbatim>
			<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{ForumTool.selectedTopic.topic.id}"/><f:verbatim>"/></f:verbatim></h:panelGroup>

			<h:outputText id="outputLabel2"   value="#{msgs.cdfm_fullDescription}" styleClass="labeled"/>
			<sakai:inputRichText textareaOnly="#{PrivateMessagesTool.mobileSession}"
				rows="#{ForumTool.editorRows}"
				cols="132"
				id="topic_description"
				value="#{ForumTool.selectedTopic.topic.extendedDescription}">
			</sakai:inputRichText>
		</h:panelGroup>

		<%--Attachment area  --%>
		<h2><h:outputText value="#{msgs.cdfm_att}"/></h2>

		<div style="padding-left:1em">
			<%--designNote: would be nice to make this an include, as well as a more comprehensive MIME type check  --%>
			<h:dataTable styleClass="attachPanel" id="attmsg" value="#{ForumTool.attachments}" var="eachAttach"  cellpadding="0" cellspacing="0" columnClasses="attach,bogus,specialLink,bogus,bogus" rendered="#{!empty ForumTool.attachments}">
				<h:column>
					<f:facet name="header"><h:outputText escape="false"  value="&nbsp;" /></f:facet>
					<sakai:contentTypeMap fileType="#{eachAttach.attachment.attachmentType}" mapType="image" var="imagePath" pathPrefix="/library/image/"/>
					<h:graphicImage id="exampleFileIcon" value="#{imagePath}" />
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText value="#{msgs.cdfm_title}" /></f:facet>
					<h:outputText value="#{eachAttach.attachment.attachmentName}"/>
				</h:column>
				<h:column>
					<f:facet name="header"><h:outputText escape="false" value="&nbsp;"/></f:facet>
					<h:commandLink action="#{ForumTool.processDeleteAttachSetting}"
						immediate="true"
						title="#{msgs.cdfm_remove}">
						<h:outputText value="#{msgs.cdfm_remove}"/>
						<f:param value="#{eachAttach.attachment.attachmentId}" name="dfmsg_current_attach"/>
					</h:commandLink>
				</h:column>
				<h:column rendered="#{!empty ForumTool.attachments}">
					<f:facet name="header"><h:outputText value="#{msgs.cdfm_attsize}" /></f:facet>
					<h:outputText value="#{ForumTool.getAttachmentReadableSize(eachAttach.attachment.attachmentSize)}"/>
				</h:column>
				<h:column rendered="#{!empty ForumTool.attachments}">
					<f:facet name="header"><h:outputText value="#{msgs.cdfm_atttype}" /></f:facet>
					<h:outputText value="#{eachAttach.attachment.attachmentType}"/>
				</h:column>
			</h:dataTable>
			
			<h:panelGroup styleClass="instruction" rendered="#{empty ForumTool.attachments}">
				<h:outputText value="#{msgs.cdfm_no_attachments}" />
			</h:panelGroup>

			<p class="act" style="padding:0 0 1em 0;">
				<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}" 
					value="#{msgs.cdfm_button_bar_add_attachment_more_redirect}" 
					accesskey="a" 
			        rendered="#{!empty ForumTool.attachments}"
					style="font-size:95%"/>
				<h:commandButton action="#{ForumTool.processAddAttachmentRedirect}" 
					value="#{msgs.cdfm_button_bar_add_attachment_redirect}" 
					accesskey="a" 
					rendered="#{empty ForumTool.attachments}"
					style="font-size:95%"/>
			</p>
		</div>

		<%--general posting  topic settings --%>
		<h2 id="topic_posting_head"><h:outputText  value="#{msgs.cdfm_topic_posting}"/></h2>
		<p class="checkbox">
			<h:selectBooleanCheckbox
				title="topicLocked" value="#{ForumTool.selectedTopic.topicLocked}"
				id="topic_locked">
			</h:selectBooleanCheckbox> <h:outputLabel for="topic_locked" id="topic_locked_label" value="#{msgs.cdfm_lock_topic}" />
		</p>
		<p class="checkbox">
			<h:selectBooleanCheckbox
				title="Moderated" value="#{ForumTool.selectedTopic.topicModerated}"
				id="topic_moderated">
			</h:selectBooleanCheckbox> <h:outputLabel for="topic_moderated" id="topic_moderated_label" value="#{msgs.cdfm_moderate_topic}" />
		</p>
		<p class="checkbox">
			<h:selectBooleanCheckbox
				title="postFirst" value="#{ForumTool.selectedTopic.topicPostFirst}"
				id="topic_postFirst">
			</h:selectBooleanCheckbox> <h:outputLabel for="topic_postFirst" id="topic_postFirst_label" value="#{msgs.cdfm_postFirst}" />
		</p>
		<t:htmlTag value="p" styleClass="checkbox anonTopic" rendered="#{ForumTool.anonymousEnabled}">
			<h:selectBooleanCheckbox
				title="postAnonymous" value="#{ForumTool.selectedTopic.topicPostAnonymous}"
				id="topic_postAnonymous"
				onclick='togglePostAnonymousOption(this.checked);'
				disabled="#{!ForumTool.newTopicOrPostAnonymousRevisable}">
			</h:selectBooleanCheckbox>
			<h:outputLabel escape="false" for="topic_postAnonymous" value="#{msgs.cdfm_postAnonymous} &nbsp;" id="topic_postAnonymous_label">
				<h:outputText value="#{msgs.cdfm_noReviseAfter}" styleClass="sak-banner-warn-inline" rendered="#{!ForumTool.postAnonymousRevisable && !ForumTool.existingTopic}"/>
				<h:outputText value="#{msgs.cdfm_noRevise}" styleClass="sak-banner-warn-inline" rendered="#{!ForumTool.postAnonymousRevisable && ForumTool.existingTopic}"/>
			</h:outputLabel>
		</t:htmlTag>
		<t:htmlTag value="div" id="revealIDsToRolesContainer" style="display: #{ForumTool.selectedTopic.topicPostAnonymous ? '' : 'none'}" styleClass="indnt2 anonTopic" rendered="#{ForumTool.anonymousEnabled}">
			<p class="checkbox">
				<h:selectBooleanCheckbox
					title="revealIDsToRoles" value="#{ForumTool.selectedTopic.topicRevealIDsToRoles}"
					id="topic_revealIDsToRoles"
					disabled="#{!ForumTool.newTopicOrRevealIDsToRolesRevisable}">
				</h:selectBooleanCheckbox>
				<h:outputLabel escape="false" for="topic_revealIDsToRoles" value="#{msgs.cdfm_revealIDsToRoles} &nbsp;">
					<h:outputText value="#{msgs.cdfm_noReviseAfter}" styleClass="sak-banner-warn-inline" rendered="#{!ForumTool.revealIDsToRolesRevisable && !ForumTool.existingTopic}"/>
					<h:outputText value="#{msgs.cdfm_noRevise}" styleClass="sak-banner-warn-inline" rendered="#{!ForumTool.revealIDsToRolesRevisable && ForumTool.existingTopic}"/>
				</h:outputLabel>
			</p>
		</t:htmlTag>

		<h2><h:outputText  value="#{msgs.cdfm_forum_availability}" id="forumAvailabilityLabel3" /></h2>
		<div class="indnt1">
			<h:panelGroup styleClass="checkbox">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setDatesEnabled(this);" disabled="#{not ForumTool.editMode}" id="availabilityRestricted"  value="#{ForumTool.selectedTopic.availabilityRestricted}">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_forum_avail_show}"/>
					<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_forum_avail_date}"/>
				</h:selectOneRadio>
			</h:panelGroup>
			<h:panelGroup id="openDateSpan" styleClass="indnt2 openDateSpan calWidget" style="display: #{ForumTool.selectedTopic.availabilityRestricted ? 'block' : 'none'}">
				<h:outputLabel value="#{msgs.openDate}: " for="openDate"/>
				<h:inputText id="openDate" styleClass="openDate" value="#{ForumTool.selectedTopic.openDate}"/>
			</h:panelGroup>
			<h:panelGroup id="closeDateSpan" styleClass="indnt2 openDateSpan calWidget" style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
				<h:outputLabel value="#{msgs.closeDate}: " for="closeDate"/>
				<h:inputText id="closeDate" styleClass="closeDate" value="#{ForumTool.selectedTopic.closeDate}"/>
			</h:panelGroup>
			<h:panelGroup styleClass="checkbox" style="display: #{ForumTool.doesSiteHaveCalendar ? '' : 'none'}">
				<h:panelGroup id="sendOpenCloseDateToCalendarSpan"
							  styleClass="indnt2 lockForumAfterCloseDateSpan calWidget"
							  style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
					<h:selectBooleanCheckbox id="sendOpenCloseDateToCalendar" styleClass="ms-0 me-3"
											 disabled="#{not ForumTool.doesSiteHaveCalendar}"
											 value="#{ForumTool.selectedTopic.topic.sendOpenCloseToCalendar}"/>
					<h:outputLabel for="sendOpenCloseDateToCalendar" styleClass="p-0" value="#{msgs.sendOpenCloseToCalendar}" />
				</h:panelGroup>
			</h:panelGroup>
			<h:panelGroup id="lockForumAfterCloseDateSpan" styleClass="indnt2 lockForumAfterCloseDateSpan" style="display: #{ForumTool.selectedTopic.availabilityRestricted ? '' : 'none'}">
				<h:selectBooleanCheckbox id="lockForumAfterCloseDate" styleClass="ms-0 me-3" value="#{ForumTool.selectedTopic.topic.lockedAfterClosed}"/>
				<h:outputLabel for="lockForumAfterCloseDate" styleClass="p-0" value="#{msgs.lockForumAfterCloseDate}" />
			</h:panelGroup>
		</div>

		<script>
			localDatePicker({
				input:'[id="revise:openDate"]',
				allowEmptyDate: true,
				ashidden: { iso8601: 'openDateISO8601' },
				getval:'[id="revise:openDate"]',
				useTime:1
			});

			localDatePicker({
				input:'[id="revise:closeDate"]',
				allowEmptyDate: true,
				ashidden: { iso8601: 'closeDateISO8601' },
				getval: '[id="revise:closeDate"]',
				useTime:1
			});
		</script>

		<h2><h:outputText value="#{msgs.cdfm_forum_notifications}"/></h2>
		<p class="checkbox">
			<h:selectBooleanCheckbox
				title="allowEmailNotifications" value="#{ForumTool.selectedTopic.topicAllowEmailNotifications}"
				id="topic_allow_email_notifications"
				onclick='toggleIncludeContentsInEmailsOption(this.checked);resizeFrame();'>
			</h:selectBooleanCheckbox>
			<h:outputLabel for="topic_allow_email_notifications" value="#{msgs.cdfm_allowEmailNotifications}" />
		</p>
		<h:panelGroup layout="block" id="includeContentsInEmailsContainer" style="display: #{ForumTool.selectedTopic.topicAllowEmailNotifications ? '' : 'none'}" styleClass="indnt2">
			<p class="checkbox">
				<h:selectBooleanCheckbox
					title="includeContentsInEmails" value="#{ForumTool.selectedTopic.topicIncludeContentsInEmails}"
					id="topic_includeContentsInEmails">
				</h:selectBooleanCheckbox>
				<h:outputLabel for="topic_includeContentsInEmails" value="#{msgs.cdfm_includeContentsInEmails}" />
			</p>
		</h:panelGroup>

		<h2><h:outputText value="#{msgs.cdfm_forum_mark_read}"/></h2>
		<p class="checkbox">
			<h:selectBooleanCheckbox
				title="autoMarkThreadsRead"
				value="#{ForumTool.selectedTopic.topicAutoMarkThreadsRead}"
				id="autoMarkThreadsRead">
			</h:selectBooleanCheckbox>
			<h:outputLabel for="autoMarkThreadsRead" value="#{msgs.cdfm_auto_mark_threads_read}" />
		</p>

		<h2><h:outputText value="#{msgs.perm_choose_assignment_head}" /></h2>
		<h:panelGrid columns="2" rendered="#{ForumTool.gradebookExist && !ForumTool.selectedForum.markForDeletion}" style="margin-top:.5em;clear:both"  styleClass="itemSummary">
			<h:panelGroup  style="white-space:nowrap;">
				<h:outputLabel for="topic_assignments" value="#{msgs.perm_choose_assignment}"></h:outputLabel>
			</h:panelGroup>
			<h:panelGroup styleClass="gradeSelector itemAction actionItem">
				<h:selectOneMenu value="#{ForumTool.selectedTopic.gradeAssign}" onchange="updateGradeAssignment()" id="topic_assignments" disabled="#{not ForumTool.editMode}">
					<f:selectItems value="#{ForumTool.assignments}" />
				</h:selectOneMenu>
				<h:outputText value="#{msgs.perm_choose_assignment_none_t}" styleClass="instrWOGrades" style="display:none;margin-left:0"/>
				<h:outputText value=" #{msgs.perm_choose_instruction_topic} " styleClass="instrWithGrades" style="margin-left:0;"/>
				<h:outputLink value="#" style="text-decoration:none"  styleClass="instrWithGrades">
					<h:outputText styleClass="displayMore" value="#{msgs.perm_choose_instruction_more_link}" />
				</h:outputLink>
			</h:panelGroup>
			<h:panelGroup styleClass="displayMorePanel" style="display:none"></h:panelGroup>
			<h:panelGroup styleClass="itemAction actionItem displayMorePanel" style="display:none">
				<h:outputText styleClass="displayMorePanel" value="#{msgs.perm_choose_instruction_topic_more}"/>
			</h:panelGroup>
			<h:panelGroup id="createTaskEmptyPanel" style="display:#{((ForumTool.selectedTopic.gradeAssign != null && ForumTool.selectedTopic.gradeAssign != 'Default_0') ? 'block' : 'none')}"></h:panelGroup>
			<h:panelGroup id="createTaskGroup" style="display:#{((ForumTool.selectedTopic.gradeAssign != null && ForumTool.selectedTopic.gradeAssign != 'Default_0') ? 'block' : 'none')}">
				<h:selectBooleanCheckbox id="createTask" title="createTask" value="#{ForumTool.selectedTopic.createTask}"/>
				<h:outputLabel for="createTask" value="#{msgs.perm_create_task_topic}" style="margin-left:5px"/>
			</h:panelGroup>
		</h:panelGrid>
		<sakai-rubric-association style="margin-left:20px;display:none"
            site-id='<h:outputText value="#{ForumTool.siteId}" />'
			dont-associate-label='<h:outputText value="#{msgs.topic_dont_associate_label}" />'
			dont-associate-value="0"
			associate-label='<h:outputText value="#{msgs.topic_associate_label}" />'
			associate-value="1"
			read-only="true"
			tool-id="sakai.gradebookng"
			fine-tune-points='<h:outputText value="#{msgs.option_pointsoverride}" />'
			hide-student-preview='<h:outputText value="#{msgs.option_studentpreview}" />'

		></sakai-rubric-association>

		<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups}">
			<f:verbatim><h2></f:verbatim><h:outputText  value="#{msgs.cdfm_autocreate_topics_header}" /><f:verbatim></h2></f:verbatim>
		</h:panelGroup>
		<h:panelGrid columns="1" columnClasses="longtext,checkbox" cellpadding="0" cellspacing="0" >
			<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && !ForumTool.selectedForum.restrictPermissionsForGroups}">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setAutoCreatePanel(this);" disabled="#{not ForumTool.editMode}" id="createTopicsForGroups" value="#{ForumTool.selectedTopic.restrictPermissionsForGroups}">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_create_one_topic}"/>
					<f:selectItem itemValue="true" itemLabel="#{msgs.cdfm_autocreate_topics_for_groups}"/>
				</h:selectOneRadio>
			</h:panelGroup>
			<h:panelGroup style="display:none" rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && ForumTool.selectedForum.restrictPermissionsForGroups}">
				<h:selectOneRadio layout="pageDirection" onclick="this.blur()" onchange="setAutoCreatePanel(this);" disabled="#{not ForumTool.editMode}" id="createTopicsForGroups2" value="#{ForumTool.selectedTopic.restrictPermissionsForGroups}">
					<f:selectItem itemValue="false" itemLabel="#{msgs.cdfm_create_one_topic}"/>
				</h:selectOneRadio>
			</h:panelGroup>
		</h:panelGrid>
		<div id="createOneTopicPanel" class="createOneTopicPanel">
			<%@ include file="/jsp/discussionForum/permissions/permissions_include.jsp"%>
		</div>

		<div id="createTopicsForGroupsPanel" class="createTopicsForGroupsPanel" style="display:none" >
			<h:panelGroup rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && !ForumTool.selectedForum.restrictPermissionsForGroups}">
				<h:outputText value="#{msgs.cdfm_autocreate_topics_desc}" rendered="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups}" />
				<h:panelGroup styleClass="itemAction">
					<h:outputLink value="#" style="text-decoration:none"  styleClass="instrWithGrades">
						<h:outputText styleClass="displayMoreAutoCreate" value="#{msgs.perm_choose_instruction_more_link}"/>
					</h:outputLink>
				</h:panelGroup>
				<f:verbatim><br/></f:verbatim>
				<h:panelGroup styleClass="displayMoreAutoCreatePanel instruction" style="display:none">
					<h:outputText value="#{msgs.cdfm_autocreate_topics_desc_more}" />
					<h:outputText value="#{ForumTool.autoRolesNoneDesc}" />
					<h:outputText value="#{ForumTool.autoGroupsDesc}" />
				</h:panelGroup>
				<h:dataTable value="#{ForumTool.siteGroups}" var="siteGroup" cellpadding="0" cellspacing="0" styleClass="indnt1 jsfFormTable"
							 rendered="#{ForumTool.selectedTopic.topic.id==null}">
					<h:column>
						<h:selectBooleanCheckbox value="#{siteGroup.createTopicForGroup}" id="topic_siteGroupCheck" />
                        <h:outputText value="#{siteGroup.group.title}" id="topic_siteGroupCheck_label" />
					</h:column>
				</h:dataTable>
			</h:panelGroup>
		</div>

		<script>
			setPanelId('<%= org.sakaiproject.util.Web.escapeJavascript(thisId)%>');
			$(function () {
				if (<h:outputText value="#{ForumTool.selectedTopic.topic.id==null && !empty ForumTool.siteGroups && ForumTool.selectedTopic.restrictPermissionsForGroups}" />) {
					$("#createOneTopicPanel").hide();
					$("#createTopicsForGroupsPanel").show();
				}
			});
		</script>
		<div class="act">
			<h:commandButton action="#{ForumTool.processActionSaveTopicSettings}" value="#{msgs.cdfm_button_bar_save_setting}" accesskey="s"
									 rendered="#{!ForumTool.selectedTopic.markForDeletion}" styleClass="blockMeOnClick active">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionSaveTopicAsDraft}" value="#{msgs.cdfm_button_bar_save_draft}" accesskey="v"
									 rendered="#{!ForumTool.selectedTopic.markForDeletion}" styleClass="blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionSaveTopicAndAddTopic}" value="#{msgs.cdfm_button_bar_save_setting_add_topic}" accesskey="t"
									 rendered="#{!ForumTool.selectedTopic.markForDeletion}"  styleClass="blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId"/>
				<f:param value="#{ForumTool.selectedForum.forum.id}" name="forumId"/>
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionDeleteTopicConfirm}" id="delete_confirm"
					   value="#{msgs.cdfm_button_bar_delete_topic}" accesskey="d" rendered="#{!ForumTool.selectedTopic.markForDeletion && ForumTool.displayTopicDeleteOption}" styleClass="blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
			</h:commandButton>
			<h:commandButton action="#{ForumTool.processActionDeleteTopic}" id="delete" accesskey="d"
					   value="#{msgs.cdfm_button_bar_delete_topic}" rendered="#{ForumTool.selectedTopic.markForDeletion}" styleClass="blockMeOnClick">
				<f:param value="#{ForumTool.selectedTopic.topic.id}" name="topicId" />
			</h:commandButton>
			<h:commandButton immediate="true" action="#{ForumTool.processActionHome}" value="#{msgs.cdfm_button_bar_cancel}" accesskey="x" />
			<h:outputText styleClass="sak-banner-info" style="display:none" value="#{msgs.cdfm_processing_submit_message}" />
		</div>
	</h:form>
	<script>
		$(document).ready(function () {
			$('.displayMore').click(function(e) {

				e.preventDefault();
				$('.displayMorePanel').fadeIn('slow')
			});
			$('.displayMoreAutoCreate').click(function(e) {

					e.preventDefault();
					$('.displayMoreAutoCreatePanel').fadeIn('slow')
			});
			if ($('.gradeSelector').find('option').length ===1){
				$('.gradeSelector').find('select').hide();
				$('.gradeSelector').find('.instrWithGrades').hide();
				$('.gradeSelector').find('.instrWOGrades').show();
			}
			updateGradeAssignment();
			var charRemFormat = $('.charRemFormat').text();
			$(".forum_shortDescriptionClass").charCounter(255, {
				container: ".charsRemaining",
				format: charRemFormat
			});

			var menuLink = $('#forumsMainMenuLink');
			var menuLinkSpan = menuLink.closest('span');
			menuLinkSpan.addClass('current');
			menuLinkSpan.html(menuLink.text());
			$('#revise\\:topic_locked, #revise\\:topic_moderated, #revise\\:topic_postFirst').each(function() {
                $(this).attr('aria-labelledby', 'topic_posting_head ' + $(this).attr('id') + '_label');
            });
            if($('#revise\\:topic_postAnonymous').length){
                $('#revise\\:topic_postAnonymous').attr('aria-labelledby', 'topic_posting_head revise:topic_postAnonymous_label');
            }
            $('#revise\\:availabilityRestricted\\:0, #revise\\:availabilityRestricted\\:1').each(function() {
               let label = $('#revise\\:forumAvailabilityLabel3').text() + " " + $(this).next().text();
               $(this).attr('aria-label', label);
            });
            $('input[id*="topic_siteGroupCheck"]').each(function() {
                 $(this).attr('aria-labelledby', 'revise:createTopicsForGroups:1 ' + $(this).attr('id') + '_label');
            });

		 });
	</script>
</sakai:view>
</f:view>
