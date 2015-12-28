Boolean randomBoolean(Float probability) {
	return randomUnit() < probability;
}

Integer randomInt(Integer limit) {
	return (randomUnit() * limit).integer;
}

Integer randomRange(Integer min, Integer max) {
	return min + (randomUnit() * (max - min + 1)).integer;
}

Float randomUnit() {
	Float rnd;
	dynamic {
		rnd = Math.random();
	}
	return rnd;
}
