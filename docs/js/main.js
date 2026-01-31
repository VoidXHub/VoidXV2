// VoidxV2 Documentation - Main JavaScript

// Search Modal
function openSearch() {
    document.getElementById('searchModal').classList.add('open');
    document.querySelector('.search-input').focus();
}

function closeSearch() {
    document.getElementById('searchModal').classList.remove('open');
}

// Keyboard shortcut for search
document.addEventListener('keydown', function (e) {
    if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
        e.preventDefault();
        openSearch();
    }
    if (e.key === 'Escape') {
        closeSearch();
    }
});

// Close search when clicking outside
document.getElementById('searchModal')?.addEventListener('click', function (e) {
    if (e.target === this) {
        closeSearch();
    }
});

// Active navigation item
function setActiveNav() {
    const currentPath = window.location.pathname;
    document.querySelectorAll('.nav-item').forEach(item => {
        const href = item.getAttribute('href');
        if (href && currentPath.includes(href.replace('../', '').replace('.html', ''))) {
            item.classList.add('active');
        } else if (currentPath.endsWith('/') || currentPath.endsWith('index.html')) {
            if (href === 'index.html' || href === '../index.html') {
                item.classList.add('active');
            }
        }
    });
}

// Table of Contents - Active section tracking
function initTOC() {
    const headings = document.querySelectorAll('h2[id], h3[id]');
    const tocLinks = document.querySelectorAll('.toc-link');

    if (headings.length === 0 || tocLinks.length === 0) return;

    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                tocLinks.forEach(link => link.classList.remove('active'));
                const activeLink = document.querySelector(`.toc-link[href="#${entry.target.id}"]`);
                if (activeLink) activeLink.classList.add('active');
            }
        });
    }, { rootMargin: '-20% 0px -80% 0px' });

    headings.forEach(heading => observer.observe(heading));
}

// Mobile sidebar toggle
function toggleSidebar() {
    document.querySelector('.sidebar').classList.toggle('open');
}

// Copy code button
function initCodeCopy() {
    document.querySelectorAll('pre').forEach(pre => {
        const button = document.createElement('button');
        button.className = 'copy-btn';
        button.innerHTML = '📋 Copy';
        button.onclick = async function () {
            const code = pre.querySelector('code').textContent;
            await navigator.clipboard.writeText(code);
            button.innerHTML = '✅ Copied!';
            setTimeout(() => button.innerHTML = '📋 Copy', 2000);
        };
        pre.style.position = 'relative';
        pre.appendChild(button);
    });
}

// Add copy button styles
const style = document.createElement('style');
style.textContent = `
    .copy-btn {
        position: absolute;
        top: 8px;
        right: 8px;
        padding: 6px 12px;
        background: var(--bg-input);
        border: 1px solid var(--border);
        border-radius: 6px;
        color: var(--text-secondary);
        font-size: 12px;
        cursor: pointer;
        opacity: 0;
        transition: all 0.2s;
    }
    pre:hover .copy-btn {
        opacity: 1;
    }
    .copy-btn:hover {
        background: var(--accent);
        color: white;
    }
`;
document.head.appendChild(style);

// Search functionality
const searchData = [
    { title: 'Welcome', url: 'index.html', category: 'Home', keywords: 'home landing main start' },
    { title: 'Installation', url: 'pages/installation.html', category: 'Getting Started', keywords: 'setup install loadstring' },
    { title: 'Quick Start', url: 'pages/quick-start.html', category: 'Getting Started', keywords: 'tutorial guide example first script' },
    { title: 'CreateWindow', url: 'pages/window.html', category: 'Core', keywords: 'ui gui window form main' },
    { title: 'CreateTab', url: 'pages/tabs.html', category: 'Core', keywords: 'tab page section category' },
    { title: 'Components', url: 'pages/components.html', category: 'Core', keywords: 'button toggle slider dropdown input colorpicker keybind label paragraph section' },
    { title: 'ESP System', url: 'pages/esp.html', category: 'Developer', keywords: 'visual wallhack box tracer skeleton chams shadow highlight' },
    { title: 'Observer', url: 'pages/observer.html', category: 'Developer', keywords: 'event listener player character spawn die tool' },
    { title: 'Filter', url: 'pages/filter.html', category: 'Developer', keywords: 'target selection distance team check alive enemy' },
    { title: 'Zone', url: 'pages/zone.html', category: 'Developer', keywords: 'region area safezone enter exit detection' },
    { title: 'Themes', url: 'pages/themes.html', category: 'Customization', keywords: 'color style custom aesthetic dark mode' },
    { title: 'State Management', url: 'pages/state.html', category: 'Customization', keywords: 'save load config settings auto flag' },
    { title: 'Events', url: 'pages/events.html', category: 'Customization', keywords: 'callback onchange onunload toggle bind' },
];

function initSearch() {
    const input = document.querySelector('.search-input');
    const results = document.querySelector('.search-results');

    if (!input || !results) return;

    input.addEventListener('input', function () {
        const query = this.value.toLowerCase();

        if (query.length < 2) {
            results.innerHTML = '<p style="padding: 20px; color: var(--text-muted);">Type to search...</p>';
            return;
        }

        const matches = searchData.filter(item =>
            item.title.toLowerCase().includes(query) ||
            item.category.toLowerCase().includes(query) ||
            (item.keywords && item.keywords.toLowerCase().includes(query))
        );

        if (matches.length === 0) {
            results.innerHTML = '<p style="padding: 20px; color: var(--text-muted);">No results found</p>';
            return;
        }

        results.innerHTML = matches.map(item => `
            <a href="${item.url}" class="search-result-item" style="
                display: flex;
                flex-direction: column;
                padding: 12px;
                border-radius: 6px;
                text-decoration: none;
                color: inherit;
                transition: background 0.2s;
            " onmouseover="this.style.background='var(--bg-card-hover)'" onmouseout="this.style.background='transparent'">
                <span style="font-weight: 500; color: var(--text-primary);">${item.title}</span>
                <span style="font-size: 12px; color: var(--text-muted);">${item.category}</span>
            </a>
        `).join('');
    });
}

// Initialize
document.addEventListener('DOMContentLoaded', function () {
    setActiveNav();
    initTOC();
    initCodeCopy();
    initSearch();
});
