document.addEventListener('DOMContentLoaded', function() {
  fetch('/api/timetable')
      .then(response => response.json())
      .then(data => {
          const container = document.getElementById('timetable');
          // Render timetable here
          console.log(data); // For debugging
      })
      .catch(error => console.error('Error:', error));
});