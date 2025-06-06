<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://myfaces.apache.org/tomahawk" prefix="t" %>
<%@ taglib uri="http://www.sakaiproject.org/samigo" prefix="samigo" %>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--
/**********************************************************************************
 * $URL$
 * $Id$
 ***********************************************************************************
 *
 * Copyright (c) 2005, 2006, 2007, 2008 Sakai Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.osedu.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/
-->
  <f:view>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head><%= request.getAttribute("html.head") %>
      <title><h:outputText value="#{assessmentSettingsMessages.check_settings_and_add_notification}" /></title>
      <script src="/library/js/spinner.js"></script>
      </head>
      <body onload="<%= request.getAttribute("html.body.onload") %>">

<div class="portletBody">
 <!-- content... -->
 <h:form id="publishAssessmentForm">
   <h:inputHidden id="assessmentId" value="#{assessmentSettings.assessmentId}"/>
   <h3>
      <h:outputText value="#{assessmentSettingsMessages.publish_assessment}" escape="false" rendered="#{author.isEditPendingAssessmentFlow}"/>
      <h:outputText value="#{assessmentSettingsMessages.republish_assessment}" escape="false" rendered="#{!author.isEditPendingAssessmentFlow && !author.isRepublishAndRegrade}"/>
      <h:outputText value="#{assessmentSettingsMessages.regrade_republish_assessment}" escape="false" rendered="#{!author.isEditPendingAssessmentFlow && author.isRepublishAndRegrade}"/>
   </h3>
<div class="tier1">

  <!-- Error publishing assessment -->
  <h:messages globalOnly="true"  styleClass="sak-banner-error" rendered="#{! empty facesContext.maximumSeverity}" layout="table"/>
  
  <!-- NOTIFICATION -->
  <h:panelGroup>
    <div class="row">
      <h:outputLabel styleClass="col-md-2" value="#{assessmentSettingsMessages.notification}" for="number" />
      <div class="col-md-10">
        <h:panelGrid>
          <h:selectOneMenu id="number" value="1" onchange="document.getElementById('publishAssessmentForm').submit();">
            <f:selectItems value="#{publishRepublishNotification.notificationLevelChoices}" />
            <f:valueChangeListener type="org.sakaiproject.tool.assessment.ui.listener.author.PublishRepublishNotificationListener" />
          </h:selectOneMenu>
	      <h:panelGroup rendered="#{author.isEditPendingAssessmentFlow && not empty assessmentSettings.dueDate && calendarServiceHelper.calendarExistsForSite}">
		    <h:selectBooleanCheckbox id="calendarDueDate" value="true"/>
		    <h:outputText value="#{assessmentSettingsMessages.calendarDueDate} #{calendarServiceHelper.calendarTitle}" escape="false"/>
	      </h:panelGroup>
	      <h:panelGroup rendered="#{!author.isEditPendingAssessmentFlow && not empty publishedSettings.dueDate && calendarServiceHelper.calendarExistsForSite}">
		    <h:selectBooleanCheckbox id="calendarDueDate2" value="true"/>
		    <h:outputText value="#{assessmentSettingsMessages.calendarDueDate} #{calendarServiceHelper.calendarTitle}" escape="false"/>
	      </h:panelGroup>
        </h:panelGrid>
      </div>
    </div>
  </h:panelGroup>
  
  
  
<h:panelGrid border="0" width="100%">
  <h:outputText value=" " />
  <h:panelGroup rendered="#{author.isEditPendingAssessmentFlow}">
    <h:panelGrid  columns="1">
	   <h:outputText value="#{assessmentSettingsMessages.publish_confirm_message}" escape="false" />
    </h:panelGrid>
  </h:panelGroup>

  <h:panelGroup rendered="#{!author.isEditPendingAssessmentFlow && !author.isRepublishAndRegrade}">
	<h:panelGrid  columns="1">
   	   <h:outputText value="#{assessmentSettingsMessages.republish_confirm_message}" escape="false"/>
		<h:outputFormat value="#{assessmentSettingsMessages.cancel_message}" escape="false">		
		<f:param value="#{commonMessages.cancel_action}"/>
		</h:outputFormat>	
	</h:panelGrid>
  </h:panelGroup>

  <h:outputText value="#{assessmentSettingsMessages.started_or_submitted}" rendered="#{!author.isEditPendingAssessmentFlow && author.isRepublishAndRegrade}" styleClass="sak-banner-warn"/>

<h:panelGrid rendered="#{!author.isEditPendingAssessmentFlow && author.isRepublishAndRegrade}">
    <h:outputText value="#{assessmentSettingsMessages.score_discrepancies_note}" rendered="#{publishedSettings.itemNavigation ne '2' || !assessmentBean.hasSubmission}"/> 
    <h:outputText value="#{assessmentSettingsMessages.score_discrepancies_note_non_linear}" rendered="#{publishedSettings.itemNavigation eq '2' && assessmentBean.hasSubmission}"/> 
  <h:panelGroup rendered="#{publishedSettings.itemNavigation eq '2' && assessmentBean.hasSubmission}">
        <h:selectBooleanCheckbox id="updateMostCurrentSubmissionCheckbox" value="#{publishedSettings.updateMostCurrentSubmission}" onclick="javascript:showRepublishWarning(this);" />
        <h:outputText value="#{assessmentSettingsMessages.update_most_current_submission_checkbox}" />		
  </h:panelGroup>
  <h:outputText id="updateMostCurrentSubmissionCheckboxWarning" rendered="#{publishedSettings.itemNavigation eq '2' && assessmentBean.hasSubmission}" value="#{assessmentSettingsMessages.update_most_current_submission_checkbox_warn}" styleClass="notification" style="visibility:hidden"/>    
</h:panelGrid>
</h:panelGrid>

<h:panelGrid columns="5" styleClass="act">
  <!-- Cancel button -->
   <h:commandButton value="#{commonMessages.cancel_action}" type="submit" action="#{author.getFirstFromPage}" rendered="#{author.isEditPendingAssessmentFlow}"/>
   <h:commandButton value="#{commonMessages.cancel_action}" type="submit" action="editAssessment" rendered="#{!author.isEditPendingAssessmentFlow}">
	  <f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.EditAssessmentListener" />
   </h:commandButton>

   <h:commandButton value="#{assessmentSettingsMessages.button_edit_settings}" type="submit" action="editAssessmentSettings" rendered="#{author.isEditPendingAssessmentFlow}">
      <f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.SetFromPageAsPublishAssessmentListener" />
   </h:commandButton>
   <h:commandButton value="#{assessmentSettingsMessages.button_edit_settings}" type="submit" action="editPublishedAssessmentSettings" rendered="#{!author.isEditPendingAssessmentFlow}">
      <f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.SetFromPageAsPublishAssessmentListener" />
   </h:commandButton>

   <!-- Publish, Republishe and Regrade, or Republish button -->
   <h:commandButton id="publish" value="#{commonMessages.publish_action}" type="submit" styleClass="active" action="publishAssessment" rendered="#{author.isEditPendingAssessmentFlow}" onclick="SPNR.disableControlsAndSpin(this, null);">
     <f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.PublishAssessmentListener" />
   </h:commandButton>

	<h:commandButton  value="#{authorMessages.button_republish_and_regrade}" type="submit" styleClass="active" rendered="#{!author.isEditPendingAssessmentFlow && author.isRepublishAndRegrade}" action="publishAssessment" onclick="SPNR.disableControlsAndSpin(this, null);">
		<f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.RepublishAssessmentListener" />
	</h:commandButton>

	<h:commandButton  value="#{authorMessages.button_republish}" type="submit" styleClass="active" rendered="#{!author.isEditPendingAssessmentFlow && !author.isRepublishAndRegrade}" action="publishAssessment" onclick="SPNR.disableControlsAndSpin(this, null);">
		<f:actionListener type="org.sakaiproject.tool.assessment.ui.listener.author.RepublishAssessmentListener" />
	</h:commandButton>	

  </h:panelGrid>



<h:panelGrid columns="1" border="0" width="78%" styleClass="settings">
<h:panelGrid columns="1" border="0">
<h:panelGrid columns="1" border="0">
  <h:outputText value="#{assessmentSettingsMessages.notification}" styleClass="notification" rendered="#{publishRepublishNotification.sendNotification}" escape="false"/>
  <h:outputText value="#{assessmentSettingsMessages.subject} #{publishRepublishNotification.notificationSubject}" rendered="#{publishRepublishNotification.sendNotification}"/>
</h:panelGrid>

<h:panelGrid columns="1" rowClasses="shorttextPadding" rendered="#{author.isEditPendingAssessmentFlow}" border="0">
	<h:panelGroup>
		<h:panelGroup rendered="#{assessmentSettings.title ne null}"> 
			<f:verbatim><b></f:verbatim>
			<h:outputText value="\"#{assessmentSettings.title}\"" />
			<f:verbatim></b></f:verbatim>
		</h:panelGroup>
		
		<h:outputFormat value=" #{assessmentSettingsMessages.available_anonymously_at}" escape="false" rendered="#{assessmentSettings.releaseTo eq 'Anonymous Users'}">
			<f:param value="#{assessmentSettings.startDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.publishedUrl}" />
		</h:outputFormat>
		
		<h:outputFormat value=" #{assessmentSettingsMessages.available_class_at}" escape="false" rendered="#{assessmentSettings.releaseTo ne 'Anonymous Users' && assessmentSettings.releaseTo ne 'Selected Groups'}">
			<f:param value="#{assessmentSettings.startDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.publishedUrl}" />
		</h:outputFormat>
		
		<h:outputFormat value=" #{assessmentSettingsMessages.available_group_at}" escape="false" rendered="#{assessmentSettings.releaseTo eq 'Selected Groups'}">
			<f:param value="#{assessmentSettings.startDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.releaseToGroupsAsHtml}" />
			<f:param value="#{assessmentSettings.publishedUrl}" />
		</h:outputFormat>
	</h:panelGroup>
	
	<h:panelGroup  rendered="#{assessmentSettings.dueDate ne null}" > 
		<f:verbatim><br/></f:verbatim>
		<h:outputFormat value=" #{assessmentSettingsMessages.it_is_due}" escape="false">
			<f:param value="#{assessmentSettings.dueDateInClientTimezoneString}" />
		</h:outputFormat>	
	</h:panelGroup>
	
	<f:verbatim><br/></f:verbatim>    

	<h:panelGroup>
	<h:outputText value="#{assessmentSettingsMessages.the_time_limit_is} #{assessmentSettings.timedHours} #{assessmentSettingsMessages.hours}, #{assessmentSettings.timedMinutes} #{assessmentSettingsMessages.minutes}. #{assessmentSettingsMessages.submit_when_time_is_up}" rendered="#{assessmentSettings.valueMap.hasTimeAssessment eq 'true' && assessmentSettings.timedMinutes != 0}"/>
	<h:outputText value="#{assessmentSettingsMessages.the_time_limit_is} #{assessmentSettings.timedHours} #{assessmentSettingsMessages.hours}. #{assessmentSettingsMessages.submit_when_time_is_up}" rendered="#{assessmentSettings.valueMap.hasTimeAssessment eq 'true' && assessmentSettings.timedMinutes == 0}"/>
	<h:outputText rendered="#{assessmentSettings.valueMap.hasTimeAssessment ne 'true'}" value="#{assessmentSettingsMessages.there_is_no_time_limit}" />
		
		<h:outputText value=" #{assessmentSettingsMessages.student_submit_unlimited_times}" rendered="#{assessmentSettings.unlimitedSubmissions eq '1'}" />
		<h:outputFormat value=" #{assessmentSettingsMessages.student_submit_certain_time}" escape="false" rendered="#{assessmentSettings.unlimitedSubmissions eq '0'}">
			<f:param value="#{assessmentSettings.submissionsAllowed}" />
		</h:outputFormat>
		
		<h:outputText value=" #{assessmentSettingsMessages.record_highest}" rendered="#{assessmentSettings.scoringType eq '1'}" />
		<h:outputText value=" #{assessmentSettingsMessages.record_last}" rendered="#{assessmentSettings.scoringType eq '2'}" />
		<h:outputText value=" #{assessmentSettingsMessages.record_average}" rendered="#{assessmentSettings.scoringType eq '4'}" />
	</h:panelGroup>
		
	<f:verbatim><br/></f:verbatim>   
		
	<h:panelGroup>
		<h:outputText value=" #{assessmentSettingsMessages.receive_immediate}" rendered="#{assessmentSettings.feedbackDelivery eq '1'}" escape="false"/>
		<h:outputText value=" #{assessmentSettingsMessages.receive_feedback_on_submission}" rendered="#{assessmentSettings.feedbackDelivery eq '4'}" escape="false"/>
		<h:outputText value=" #{assessmentSettingsMessages.receive_no_feedback}" rendered="#{assessmentSettings.feedbackDelivery eq '3'}" escape="false"/>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_on}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && empty assessmentSettings.feedbackEndDateInClientTimezoneString && empty assessmentSettings.feedbackScoreThreshold}" escape="false">
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- Ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_ranges}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && not empty assessmentSettings.feedbackEndDateInClientTimezoneString && empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.feedbackEndDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_on_threshold}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && empty assessmentSettings.feedbackEndDateInClientTimezoneString && not empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackScoreThreshold}" />
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_ranges_threshold}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && not empty assessmentSettings.feedbackEndDateInClientTimezoneString && not empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackScoreThreshold}" />
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.feedbackEndDateInClientTimezoneString}" />
		</h:outputFormat>
	</h:panelGroup>

	<f:verbatim><br/></f:verbatim>

	<%-- Autosubmit information --%>
	<h:panelGroup rendered="#{assessmentSettings.autoSubmit}">
		<%-- Late submissions allowed --%>
		<h:panelGroup rendered="#{assessmentSettings.lateHandling == '1'}">
			<h:outputFormat value="#{assessmentSettingsMessages.autosubmit_info}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_retract_date}" />
				<f:param value="#{assessmentSettings.retractDateString}" />
			</h:outputFormat>
			<h:outputFormat value=" #{assessmentSettingsMessages.autosubmit_info_extended_time}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_retract_date}" />
			</h:outputFormat>
		</h:panelGroup>

		<%-- Late submissions not allowed --%>
		<h:panelGroup rendered="#{assessmentSettings.lateHandling == '2'}">
			<h:outputFormat value="#{assessmentSettingsMessages.autosubmit_info}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_due_date}" />
				<f:param value="#{assessmentSettings.dueDateInClientTimezoneString}" />
			</h:outputFormat>
			<h:outputFormat value=" #{assessmentSettingsMessages.autosubmit_info_extended_time}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_due_date}" />
			</h:outputFormat>
		</h:panelGroup>
	</h:panelGroup>

	</h:panelGrid>

	<h:panelGrid columns="1" rowClasses="shorttextPadding" rendered="#{!author.isEditPendingAssessmentFlow}" border="0">
		<h:panelGroup>
			<h:panelGroup rendered="#{publishedSettings.title ne null}"> 
				<f:verbatim><b></f:verbatim>
				<h:outputText value="\"#{publishedSettings.title}\"" />
				<f:verbatim></b></f:verbatim>
			</h:panelGroup>

			<h:outputFormat value=" #{assessmentSettingsMessages.available_anonymously_at}" escape="false" rendered="#{publishedSettings.releaseTo eq 'Anonymous Users'}">
				<f:param value="#{publishedSettings.startDateInClientTimezoneString}" />
				<f:param value="#{publishedSettings.publishedUrl}" />
			</h:outputFormat>
		
			<h:outputFormat value=" #{assessmentSettingsMessages.available_class_at}" escape="false" rendered="#{publishedSettings.releaseTo ne 'Anonymous Users' && publishedSettings.releaseTo ne 'Selected Groups'}">
				<f:param value="#{publishedSettings.startDateInClientTimezoneString}" />
				<f:param value="#{publishedSettings.publishedUrl}" />
			</h:outputFormat>
		
			<h:outputFormat value=" #{assessmentSettingsMessages.available_group_at}" escape="false" rendered="#{publishedSettings.releaseTo eq 'Selected Groups'}">
				<f:param value="#{publishedSettings.startDateInClientTimezoneString}" />
				<f:param value="#{publishedSettings.releaseToGroupsAsHtml}" />
				<f:param value="#{publishedSettings.publishedUrl}" />
			</h:outputFormat>
		</h:panelGroup>
		
		<h:panelGroup  rendered="#{publishedSettings.dueDate ne null}" >
			<f:verbatim><br/></f:verbatim> 
			<h:outputFormat value=" #{assessmentSettingsMessages.it_is_due}" escape="false">
				<f:param value="#{publishedSettings.dueDateInClientTimezoneString}" />
			</h:outputFormat>
		</h:panelGroup>
		
		<f:verbatim><br/></f:verbatim>
		
		<h:panelGroup>
		<h:outputText value="#{assessmentSettingsMessages.the_time_limit_is} #{publishedSettings.timedHours} #{assessmentSettingsMessages.hours}, #{publishedSettings.timedMinutes} #{assessmentSettingsMessages.minutes}. #{assessmentSettingsMessages.submit_when_time_is_up}" rendered="#{publishedSettings.valueMap.hasTimeAssessment eq 'true' && publishedSettings.timedMinutes != 0}"/>
		<h:outputText value="#{assessmentSettingsMessages.the_time_limit_is} #{publishedSettings.timedHours} #{assessmentSettingsMessages.hours}. #{assessmentSettingsMessages.submit_when_time_is_up}" rendered="#{publishedSettings.valueMap.hasTimeAssessment eq 'true' && publishedSettings.timedMinutes == 0}"/>
		<h:outputText rendered="#{publishedSettings.valueMap.hasTimeAssessment ne 'true'}" value="#{assessmentSettingsMessages.there_is_no_time_limit}" />

			<h:outputText value=" #{assessmentSettingsMessages.student_submit_unlimited_times}" rendered="#{publishedSettings.unlimitedSubmissions eq '1'}" />
			<h:outputFormat value=" #{assessmentSettingsMessages.student_submit_certain_time}" escape="false" rendered="#{publishedSettings.unlimitedSubmissions eq '0'}">
				<f:param value="#{publishedSettings.submissionsAllowed}" />
			</h:outputFormat>
			
			<h:outputText value=" #{assessmentSettingsMessages.record_highest}" rendered="#{publishedSettings.scoringType eq '1'}" />
			<h:outputText value=" #{assessmentSettingsMessages.record_last}" rendered="#{publishedSettings.scoringType eq '2'}" />
			<h:outputText value=" #{assessmentSettingsMessages.record_average}" rendered="#{publishedSettings.scoringType eq '4'}" />
		</h:panelGroup>
		
	<f:verbatim><br/></f:verbatim>
		
	<h:panelGroup>
		<h:outputText value=" #{assessmentSettingsMessages.receive_immediate}" rendered="#{publishedSettings.feedbackDelivery eq '1'}" escape="false"/>
		<h:outputText value=" #{assessmentSettingsMessages.receive_feedback_on_submission}" rendered="#{publishedSettings.feedbackDelivery eq '4'}" escape="false"/>
		<h:outputText value=" #{assessmentSettingsMessages.receive_no_feedback}" rendered="#{publishedSettings.feedbackDelivery eq '3'}" escape="false"/>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_on}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && empty assessmentSettings.feedbackEndDateInClientTimezoneString && empty assessmentSettings.feedbackScoreThreshold}" escape="false">
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- Ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_ranges}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && not empty assessmentSettings.feedbackEndDateInClientTimezoneString && empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.feedbackEndDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_on_threshold}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && empty assessmentSettings.feedbackEndDateInClientTimezoneString && not empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackScoreThreshold}" />
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
		</h:outputFormat>
		<%-- No ranged no threshold--%>
		<h:outputFormat value=" #{assessmentSettingsMessages.feedback_available_ranges_threshold}" rendered="#{assessmentSettings.feedbackDelivery eq '2' && not empty assessmentSettings.feedbackEndDateInClientTimezoneString && not empty assessmentSettings.feedbackScoreThreshold }" escape="false">
			<f:param value="#{assessmentSettings.feedbackScoreThreshold}" />
			<f:param value="#{assessmentSettings.feedbackDateInClientTimezoneString}" />
			<f:param value="#{assessmentSettings.feedbackEndDateInClientTimezoneString}" />
		</h:outputFormat>
	</h:panelGroup>

	<f:verbatim><br/></f:verbatim>

	<%-- Autosubmit information --%>
	<h:panelGroup rendered="#{assessmentSettings.autoSubmit}">
		<%-- Late submissions allowed --%>
		<h:panelGroup rendered="#{assessmentSettings.lateHandling == '1'}">
			<h:outputFormat value="#{assessmentSettingsMessages.autosubmit_info}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_retract_date}" />
				<f:param value="#{assessmentSettings.retractDateString}" />
			</h:outputFormat>
			<h:outputFormat value=" #{assessmentSettingsMessages.autosubmit_info_extended_time}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_retract_date}" />
			</h:outputFormat>
		</h:panelGroup>

		<%-- Late submissions not allowed --%>
		<h:panelGroup rendered="#{assessmentSettings.lateHandling == '2'}">
			<h:outputFormat value="#{assessmentSettingsMessages.autosubmit_info}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_due_date}" />
				<f:param value="#{assessmentSettings.dueDateInClientTimezoneString}" />
			</h:outputFormat>
			<h:outputFormat value=" #{assessmentSettingsMessages.autosubmit_info_extended_time}" escape="false">
				<f:param value="#{assessmentSettingsMessages.header_extendedTime_due_date}" />
			</h:outputFormat>
		</h:panelGroup>
	</h:panelGroup>

</h:panelGrid>
</h:panelGrid>
<h:panelGrid />
<h:panelGrid />
</h:panelGrid>

<f:verbatim><p></p></f:verbatim>

<script>
function showRepublishWarning (obj) {
	const objwarn = document.getElementById('publishAssessmentForm:updateMostCurrentSubmissionCheckboxWarning');
	objwarn.style.visibility = obj.checked ? 'visible' : 'hidden';
}  
</script>

<p>&nbsp;</p>

 </h:form>
 <!-- end content -->
</div>

      </body>
    </html>

  </f:view>
