package org.sakaiproject.dummy.tool;

import lombok.extern.slf4j.Slf4j;
import org.sakaiproject.cheftool.Context;
import org.sakaiproject.cheftool.JetspeedRunData;
import org.sakaiproject.cheftool.VelocityPortletPaneledAction;
import org.sakaiproject.cheftool.VelocityPortlet;
import org.sakaiproject.event.api.SessionState;

/**
 * <p>
 * DummyToolAction is a placeholder admin tool for demonstration purposes.
 * </p>
 */
@Slf4j
public class DummyAction extends VelocityPortletPaneledAction {

    /**
     * Build the main context for the dummy tool.
     */
    public String buildMainPanelContext(VelocityPortlet portlet, Context context, JetspeedRunData rundata, SessionState state) {
        context.put("message", "Welcome to the Dummy Admin Tool!");
        return "_dummy";
    }
}