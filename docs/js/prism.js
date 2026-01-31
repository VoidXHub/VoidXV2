/* Simple Lua Syntax Highlighter */
(function () {
    function highlightLua(code) {
        const keywords = ['local', 'function', 'end', 'if', 'then', 'else', 'elseif', 'for', 'while', 'do', 'repeat', 'until', 'return', 'break', 'in', 'and', 'or', 'not', 'true', 'false', 'nil'];
        const builtins = ['print', 'pairs', 'ipairs', 'tostring', 'tonumber', 'type', 'table', 'string', 'math', 'task', 'wait', 'spawn', 'game', 'workspace', 'Instance'];

        // Escape HTML
        code = code.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

        // Strings
        code = code.replace(/"([^"\\]|\\.)*"/g, '<span class="token string">$&</span>');
        code = code.replace(/'([^'\\]|\\.)*'/g, '<span class="token string">$&</span>');

        // Comments
        code = code.replace(/--\[\[[\s\S]*?\]\]/g, '<span class="token comment">$&</span>');
        code = code.replace(/--[^\n]*/g, '<span class="token comment">$&</span>');

        // Numbers
        code = code.replace(/\b(\d+\.?\d*)\b/g, '<span class="token number">$1</span>');

        // Keywords
        keywords.forEach(kw => {
            const regex = new RegExp('\\b(' + kw + ')\\b', 'g');
            code = code.replace(regex, '<span class="token keyword">$1</span>');
        });

        // Builtins
        builtins.forEach(fn => {
            const regex = new RegExp('\\b(' + fn + ')\\b', 'g');
            code = code.replace(regex, '<span class="token function">$1</span>');
        });

        // Functions (word followed by parenthesis)
        code = code.replace(/(\w+)(\s*\()/g, '<span class="token function">$1</span>$2');

        return code;
    }

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('code.language-lua').forEach(block => {
            block.innerHTML = highlightLua(block.textContent);
        });
    });
})();
