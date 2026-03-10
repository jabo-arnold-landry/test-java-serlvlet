<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

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
    box-shadow: 0 4px 12px rgba(0,0,0,0.15); 
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
    background: var(--toast-bg, rgba(14,165,233,0.15)); 
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
    from { opacity: 0; transform: translateY(20px); } 
    to { opacity: 1; transform: translateY(0); } 
}
</style>

<div id="alertToastStack" class="toast-stack"></div>

<script>
// Global Alert Notification System
(function() {
    // Prevent double-initialization
    if (window.__alertSystemInitialized) {
        console.log('⚠️ Alert system already initialized, skipping.');
        return;
    }
    window.__alertSystemInitialized = true;

    console.log('🚀 Alert Notification System Initializing...');
    
    // Use server-side context path — always reliable
    const CONTEXT_PATH = '${pageContext.request.contextPath}';
    
    const alertPoll = {
        baseUrl: CONTEXT_PATH,
        lastSeenId: 0
    };
    
    const toastStack = document.getElementById('alertToastStack');
    
    if (!toastStack) {
        console.error('❌ Alert toast stack container not found!');
        return;
    }
    
    console.log('✅ Toast stack found, base URL:', alertPoll.baseUrl);
    
    const alertStyles = {
        HIGH_TEMP:       { accent: '#dc3545', bg: 'rgba(220,53,69,0.1)',  icon: 'bi-exclamation-triangle-fill', label: 'High Temperature Alert' },
        HUMIDITY:        { accent: '#0d6efd', bg: 'rgba(13,110,253,0.1)', icon: 'bi-droplet-fill',              label: 'Humidity Alert' },
        UPS_OVERLOAD:    { accent: '#fd7e14', bg: 'rgba(253,126,20,0.1)', icon: 'bi-lightning-charge-fill',      label: 'UPS Overload Alert' },
        LOW_BATTERY:     { accent: '#ffc107', bg: 'rgba(255,193,7,0.1)',  icon: 'bi-battery-half',              label: 'Low Battery Alert' },
        MAINTENANCE_DUE: { accent: '#198754', bg: 'rgba(25,135,84,0.1)', icon: 'bi-tools',                     label: 'Maintenance Due' },
        default:         { accent: '#0ea5e9', bg: 'rgba(14,165,233,0.1)', icon: 'bi-info-circle-fill',          label: 'System Alert' }
    };

    function renderAlertCard(data) {
        console.log('🔔 Rendering alert card:', data);
        
        const style = alertStyles[data.type] || alertStyles.default;
        const card = document.createElement('div');
        card.className = 'live-toast-card';
        card.style.setProperty('--toast-accent', style.accent);
        card.style.setProperty('--toast-bg', style.bg);

        const iconWrap = document.createElement('div');
        iconWrap.className = 'live-toast-icon';
        const icon = document.createElement('i');
        icon.className = 'bi ' + style.icon;
        iconWrap.appendChild(icon);

        const body = document.createElement('div');
        body.className = 'live-toast-body';
        
        const titleEl = document.createElement('div');
        titleEl.className = 'live-toast-title';
        titleEl.textContent = style.label;
        
        const msgEl = document.createElement('div');
        msgEl.className = 'live-toast-msg';
        msgEl.textContent = data.message || 'Alert triggered';
        
        const metaEl = document.createElement('div');
        metaEl.className = 'live-toast-meta';
        const metaParts = [];
        if (data.equipmentType) metaParts.push(data.equipmentType);
        if (data.equipmentId) metaParts.push('ID: ' + data.equipmentId);
        if (data.createdAt) metaParts.push(new Date(data.createdAt).toLocaleString());
        metaEl.textContent = metaParts.join(' \u2022 ');
        
        body.append(titleEl, msgEl, metaEl);

        const closeBtn = document.createElement('button');
        closeBtn.className = 'live-toast-close';
        closeBtn.setAttribute('aria-label', 'Close');
        closeBtn.innerHTML = '\u00d7';
        closeBtn.addEventListener('click', function() { card.remove(); });

        card.append(iconWrap, body, closeBtn);
        toastStack.prepend(card);
        
        // Limit to 5 toasts at once
        while (toastStack.childElementCount > 5) {
            toastStack.lastElementChild.remove();
        }
        
        // Auto-remove after 10 seconds
        setTimeout(function() {
            if (card.parentNode) card.remove();
        }, 10000);
    }

    // ---------- SSE (primary real-time channel) ----------
    function startSse() {
        var sseUrl = alertPoll.baseUrl + '/alerts/stream';
        console.log('🔗 Starting SSE connection to:', sseUrl);
        
        try {
            if (window.alertEventSource) {
                window.alertEventSource.close();
                console.log('🔌 Closed existing SSE connection');
            }
            
            var es = new EventSource(sseUrl);
            window.alertEventSource = es;
            
            es.onopen = function() {
                console.log('✅ SSE connection OPENED and ready');
            };
            
            var handler = function(event) {
                console.log('📨 SSE event received:', event.type, event.data);
                if (!event || !event.data) return;
                try {
                    var data = JSON.parse(event.data);
                    if (data && data.id && data.id > alertPoll.lastSeenId) {
                        alertPoll.lastSeenId = data.id;
                        renderAlertCard(data);
                    }
                } catch (e) {
                    console.error('❌ SSE parse error:', e);
                }
            };
            
            // Listen for named 'alert' events
            es.addEventListener('alert', handler);
            
            // Fallback: generic messages
            es.onmessage = function(event) {
                if (event.data && event.data !== 'connected') {
                    handler(event);
                }
            };
            
            es.onerror = function() {
                console.warn('⚠️ SSE error / connection lost, retrying in 5s...');
                es.close();
                setTimeout(startSse, 5000);
            };
        } catch (error) {
            console.error('❌ Failed to start SSE:', error);
            setTimeout(startSse, 5000);
        }
    }

    // ---------- Polling (backup channel) ----------
    function pollLatestAlert() {
        var pollUrl = alertPoll.baseUrl + '/alerts/latest?sinceId=' + alertPoll.lastSeenId;
        
        fetch(pollUrl, { headers: { 'Accept': 'application/json' } })
        .then(function(res) { return res.ok ? res.json() : null; })
        .then(function(data) {
            if (data && data.id && data.id > alertPoll.lastSeenId) {
                alertPoll.lastSeenId = data.id;
                renderAlertCard(data);
            }
        })
        .catch(function(error) {
            console.error('❌ Poll error:', error);
        });
    }

    // ---------- Init ----------
    function initializeAlerts() {
        console.log('🚀 Initializing alert system with context path:', alertPoll.baseUrl);
        
        // Start SSE (primary)
        startSse();
        
        // Start polling as backup every 3 seconds
        setInterval(pollLatestAlert, 3000);
        // Also do one immediate poll
        setTimeout(pollLatestAlert, 500);
    }

    // Expose a manual test helper on the console
    window.testAlert = function() {
        renderAlertCard({
            id: Date.now(),
            type: 'HIGH_TEMP',
            message: 'This is a manual test alert!',
            equipmentType: 'Test',
            equipmentId: '0',
            createdAt: new Date().toISOString()
        });
    };

    // Start when DOM is ready (only once)
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeAlerts);
    } else {
        initializeAlerts();
    }
})();
</script>
