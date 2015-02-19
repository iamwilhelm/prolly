# Prolly

**Prolly makes writing machine learning algorithms easier.** It's a Domain Specific Language (DSL) for expressing probabilities in code. By being able to express probabilities is useful.

## Quick intro

Prolly makes it easy to express probabilities from data. It can also calculate entropies of random variables 
as well as the information gain.

Here's how to express Bayes Rule in Prolly:

```
Ps.rv(color: blue).given(size: red).prob * Ps.rv(size: red).prob / Ps.rv(color: blue).prob
```

And the above will calculate P(Size=red | color= blue)

## Installing

`gem install prolly`

## Usage

Say you have a jar with green and blue marbles, and the sizes can be big or small. 

### Adding samples

Now we add the samples of data that we've observed for the random variable. Presumably, we have a large
enough dataset that we can reasonably estimate each RV using the Central limit theorem.

```
Ps.add({ color: :blue, size: :small })
Ps.add({ color: :blue, size: :big })
Ps.add({ color: :blue, size: :big })
Ps.add({ color: :green, size: :big })
Ps.add({ color: :green, size: :small })
```

Now that we have samples to estimate our probabilities, we're good to go on how to express them.

### Expressing Stochastics through Probability Space

`Ps` is short for Probability Space. It's normally denoted by &Omega;, U (for universal set), or S (for sample set) in probability textbooks. It's the set of all events that could happen.

You start with probability space.
```
Ps
```
then pick the random variable you want to examine
```
Ps.rv(:color)
```
We can also use specified random variable to examine
```
Ps.rv(color: :blue)
```
And if necessary, pick the conditional random variable
```
Ps.rv(color: :blue).given(size: :small)
```
Then pick the operation, where it can be `prob`, `entropy`, or `infogain`.
```
Ps.rv(color: :blue).given(size: :small).prob
```
And that will give you the probability of the random variable Color is :blue given that the Size was :small. 

Each of the operations will only work with certain combinations of random variables, specific or not. The possibilities are listed below, and Prolly will throw an exception if it's violated. Checkmark means it's a valid operation given the random variable construction. The colors indicate whether it's been implemented or not.

<table>
	<tr>
		<th>RandVar</th>
		<th>Given</th>
		<th>.prob</th>
		<th>.pdf</th>
		<th>.entropy</th>
		<th>.infogain</th>
		<th>.count</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th/>
		<th/>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th/>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(:size)</th>
		<th/>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(size: :small)</th>
		<th></th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th></th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(:size, weight: :fat)</th>
		<th></th>
		<th></th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th></th>
		<th></th>
		<th style="background-color: indianred">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(:size)</th>
		<th></th>
		<th style="background-color: indianred">&#10003;</th>
		<th style="background-color: indianred">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(size: :small)</th>
		<th></th>
		<th style="background-color: indianred">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th></th>
		<th style="background-color: indianred">&#10003;</th>
		<th style="background-color: indianred">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(:size, weight: :fat)</th>
		<th></th>
		<th style="background-color: indianred">&#10003;</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th></th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(:size)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(size: :small)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th></th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(:size)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(size: :small)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th style="background-color: yellowgreen">&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th></th>
	</tr>
</table>

### Probabilities

What is the probability there is a blue marble?
```
# P(C = blue)
Ps.rv(color: :blue).prob
```

What is the joint probability there is a blue marble that also has a rough texture?
```
# P(C = blue, T = rough)
Ps.rv(color: :blue, texture: :rough).prob
```

What is the probability of a blue marble given that the marble is small?
```
# P(C = blue | S = small)
Ps.rv(color: :blue).given(size: :small).prob
```

What is the probability of a blue marble and rough texture given that the marble is small?
```
# P(C = blue, T = rough | S = small)
Ps.rv(color: :blue, texture: :rough).given(size: :small).prob
```

What is the probability of 

### Probability densities

Probability density for a random variable.
```
Ps.rv(:color).prob
```

Probability density for a conditional random variable.
```
Ps.rv(:color).given(size: :small).prob
```

### Entropy of color given size is small

Entropy of a random variable is pretty easy too.

```
# H(C)
Ps.rv(:color).entropy
```

```
# H(C | S = small)
Ps.rv(:color).given(size: :small).entropy
```

### Information Gain of color given size

```
# IG(C | S)
Ps.rv(:color).given(:size).infogain
```
### Counts

At the base of all the probabilities are counts of stuff.

```
Ps.rv(color: :blue).count
```

## Contributing

## Contributors

## License

MIT license
