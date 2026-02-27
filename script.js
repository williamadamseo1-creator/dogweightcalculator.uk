const KG_TO_LB = 2.2046226218;

const growthCurves = {
  small: [
    [8, 0.25], [12, 0.4], [16, 0.55], [20, 0.7], [24, 0.82], [32, 0.95], [52, 1.0]
  ],
  medium: [
    [8, 0.18], [12, 0.3], [16, 0.43], [20, 0.55], [24, 0.66], [32, 0.82], [40, 0.93], [60, 1.0]
  ],
  large: [
    [8, 0.13], [12, 0.22], [16, 0.32], [20, 0.42], [24, 0.52], [32, 0.67], [40, 0.79], [52, 0.9], [72, 1.0]
  ],
  giant: [
    [8, 0.1], [12, 0.18], [16, 0.26], [20, 0.34], [24, 0.42], [32, 0.55], [40, 0.66], [52, 0.78], [72, 0.9], [96, 1.0]
  ]
};

const form = document.getElementById("dogForm");
const result = document.getElementById("result");
const year = document.getElementById("year");

year.textContent = new Date().getFullYear();

function clamp(value, min, max) {
  return Math.min(Math.max(value, min), max);
}

function interpolateFraction(ageWeeks, sizeClass) {
  const points = growthCurves[sizeClass];
  if (!points) return null;

  if (ageWeeks <= points[0][0]) return points[0][1];
  if (ageWeeks >= points[points.length - 1][0]) return points[points.length - 1][1];

  for (let i = 0; i < points.length - 1; i += 1) {
    const [w1, f1] = points[i];
    const [w2, f2] = points[i + 1];
    if (ageWeeks >= w1 && ageWeeks <= w2) {
      const ratio = (ageWeeks - w1) / (w2 - w1);
      return f1 + ratio * (f2 - f1);
    }
  }
  return null;
}

function getVariance(ageWeeks) {
  if (ageWeeks < 10 || ageWeeks > 72) return 0.18;
  if (ageWeeks < 16 || ageWeeks > 56) return 0.14;
  return 0.1;
}

function formatNumber(value) {
  return Number.parseFloat(value).toFixed(1);
}

function renderMessage(type, html) {
  result.classList.remove("result-good", "result-warn");
  if (type === "good") result.classList.add("result-good");
  if (type === "warn") result.classList.add("result-warn");
  result.innerHTML = html;
}

form.addEventListener("submit", (event) => {
  event.preventDefault();

  const unit = document.getElementById("unit").value;
  const weightInput = Number.parseFloat(document.getElementById("weight").value);
  const ageValue = Number.parseFloat(document.getElementById("ageValue").value);
  const ageUnit = document.getElementById("ageUnit").value;
  const sizeClass = document.getElementById("sizeClass").value;

  if (!Number.isFinite(weightInput) || !Number.isFinite(ageValue) || weightInput <= 0 || ageValue <= 0) {
    renderMessage("warn", "<p><strong>Check your inputs.</strong> Enter positive numbers for weight and age.</p>");
    return;
  }

  const ageWeeks = ageUnit === "months" ? ageValue * 4.345 : ageValue;
  if (ageWeeks < 6) {
    renderMessage("warn", "<p><strong>Too early for a reliable estimate.</strong> Try again when your puppy is at least 6-8 weeks old.</p>");
    return;
  }

  const weightKg = unit === "kg" ? weightInput : weightInput / KG_TO_LB;
  const fraction = interpolateFraction(ageWeeks, sizeClass);
  if (!fraction || fraction <= 0) {
    renderMessage("warn", "<p>Could not calculate estimate. Please check your selections.</p>");
    return;
  }

  const adultKgRaw = weightKg / fraction;
  const adultKg = clamp(adultKgRaw, 1.2, 120);
  const variance = getVariance(ageWeeks);
  const lowKg = adultKg * (1 - variance);
  const highKg = adultKg * (1 + variance);
  const midLb = adultKg * KG_TO_LB;
  const lowLb = lowKg * KG_TO_LB;
  const highLb = highKg * KG_TO_LB;

  const confidence = variance <= 0.1 ? "Higher confidence window" : "Lower confidence window";
  const confidenceText = variance <= 0.1
    ? "Your puppy age is in a strong prediction range."
    : "Age is outside peak prediction range, so variance is wider.";

  renderMessage(
    "good",
    `
      <p><strong>Estimated Adult Weight:</strong></p>
      <p><strong>${formatNumber(lowKg)}-${formatNumber(highKg)} kg</strong> (${formatNumber(lowLb)}-${formatNumber(highLb)} lb)</p>
      <p>Most likely midpoint: <strong>${formatNumber(adultKg)} kg</strong> (${formatNumber(midLb)} lb)</p>
      <p><strong>${confidence}</strong>: ${confidenceText}</p>
    `
  );
});
