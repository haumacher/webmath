shared class Range(shared variable Integer min, variable shared Integer max) {
	shared Boolean contains(Integer val) => val >= min && val <= max;
	shared Integer randomValue() => randomRange(min, max);
}