/* Dry Run landing behaviour: the tagline reveal, and nothing else.
   Words reach full colour one at a time as they enter the viewport.
   With reduced motion, or without IntersectionObserver, the copy is static. */

(function () {
  'use strict';

  var tagline = document.querySelector('.tagline');
  if (!tagline) {
    return;
  }

  var words = Array.prototype.slice.call(tagline.querySelectorAll('.word'));
  var reduced = window.matchMedia('(prefers-reduced-motion: reduce)');

  function showEverything() {
    tagline.classList.remove('reveal-armed');
    words.forEach(function (word) {
      word.classList.add('is-on');
    });
  }

  if (!words.length) {
    return;
  }

  if (reduced.matches || !('IntersectionObserver' in window)) {
    showEverything();
    return;
  }

  tagline.classList.add('reveal-armed');

  var observer = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) {
          return;
        }
        entry.target.classList.add('is-on');
        observer.unobserve(entry.target);
      });
    },
    { rootMargin: '0px 0px -30% 0px', threshold: 0 }
  );

  words.forEach(function (word) {
    observer.observe(word);
  });

  reduced.addEventListener('change', function (event) {
    if (event.matches) {
      observer.disconnect();
      showEverything();
    }
  });
})();
