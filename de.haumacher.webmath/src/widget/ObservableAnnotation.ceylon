import ceylon.language.meta.declaration {
	ValueDeclaration
}

shared final annotation class ObservableAnnotation() satisfies OptionalAnnotation<ObservableAnnotation, ValueDeclaration> {
	
}

"Annotation marking a member that can be observed using the [[PropertyObservable]] API."
shared annotation ObservableAnnotation observable() => ObservableAnnotation();
