/**
 * Date Helper Utilities
 * Works with YYYY-MM-DD date keys and local dates reliably
 */

function formatDateKey(date) {
  const d = new Date(date);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

function parseDateKey(dateKey) {
  const [year, month, day] = dateKey.split('-').map(Number);
  return new Date(year, month - 1, day);
}

function addDays(date, days) {
  const result = new Date(date);
  result.setDate(result.getDate() + days);
  return result;
}

/**
 * Returns weekday index: 1 = Monday, 2 = Tuesday, ..., 7 = Sunday
 */
function getWeekdayIndex(date) {
  const day = new Date(date).getDay();
  return day === 0 ? 7 : day;
}

/**
 * Check if a habit was scheduled on a given dateKey
 */
function isHabitScheduledOnDate(habit, dateKey) {
  const targetDate = parseDateKey(dateKey);
  const habitStart = new Date(habit.startDate);
  habitStart.setHours(0, 0, 0, 0);
  
  const compDate = new Date(targetDate);
  compDate.setHours(0, 0, 0, 0);

  if (compDate < habitStart) {
    return false;
  }

  if (habit.endDate) {
    const habitEnd = new Date(habit.endDate);
    habitEnd.setHours(23, 59, 59, 999);
    if (compDate > habitEnd) {
      return false;
    }
  }

  if (habit.frequency === 'every_day') {
    return true;
  }

  if (habit.frequency === 'selected_weekdays' && Array.isArray(habit.selectedWeekdays)) {
    const weekday = getWeekdayIndex(targetDate);
    return habit.selectedWeekdays.includes(weekday);
  }

  return true;
}

module.exports = {
  formatDateKey,
  parseDateKey,
  addDays,
  getWeekdayIndex,
  isHabitScheduledOnDate,
};
