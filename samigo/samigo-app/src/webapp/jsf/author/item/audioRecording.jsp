<%@ page contentType="text/html;charset=utf-8" pageEncoding="utf-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsf/html" prefix="h" %>
<%@ taglib uri="http://java.sun.com/jsf/core" prefix="f" %>
<%@ taglib uri="http://www.sakaiproject.org/samigo" prefix="samigo" %>
<%@ taglib uri="http://sakaiproject.org/jsf2/sakai" prefix="sakai" %>
<!DOCTYPE html
     PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!--
* $Id$
<%--
***********************************************************************************
*
* Copyright (c) 2004, 2005, 2006 The Sakai Foundation.
*
* Licensed under the Educational Community License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.osedu.org/licenses/ECL-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License. 
*
**********************************************************************************/
--%>
-->
  <f:view>
    <html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
      <head><%= request.getAttribute("html.head") %>
      <title><h:outputText value="#{authorMessages.item_display_author}"/></title>
      <script src="/samigo-app/js/authoring.js"></script>
      <script type="module" src="/webcomponents/bundles/rubric-association-requirements.js<h:outputText value="#{studentScores.CDNQuery}" />"></script>
      </head>
<body onload="<%= request.getAttribute("html.body.onload") %>">

<div class="portletBody container-fluid">
<!-- content... -->
<!-- FORM -->



<!-- HEADING -->
<%@ include file="/jsf/author/item/itemHeadings.jsp" %>
<h:form id="itemForm">
<f:verbatim><input type="hidden" id="ckeditor-autosave-context" name="ckeditor-autosave-context" value="samigo_edit_audioRecording" /></f:verbatim>
<h:panelGroup rendered="#{itemauthor.currentItem.itemId!=null}"><f:verbatim><input type="hidden" id="ckeditor-autosave-entity-id" name="ckeditor-autosave-entity-id" value="</f:verbatim><h:outputText value="#{itemauthor.currentItem.itemId}"/><f:verbatim>"/></f:verbatim></h:panelGroup>
<p class="act">
  <h:commandButton rendered="#{itemauthor.target=='assessment'}" value="#{commonMessages.action_save}" action="#{itemauthor.currentItem.getOutcome}" styleClass="active">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ItemAddListener" />
  </h:commandButton>
  <h:commandButton rendered="#{itemauthor.target=='questionpool'}" value="#{commonMessages.action_save}" action="#{itemauthor.currentItem.getPoolOutcome}" styleClass="active">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ItemAddListener" />
  </h:commandButton>


  <h:commandButton rendered="#{itemauthor.target=='assessment'}" value="#{commonMessages.cancel_action}" action="editAssessment" immediate="true">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ResetItemAttachmentListener" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.EditAssessmentListener" />
  </h:commandButton>

 <h:commandButton rendered="#{itemauthor.target=='questionpool'}" value="#{commonMessages.cancel_action}" action="editPool" immediate="true">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ResetItemAttachmentListener" />
 </h:commandButton>
</p>

