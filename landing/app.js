// Dry Run Landing Page Plain JS

document.addEventListener('DOMContentLoaded', function () {
  fetch('content.json')
    .then(function (res) {
      return res.json();
    })
    .then(function (content) {
      document.getElementById('disclaimer-banner').textContent = content.disclaimer;
      document.getElementById('hero-headline').textContent = content.hero.headline;
      document.getElementById('hero-subheadline').textContent = content.hero.subheadline;
      document.getElementById('btn-try').textContent = content.hero.cta_try;
      document.getElementById('btn-invite').textContent = content.hero.cta_invite;

      document.getElementById('facts-headline').textContent = content.facts.headline;
      document.getElementById('stat-value').textContent = content.facts.stat_value;
      document.getElementById('stat-label').textContent = content.facts.stat_label;

      document.getElementById('how-headline').textContent = content.how_it_works.headline;
      var stepsContainer = document.getElementById('how-steps');
      content.how_it_works.steps.forEach(function (step) {
        var el = document.createElement('div');
        el.className = 'list-item';
        el.innerHTML = '<h3><span class="step-number">' + step.number + '.</span> ' + step.title + '</h3><p>' + step.description + '</p>';
        stepsContainer.appendChild(el);
      });

      document.getElementById('habits-headline').textContent = content.habits.headline;
      var habitsContainer = document.getElementById('habits-items');
      content.habits.items.forEach(function (habit) {
        var el = document.createElement('div');
        el.className = 'list-item';
        el.innerHTML = '<h3>' + habit.title + '</h3><p>' + habit.description + '</p>';
        habitsContainer.appendChild(el);
      });

      document.getElementById('footer-notice').textContent = content.footer.notice;
    })
    .catch(function (err) {
      console.error('Failed to load content.json:', err);
    });
});
