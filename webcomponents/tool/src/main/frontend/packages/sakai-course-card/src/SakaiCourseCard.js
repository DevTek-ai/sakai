import { html, css } from "lit";
import { SakaiElement } from "@sakai-ui/sakai-element";
import "@sakai-ui/sakai-icon";
import { loadProperties } from "@sakai-ui/sakai-i18n";

export class SakaiCourseCard extends SakaiElement {

  static properties = {

    courseData: { attribute: "course-data", type: Object },
    toolUrls: { attribute: "tool-urls", type: Object },

    toolnameMap: { state: true },
  };

  constructor() {

    super();

    this._courseData = {
      id: "xyz",
      title: "Course Title",
      code: "Course Code",
      favourite: false,
      url: "http://www.ebay.co.uk",
      alerts: [],
    };

    loadProperties("toolname-mappings").then(r => {

      this.toolnameMap = {
        assignments: r.assignments,
        gradebook: r.gradebook,
        forums: r.forums,
      };
    });

    this._toolUrlDefaults = {
      assignments: "http://www.theguardian.co.uk",
      gradebook: "http://www.oracle.com",
      forums: "http://www.twitter.com",
    };

    this._toolUrls = this._toolUrlDefaults;

    this.loadTranslations("coursecard").then(r => this._i18n = r);
  }

  set courseData(value) {

    const oldValue = this._courseData;
    this._courseData = value;
    this._courseData.alerts = this._courseData.alerts || [];
    this.requestUpdate("courseData", oldValue);
  }

  get courseData() {
    return this._courseData;
  }

  set toolUrls(value) {
    this._toolUrls = Object.assign(this._toolUrlDefaults, value);
  }

  get toolUrls() {
    return this._toolUrls;
  }

  _toggleFavourite(e) {

    const url = `/api/${e.target.checked ? "addfavourite" : "removefavourite"}?siteId=${this._courseData.id}`;

    fetch(url).then(r => {

      if (r.ok) {
        this._courseData.favourite = e.target.checked;
        this.requestUpdate();
        this.dispatchEvent(new CustomEvent(e.target.checked ? "favourited" : "unfavourited", { detail: { id: this._courseData.id }, bubbles: true }));
      } else {
        e.target.checked = !e.target.checked;
        throw new Error(`Failed to favourite/unfavourite site with id ${this._courseData.id}`);
      }
    }).catch(error => console.error(error));
  }

  shouldUpdate() {
    return this._i18n && this.toolnameMap;
  }

  render() {

    //<div id="arrow" data-popper-arrow></div>

    return html`
      <div class="info-block" style="background-image: ${this._courseData.image ? `url(${this._courseData.image})` : ""}">
        <div class="top-bar">
          <a href="${this._courseData.url}" title="${this._i18n.visit} ${this._courseData.title}">
            <div class="title-block">
              ${this._courseData.favourite ? html`<sakai-icon class="favourite" type="favourite" size="small"></sakai-icon>` : ""}
              <span>${this.courseData.title}</span>
            </div>
          </a>
        </div>
        <a href="${this._courseData.url}" title="${this._i18n.visit} ${this._courseData.title}">
          <div class="code-block">${this._courseData.code}</div>
        </a>
      </div>
      <a href="${this._courseData.url}" title="${this._i18n.visit} ${this._courseData.title}">
        <div class="tool-alerts-block">
          ${this._courseData.alerts.map(t => html`<div><a .href="${this._toolUrls[t]}" .title="${this._i18n[`${t }_tooltip`]}"><sakai-icon .type=${t} size="small" has-alerts></a></div>`)}
        </div>
      </a>
    `;
  }

  static styles = css`
    :host {
      display: block;
      width: var(--sakai-course-card-width);
    }

    a {
      text-decoration: none;
    }
    .info-block {
      height: var(--sakai-course-card-info-height);
      border: solid;
      border-width: var(--sakai-course-card-border-width);
      border-color: var(--sakai-course-card-border-color);
      border-bottom: 0;
      border-radius: var(--sakai-course-card-border-radius) var(--sakai-course-card-border-radius) 0 0;
      padding: var(--sakai-course-card-padding);
      background: no-repeat;
      background-color: var(--sakai-course-card-info-block-bg-color);
      background-size: cover;
      background-position: center;
    }
      .top-bar { display: flex; justify-content: space-between;}
        .favourite { color: var(--sakai-icon-favourite-color); margin-right: 4px; }
        .title-block {
          flex: 2;
          color: var(--sakai-course-card-title-color);
        }
        .title-block span {
          font-size: var(--sakai-course-card-title-font-size);
        }
        .code-block {
          color: var(--sakai-course-card-code-color);
          font-size: var(--sakai-course-card-code-font-size);
        }
    .tool-alerts-block {
      display: flex;
      align-items: center;
      justify-content: left;
      height: var(--sakai-course-card-tool-alerts-height);
      padding: var(--sakai-course-card-tool-alerts-padding);
      border: solid;
      border-width: var(--sakai-course-card-border-width);
      border-color: var(--sakai-course-card-border-color);
      border-radius: 0 0 var(--sakai-course-card-border-radius) var(--sakai-course-card-border-radius);
      border-top: 0;
      color: var(--sakai-course-card-tool-alerts-color);
      background-color: var(--sakai-course-card-bg-color);
    }
      .tool-alerts-block div { flex: 0; margin-left: 5px; margin-right: 5px; }
      .tool-alerts sakai-icon { margin: 0 5px 0 5px;}
      .alert { color: var(--sakai-course-card-tool-alert-icon-color) }

    #course-options { min-width: 200px; padding: 10px; }
    #course-options input { margin-right: 10px; }
      #favourite-block {
        color: var(--sakai-course-card-options-menu-favourites-block-color);
        font-size: var(--sakai-course-card-options-menu-favourites-block-font-size);
        font-weight: var(--sakai-course-card-options-menu-favourites-block-font-weight);
      }
  `;
}
