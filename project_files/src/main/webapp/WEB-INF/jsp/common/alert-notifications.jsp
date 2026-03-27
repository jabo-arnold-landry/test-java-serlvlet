<%@ page language="java" contentType="text/html; charset=UTF-8"
pageEncoding="UTF-8"%> <%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Global Alert Notification System -->
<style>
  .toast-stack {
    position: fixed;
    bottom: 16px;
    right: 16px;
    z-index: 1100;
    display: flex;
    flex-direction: column;
    gap: 12px;
    align-items: flex-end;
  }

  .live-toast-card {
    min-width: 320px;
    max-width: 420px;
    background: #f8f9fa;
    border-radius: 8px;
    padding: 16px;
    display: flex;
    align-items: flex-start;
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    border-left: 4px solid var(--toast-accent, #0ea5e9);
    animation: fadeInUp 0.3s ease;
    margin-bottom: 8px;
  }

  .live-toast-icon {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    background: var(--toast-bg, rgba(14, 165, 233, 0.15));
    color: var(--toast-accent, #0ea5e9);
    flex-shrink: 0;
    margin-right: 12px;
  }

  .live-toast-body {
    flex: 1;
    min-width: 0;
  }

  .live-toast-title {
    font-weight: 600;
    color: #212529;
    margin: 0 0 4px 0;
    font-size: 14px;
    line-height: 1.4;
  }

  .live-toast-msg {
    color: #6c757d;
    font-size: 13px;
    margin: 0 0 4px 0;
    line-height: 1.4;
  }

  .live-toast-meta {
    color: #adb5bd;
    font-size: 11px;
    margin: 0;
    font-style: italic;
  }

  .live-toast-close {
    border: none;
    background: transparent;
    color: #6c757d;
    cursor: pointer;
    padding: 4px;
    margin-left: 8px;
    font-size: 16px;
    line-height: 1;
  }

  .live-toast-close:hover {
    color: #495057;
  }

  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(20px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
</style>

<div id="alertToastStack" class="toast-stack"></div>

<script>
  // Global Alert Notification System
  (function () {
    // Prevent double-initialization
    if (window.__alertSystemInitialized) {
      return;
    }
    window.__alertSystemInitialized = true;

    // Use server-side context path — always reliable
    const CONTEXT_PATH = "${pageContext.request.contextPath}";

    const alertPoll = {
      baseUrl: CONTEXT_PATH,
      lastSeenId: 0,
      sseConnected: false,
      reconnectTimer: null,
      pollTimer: null,
      fetchInFlight: false,
    };

    const toastStack = document.getElementById("alertToastStack");

    if (!toastStack) {
      return;
    }

    const alertStyles = {
      HIGH_TEMP: {
        accent: "#dc3545",
        bg: "rgba(220,53,69,0.1)",
        icon: "bi-exclamation-triangle-fill",
        label: "High Temperature Alert",
      },
      HUMIDITY: {
        accent: "#0d6efd",
        bg: "rgba(13,110,253,0.1)",
        icon: "bi-droplet-fill",
        label: "Humidity Alert",
      },
      UPS_OVERLOAD: {
        accent: "#fd7e14",
        bg: "rgba(253,126,20,0.1)",
        icon: "bi-lightning-charge-fill",
        label: "UPS Overload Alert",
      },
      LOW_BATTERY: {
        accent: "#ffc107",
        bg: "rgba(255,193,7,0.1)",
        icon: "bi-battery-half",
        label: "Low Battery Alert",
      },
      MAINTENANCE_DUE: {
        accent: "#198754",
        bg: "rgba(25,135,84,0.1)",
        icon: "bi-tools",
        label: "Maintenance Due",
      },
      default: {
        accent: "#0ea5e9",
        bg: "rgba(14,165,233,0.1)",
        icon: "bi-info-circle-fill",
        label: "System Alert",
      },
    };

    function renderAlertCard(data) {
      const style = alertStyles[data.type] || alertStyles.default;
      const card = document.createElement("div");
      card.className = "live-toast-card";
      card.style.setProperty("--toast-accent", style.accent);
      card.style.setProperty("--toast-bg", style.bg);

      const iconWrap = document.createElement("div");
      iconWrap.className = "live-toast-icon";
      const icon = document.createElement("i");
      icon.className = "bi " + style.icon;
      iconWrap.appendChild(icon);

      const body = document.createElement("div");
      body.className = "live-toast-body";

      const titleEl = document.createElement("div");
      titleEl.className = "live-toast-title";
      titleEl.textContent = style.label;

      const msgEl = document.createElement("div");
      msgEl.className = "live-toast-msg";
      msgEl.textContent = data.message || "Alert triggered";

      const metaEl = document.createElement("div");
      metaEl.className = "live-toast-meta";
      const metaParts = [];
      if (data.equipmentType) metaParts.push(data.equipmentType);
      if (data.equipmentId) metaParts.push("ID: " + data.equipmentId);
      if (data.createdAt)
        metaParts.push(new Date(data.createdAt).toLocaleString());
      metaEl.textContent = metaParts.join(" \u2022 ");

      body.append(titleEl, msgEl, metaEl);

      const closeBtn = document.createElement("button");
      closeBtn.className = "live-toast-close";
      closeBtn.setAttribute("aria-label", "Close");
      closeBtn.innerHTML = "\u00d7";
      closeBtn.addEventListener("click", function () {
        card.remove();
      });

      card.append(iconWrap, body, closeBtn);
      toastStack.prepend(card);

      // Limit to 5 toasts at once
      while (toastStack.childElementCount > 5) {
        toastStack.lastElementChild.remove();
      }

      // Auto-remove after 10 seconds
      setTimeout(function () {
        if (card.parentNode) card.remove();
      }, 10000);
    }

    function clearReconnectTimer() {
      if (alertPoll.reconnectTimer) {
        clearTimeout(alertPoll.reconnectTimer);
        alertPoll.reconnectTimer = null;
      }
    }

    function scheduleSseReconnect() {
      if (document.visibilityState === "hidden" || alertPoll.reconnectTimer) {
        return;
      }
      alertPoll.reconnectTimer = setTimeout(function () {
        alertPoll.reconnectTimer = null;
        startSse();
      }, 5000);
    }

    function closeSseConnection() {
      if (window.alertEventSource) {
        window.alertEventSource.close();
        window.alertEventSource = null;
      }
      alertPoll.sseConnected = false;
    }

    // ---------- SSE (primary real-time channel) ----------
    function startSse() {
      if (document.visibilityState === "hidden") {
        return;
      }
      if (typeof EventSource === "undefined") {
        return;
      }

      var sseUrl = alertPoll.baseUrl + "/alerts/stream";

      try {
        closeSseConnection();
        clearReconnectTimer();

        var es = new EventSource(sseUrl);
        window.alertEventSource = es;

        es.onopen = function () {
          alertPoll.sseConnected = true;
        };

        var handler = function (event) {
          if (!event || !event.data) return;
          try {
            var data = JSON.parse(event.data);
            if (data && data.id && data.id > alertPoll.lastSeenId) {
              alertPoll.lastSeenId = data.id;
              renderAlertCard(data);
            }
          } catch (e) {
            // Ignore malformed events and continue listening.
          }
        };

        // Listen for named 'alert' events
        es.addEventListener("alert", handler);

        // Fallback: generic messages
        es.onmessage = function (event) {
          if (event.data && event.data !== "connected") {
            handler(event);
          }
        };

        es.onerror = function () {
          closeSseConnection();
          scheduleSseReconnect();
        };
      } catch (error) {
        closeSseConnection();
        scheduleSseReconnect();
      }
    }

    // ---------- Polling (backup channel) ----------
    function pollLatestAlert() {
      if (
        document.visibilityState === "hidden" ||
        alertPoll.sseConnected ||
        alertPoll.fetchInFlight
      ) {
        return;
      }

      var pollUrl =
        alertPoll.baseUrl + "/alerts/latest?sinceId=" + alertPoll.lastSeenId;

      alertPoll.fetchInFlight = true;
      fetch(pollUrl, { headers: { Accept: "application/json" } })
        .then(function (res) {
          if (!res.ok) {
            return null;
          }

          var contentType = res.headers.get("Content-Type") || "";
          if (contentType.indexOf("application/json") === -1) {
            return null;
          }

          return res.json();
        })
        .then(function (data) {
          if (data && data.id && data.id > alertPoll.lastSeenId) {
            var isFirstPoll = alertPoll.lastSeenId === 0;
            alertPoll.lastSeenId = data.id;

            // Only show toast for new alerts that occur *after* page load
            if (!isFirstPoll) {
              renderAlertCard(data);
            }
          }
        })
        .catch(function () {
          // Keep silent; fallback polling retries automatically.
        })
        .finally(function () {
          alertPoll.fetchInFlight = false;
        });
    }

    // ---------- Init ----------
    function initializeAlerts() {
      // Start SSE (primary)
      startSse();

      // Start polling as backup every 10 seconds (used when SSE is unavailable)
      alertPoll.pollTimer = setInterval(pollLatestAlert, 10000);
      // Also do one immediate poll
      setTimeout(pollLatestAlert, 500);

      // Pause network activity when tab is not visible and resume when visible.
      document.addEventListener("visibilitychange", function () {
        if (document.visibilityState === "hidden") {
          clearReconnectTimer();
          closeSseConnection();
          return;
        }
        startSse();
        pollLatestAlert();
      });

      // Ensure intervals and open sockets are not leaked on page unload.
      window.addEventListener("beforeunload", function () {
        clearReconnectTimer();
        closeSseConnection();
        if (alertPoll.pollTimer) {
          clearInterval(alertPoll.pollTimer);
          alertPoll.pollTimer = null;
        }
      });
    }

    // Expose a manual test helper on the console
    window.testAlert = function () {
      renderAlertCard({
        id: Date.now(),
        type: "HIGH_TEMP",
        message: "This is a manual test alert!",
        equipmentType: "Test",
        equipmentId: "0",
        createdAt: new Date().toISOString(),
      });
    };

    // Start when DOM is ready (only once)
    if (document.readyState === "loading") {
      document.addEventListener("DOMContentLoaded", initializeAlerts);
    } else {
      initializeAlerts();
    }
  })();
</script>
