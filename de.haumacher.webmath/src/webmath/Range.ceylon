shared class Range(shared Integer min, shared Integer max) {
	shared Boolean contains(Integer val) => val >= min && val <= max;
	shared Integer randomValue() => randomRange(min, max);
}