<div>

    <!-- QUESTION PROPERTIES -->
    <!-- 1 POINTS -->
    <div class="form-group row">
        <h:outputLabel for="answerptr" value="#{authorMessages.answer_point_value}" styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-2">
            <h:inputText id="answerptr" label="#{authorMessages.pt}" value="#{itemauthor.currentItem.itemScore}" 
                        required="true" disabled="#{author.isEditPoolFlow}" styleClass="form-control ConvertPoint">
                <f:validateDoubleRange minimum="0.00"/>
            </h:inputText>
            <h:message for="answerptr" styleClass="validate"/>
        </div>
    </div>
  
    <div class="form-group row">
        <h:outputLabel for="itemScore" value="#{authorMessages.answer_point_value_display}" styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-5 samigo-inline-radio">
            <h:selectOneRadio value="#{itemauthor.currentItem.itemScoreDisplayFlag}" id="itemScore">
                <f:selectItem itemValue="true" itemLabel="#{authorMessages.yes}" />
                <f:selectItem itemValue="false" itemLabel="#{authorMessages.no}" />
            </h:selectOneRadio>
        </div>
    </div>

    <%@ include file="/jsf/author/item/rubricAssociation.jsp" %>

    <!-- Extra Credit -->
    <%@ include file="/jsf/author/inc/extraCreditSetting.jspf" %>

    <!-- 2 TEXT -->
    <div class="form-group row">
        <h:outputLabel for="questionItemText_textinput" value="#{authorMessages.q_text}" styleClass="form-label"/>
        <div class="col-md-8">
            <!-- WYSIWYG -->
            <h:panelGrid>
                <samigo:wysiwyg identity="questionItemText" rows="140" value="#{itemauthor.currentItem.itemText}" hasToggle="yes" mode="author">
                    <f:validateLength maximum="60000"/>
                </samigo:wysiwyg>
            </h:panelGrid>
        </div>
    </div>

    <!-- 2a ATTACHMENTS -->  
    <%@ include file="/jsf/author/item/attachment.jsp" %>

    <!-- 3 TIME allowed -->
    <div class="form-group row">
        <h:outputLabel for="timeallowed" value="#{authorMessages.time_allowed_seconds}:  #{authorMessages.time_allowed_seconds_indic} " 
                        styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-2">
            <h:inputText id="timeallowed" value="#{itemauthor.currentItem.timeAllowed}" required="true" styleClass="form-control" validatorMessage="#{authorMessages.submissions_allowed_error}">
                <f:validateLongRange minimum="1" />
            </h:inputText>
            <h:message for="timeallowed" styleClass="validate"/>
        </div>
    </div>
  
  
    <!-- 4 attempts -->
    <div class="form-group row">
        <h:outputLabel for="noattempts" value="#{authorMessages.number_of_attempts} : #{authorMessages.number_of_attempts_indic}"
                    styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-2">
            <h:selectOneMenu id="noattempts" value="#{itemauthor.currentItem.numAttempts}" required="true">
                <f:selectItem itemLabel="#{authorMessages.unlimited}" itemValue="9999"/> <%-- 9999 indicates unlimited --%>
                <f:selectItem itemLabel="1" itemValue="1"/>
                <f:selectItem itemLabel="2" itemValue="2"/>
                <f:selectItem itemLabel="3" itemValue="3"/>
                <f:selectItem itemLabel="4" itemValue="4"/>
                <f:selectItem itemLabel="5" itemValue="5"/>
                <f:selectItem itemLabel="6" itemValue="6"/>
                <f:selectItem itemLabel="7" itemValue="7"/>
                <f:selectItem itemLabel="8" itemValue="8"/>
                <f:selectItem itemLabel="9" itemValue="9"/>
                <f:selectItem itemLabel="10" itemValue="10"/>
        </h:selectOneMenu>    
        </div>   
    </div>
    <h:message for="noattempts" styleClass="validate"/><br/>

    <!-- 5 PART -->
    <h:panelGroup styleClass="form-group row" layout="block" rendered="#{itemauthor.target == 'assessment' && !author.isEditPoolFlow}">
        <h:outputLabel for="assignToPart" value="#{authorMessages.assign_to_p} " styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-8">
            <h:selectOneMenu id="assignToPart" value="#{itemauthor.currentItem.selectedSection}">
                <f:selectItems value="#{itemauthor.sectionSelectList}" />
            </h:selectOneMenu>
        </div>
    </h:panelGroup>
    
    <!-- 6 POOL -->
    <h:panelGroup styleClass="form-group row" layout="block" rendered="#{itemauthor.target == 'assessment' && author.isEditPendingAssessmentFlow}">
        <h:outputLabel for="assignToPool" value="#{authorMessages.assign_to_question_p} " styleClass="col-md-4 col-lg-2 form-label"/>
        <div class="col-md-8">
            <h:selectOneMenu id="assignToPool" value="#{itemauthor.currentItem.selectedPool}">
                <f:selectItem itemValue="" itemLabel="#{authorMessages.select_a_pool_name}" />
                <f:selectItems value="#{itemauthor.poolSelectList}" />
            </h:selectOneMenu>
        </div>
    </h:panelGroup>


    <!-- FEEDBACK -->
    <h:panelGroup rendered="#{itemauthor.target == 'questionpool' || (itemauthor.target != 'questionpool' && (author.isEditPendingAssessmentFlow && assessmentSettings.feedbackAuthoring ne '2') || (!author.isEditPendingAssessmentFlow && publishedSettings.feedbackAuthoring ne '2'))}">
        <div class="form-group row">
            <h:outputLabel for="questionFeedbackGeneral_textinput" value="#{commonMessages.feedback_optional}" escape="false" styleClass="form-label"/>
            <div class="col-md-8">
                <h:panelGrid >
                    <samigo:wysiwyg identity="questionFeedbackGeneral" rows="140" value="#{itemauthor.currentItem.generalFeedback}" hasToggle="yes" mode="author">
                        <f:validateLength maximum="60000"/>
                    </samigo:wysiwyg>
                </h:panelGrid>
            </div>
        </div> 
    </h:panelGroup>

    <!-- METADATA -->
    <h:panelGroup rendered="#{itemauthor.showMetadata == 'true'}" styleClass="longtext">
        <h:outputLabel value="Metadata"/>
        <div class="form-group row">
            <h:outputLabel for="obj" value="#{authorMessages.objective}" styleClass="col-md-4 col-lg-2 form-label"/>
            <div class="col-md-5 col-lg-3">
                <h:inputText id="obj" value="#{itemauthor.currentItem.objective}" styleClass="form-control"/>
            </div>
        </div>
        <div class="form-group row">
            <h:outputLabel for="keyword" value="#{authorMessages.keyword}" styleClass="col-md-4 col-lg-2 form-label"/>
            <div class="col-md-5 col-lg-3">
                <h:inputText id="keyword" value="#{itemauthor.currentItem.keyword}" styleClass="form-control"/>
            </div>
        </div>
        <div class="form-group row">
            <h:outputLabel for="rubric" value="#{authorMessages.rubric_colon}" styleClass="col-md-4 col-lg-2 form-label"/>
            <div class="col-md-5 col-lg-3">
                <h:inputText id="rubric" value="#{itemauthor.currentItem.rubric}" styleClass="form-control"/>
            </div>
        </div>
    </h:panelGroup>

    <%@ include file="/jsf/author/item/tags.jsp" %>

</div>

<p class="act">
  <h:commandButton rendered="#{itemauthor.target=='assessment'}" value="#{commonMessages.action_save}" action="#{itemauthor.currentItem.getOutcome}" styleClass="active">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ItemAddListener" />
  </h:commandButton>
  <h:commandButton rendered="#{itemauthor.target=='questionpool'}" value="#{commonMessages.action_save}" action="#{itemauthor.currentItem.getPoolOutcome}" styleClass="active">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ItemAddListener" />
  </h:commandButton>


  <h:commandButton rendered="#{itemauthor.target=='assessment'}" value="#{commonMessages.cancel_action}" action="editAssessment" immediate="true">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ResetItemAttachmentListener" />
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.EditAssessmentListener" />
  </h:commandButton>

 <h:commandButton rendered="#{itemauthor.target=='questionpool'}" value="#{commonMessages.cancel_action}" action="editPool" immediate="true">
        <f:actionListener
           type="org.sakaiproject.tool.assessment.ui.listener.author.ResetItemAttachmentListener" />
 </h:commandButton>

</p>
</h:form>


<!-- end content -->
</div>
    </body>
  </html>
</f:view>
