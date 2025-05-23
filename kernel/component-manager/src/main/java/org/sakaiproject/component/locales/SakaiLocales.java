/**********************************************************************************
 * $URL$
 * $Id$
 ***********************************************************************************
 *
 * Copyright (c) 2003, 2004, 2005, 2006, 2007, 2008 Sakai Foundation
 *
 * Licensed under the Educational Community License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *       http://www.opensource.org/licenses/ECL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 **********************************************************************************/

package org.sakaiproject.component.locales;

/**
 * This stores constants related to the Sakai default locales
 * 
 * @author Aaron Zeckoski (azeckoski @ unicon.net) (azeckoski @ vt.edu)
 */
public class SakaiLocales {

    /**
     * This should be complete list of supported locales and should match the commented list in default.sakai.properties
     * It MUST be a comma separated list of locale keys (be careful with your formatting)
     */
    public static final String SAKAI_LOCALES_DEFAULT = "en_US, ja_JP, zh_CN, es_ES, fr_FR, ca_ES, sv_SE, pt_BR, eu, tr_TR, mn, hi_IN, fa_IR, ar, ro_RO, bg";
    public static final String SAKAI_LEGACY_LOCALES = "en_GB, ko_KR, nl_NL, zh_TW, fr_CA, ru_RU, pt_PT, vi_VN, es_MX, pl_PL, de_DE, it_IT";

}
