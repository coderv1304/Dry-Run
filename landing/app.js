// Dry Run landing page. Copy comes from content.json; strings are never built by hand.

document.addEventListener('DOMContentLoaded', function () {
  fetch('content.json')
    .then(function (response) {
      return response.json();
    })
    .then(function (content) {
      document.getElementById('disclaimer-banner').textContent = content.disclaimer;
      document.getElementById('hero-headline').textContent = content.hero.headline;
      document.getElementById('hero-subheadline').textContent = content.hero.subheadline;
      document.getElementById('btn-try').textContent = content.hero.cta_try;
      document.getElementById('btn-invite').textContent = content.hero.cta_invite;

      document.getElementById('how-headline').textContent = content.how_it_works.headline;
      var steps = document.getElementById('how-steps');
      content.how_it_works.steps.forEach(function (step) {
        var item = document.createElement('li');
        item.className = 'list-item';

        var title = document.createElement('h3');
        title.className = 'title-3 list-title';

        var number = document.createElement('span');
        number.className = 'step-number caption-1';
        number.textContent = step.number + '.';
        title.appendChild(number);
        title.appendChild(document.createTextNode(step.title));

        var detail = document.createElement('p');
        detail.className = 'body-6 list-detail';
        detail.textContent = step.description;

        item.appendChild(title);
        item.appendChild(detail);
        steps.appendChild(item);
      });

      document.getElementById('habits-headline').textContent = content.habits.headline;
      var habits = document.getElementById('habits-items');
      content.habits.items.forEach(function (habit) {
        var item = document.createElement('li');
        item.className = 'list-item';

        var title = document.createElement('h3');
        title.className = 'title-3 list-title';
        title.textContent = habit.title;

        var detail = document.createElement('p');
        detail.className = 'body-6 list-detail';
        detail.textContent = habit.description;

        item.appendChild(title);
        item.appendChild(detail);
        habits.appendChild(item);
      });

      document.getElementById('footer-notice').textContent = content.footer.notice;
    })
    .catch(function () {
      var banner = document.getElementById('disclaimer-banner');
      banner.textContent = 'Copy could not load. Reload the page to try again.';
    });
});
