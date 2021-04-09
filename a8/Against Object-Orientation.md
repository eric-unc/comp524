# Against Object-Orientation
The great computer scientists of the past created entire operating systems without it. The great minds behind the moon landing [did not need it either](https://github.com/chrislgarry/Apollo-11). Yet, today's so-called 'programmers' cannot even make a basic web app without it. Object-orientation is lauded as the building blocks of computer science, but the truth is, it is merely the opium of the people.

## Primer: the Principles of Object-Orientation
Object-orientation is generally defined around 4 principles:
1. **Encapsulation**. Encapsulation is concerned with the restricting of data, usually through the creation of getter-setter methods to manipulate fields.
2. **Abstraction**. Abstraction is concerned with the hiding of complexity, and in object-oriented programming, the division of units of meaning into classes.
3. **Inheritance**. Inheritance is concerned with expressing abstractions in terms of the relationships with each other, especially in terms of "parent-child" or "is-a" relations.
4. **Polymorphism**. Polymorphism is concerned with the morphing of various forms.

While these principles are not inherently bad, object-orientation does not always achieve them well or its achievement ends up being bad.

## Problems of Encapsulation
Encapsulation, which advocates the hiding of data implementation for the purpose of abstraction, is perhaps the weakest link of object-oriented programming. This, in itself, is not bad, but encapsulation's manifestation in object-oriented code has usually resulted in code that is highly redundant at best, and embarrassing at worst.

_Effective Java_ (Addison-Wesley, 2017, pg 78) states that "public classes should never expose mutable fields" and that "it is less harmful, though still questionable, for public classes to expose immutable fields". Addison-Wesley gives this example of a "degenerate" class:
```java
class Point {
	public double x;
	public double y;
}
```

Addison-Wesley considers this class to be "anathema," and proposes it be changed to the following in order to reflect object-oriented principles:
```java
class Point {
	private double x;
	private double y;

	public double getX(){ return x; }
	public double getY(){ return y; }

	public void setX(double x){ this.x = x; }
	public void setY(double y){ this.y = y; }
}
```

Addison-Wesley notes that, with the first example, "you can't change the representation without changing the API, you can't enforce invariants, and you can’t take auxiliary action when a field is accessed". However, in the transformation of `Point` to a more object-oriented paradigm, none of these possible "benefits" of encapsulation are shown. In the second example, the API still must be changed if the representation is, no invariants are enforced, and no auxiliary action is taken for field accesses! In this example, _there is absolutely no benefit in using encapsulation_. The author is merely conforming to object-oriented ideology for the sake of conformity.

Not only is this juvenile principle-based masturbation useless, it can be argued that it is even harmful. The first example is obviously clearer and cleaner than the second, and the resulting boilerplate from the transformation is highly wasteful. Some languages do make some effort to reduce this boilerplate, such as in C#:
```csharp
class Point {
	public double x { get; set; }
	public double y { get; set; }
}
```

Here, with this special declaration, C# labels `x` and `y` not as fields, but as "properties", and in doing so, C# allows them to be treated as fields. But for what? This is extremely infantile, the above example will function _exactly the same_ if they _simply are fields_:
```csharp
class Point {
	public double x;
	public double y;
}
```

It is clear the defensiveness of this irrational complexity has only come from psychological repression of programming language designers. The ego correctly desires an escape from this madness, but the superego merely moderates this obsession with encapsulation into what we may call encapsulation-without-encapsulation, as seen above, whereby designers suffering from cognitive dissonance attempt to avoid encapsulation as far as one can while still operating within it as framework.

## Problems of Abstraction
Abstraction is fine, really.

## References
1. https://medium.com/@cancerian0684/what-are-four-basic-principles-of-object-oriented-programming-645af8b43727
2. https://www.kea.nu/files/textbooks/new/Effective%20Java%20%282017%2C%20Addison-Wesley%29.pdf
