// VoidxV2 Docs - Shared Sidebar & Navbar Component
// Auto-injects proper navbar and sidebar into all pages

// Determine base path based on current location
const isInPages = window.location.pathname.includes('/pages/');
const basePath = isInPages ? '../' : '';

// Navbar HTML template
const navbarHTML = `
<div class="navbar-left">
    <a href="${basePath}index.html" class="logo">
        <img src="${basePath}images/logo.png" alt="VoidxV2" class="logo-img">
    </a>
</div>
<div class="navbar-center">
    <button class="search-btn" onclick="openSearch()">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="11" cy="11" r="8"></circle>
            <path d="m21 21-4.35-4.35"></path>
        </svg>
        <span>Search...</span>
        <kbd>Ctrl K</kbd>
    </button>
</div>
<div class="navbar-right">
    <a href="https://github.com/ijosephyusufk-dev/VoidXV2" target="_blank" class="nav-link">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 0C5.37 0 0 5.37 0 12c0 5.3 3.438 9.8 8.205 11.385.6.113.82-.258.82-.577 0-.285-.01-1.04-.015-2.04-3.338.724-4.042-1.61-4.042-1.61-.546-1.385-1.335-1.755-1.335-1.755-1.087-.744.084-.729.084-.729 1.205.084 1.838 1.236 1.838 1.236 1.07 1.835 2.809 1.305 3.495.998.108-.776.417-1.305.76-1.605-2.665-.3-5.466-1.332-5.466-5.93 0-1.31.465-2.38 1.235-3.22-.135-.303-.54-1.523.105-3.176 0 0 1.005-.322 3.3 1.23.96-.267 1.98-.399 3-.405 1.02.006 2.04.138 3 .405 2.28-1.552 3.285-1.23 3.285-1.23.645 1.653.24 2.873.12 3.176.765.84 1.23 1.91 1.23 3.22 0 4.61-2.805 5.625-5.475 5.92.42.36.81 1.096.81 2.22 0 1.605-.015 2.896-.015 3.286 0 .315.21.69.825.57C20.565 21.795 24 17.295 24 12c0-6.63-5.37-12-12-12z"/>
        </svg>
    </a>
</div>
`;

// Sidebar HTML template
const sidebarHTML = `
<nav class="sidebar-nav">
    <div class="nav-section">
        <a href="${basePath}index.html" class="nav-item" data-page="index">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg></span>
            Welcome
        </a>
    </div>
    
    <div class="nav-section">
        <div class="nav-title">Getting Started</div>
        <a href="${basePath}pages/installation.html" class="nav-item" data-page="installation">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg></span>
            Installation
        </a>
        <a href="${basePath}pages/quick-start.html" class="nav-item" data-page="quick-start">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
            Quick Start
        </a>
    </div>
    
    <div class="nav-section">
        <div class="nav-title">Core Components</div>
        <a href="${basePath}pages/window.html" class="nav-item" data-page="window">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"/><line x1="3" y1="9" x2="21" y2="9"/></svg></span>
            Window
        </a>
        <a href="${basePath}pages/tabs.html" class="nav-item" data-page="tabs">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M4 6h16M4 12h16M4 18h16"/></svg></span>
            Tabs
        </a>
        <a href="${basePath}pages/components.html" class="nav-item" data-page="components">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg></span>
            Components
        </a>
    </div>
    
    <div class="nav-section">
        <div class="nav-title">Developer Utilities</div>
        <a href="${basePath}pages/esp.html" class="nav-item" data-page="esp">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="3"/><path d="M12 1v2M12 21v2M4.22 4.22l1.42 1.42M18.36 18.36l1.42 1.42M1 12h2M21 12h2M4.22 19.78l1.42-1.42M18.36 5.64l1.42-1.42"/></svg></span>
            ESP System
        </a>
        <a href="${basePath}pages/observer.html" class="nav-item" data-page="observer">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg></span>
            Observer
        </a>
        <a href="${basePath}pages/filter.html" class="nav-item" data-page="filter">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg></span>
            Filter
        </a>
        <a href="${basePath}pages/zone.html" class="nav-item" data-page="zone">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg></span>
            Zone
        </a>
    </div>
    
    <div class="nav-section">
        <div class="nav-title">Customization</div>
        <a href="${basePath}pages/themes.html" class="nav-item" data-page="themes">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><circle cx="12" cy="12" r="10"/><path d="M12 2a10 10 0 0 0 0 20 4 4 0 0 1 0-8 4 4 0 0 0 0-8"/></svg></span>
            Themes
        </a>
        <a href="${basePath}pages/state.html" class="nav-item" data-page="state">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/><polyline points="17 21 17 13 7 13 7 21"/><polyline points="7 3 7 8 15 8"/></svg></span>
            State
        </a>
        <a href="${basePath}pages/events.html" class="nav-item" data-page="events">
            <span class="nav-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg></span>
            Events
        </a>
    </div>
</nav>
`;

// Initialize components
function initComponents() {
    // Update navbar
    const navbar = document.querySelector('.navbar');
    if (navbar) {
        navbar.innerHTML = navbarHTML;
    }

    // Update sidebar
    const sidebar = document.querySelector('.sidebar');
    if (sidebar) {
        sidebar.innerHTML = sidebarHTML;

        // Set active page
        const currentPage = window.location.pathname.split('/').pop().replace('.html', '') || 'index';
        const activeItem = sidebar.querySelector(`[data-page="${currentPage}"]`);
        if (activeItem) {
            activeItem.classList.add('active');
        }
    }
}

// Run on DOM load
document.addEventListener('DOMContentLoaded', initComponents);
