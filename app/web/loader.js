// Removes the pre-Flutter loading shell once Flutter paints its first frame.
//
// It lives in its own file because the deployed CSP allows only same-origin
// scripts (script-src 'self') and blocks inline script. The Flutter engine
// dispatches "flutter-first-frame" on window; a MutationObserver on the Flutter
// view is the fallback for engines that do not dispatch the event.
(function () {
  var removed = false;

  function removeShell() {
    if (removed) {
      return;
    }
    removed = true;
    var shell = document.getElementById('dr-loading');
    if (shell && shell.parentNode) {
      shell.parentNode.removeChild(shell);
    }
  }

  window.addEventListener('flutter-first-frame', removeShell, { once: true });

  var observer = new MutationObserver(function () {
    if (document.querySelector('flt-glass-pane')) {
      window.requestAnimationFrame(removeShell);
    }
  });
  observer.observe(document.body, { childList: true, subtree: true });
})();
