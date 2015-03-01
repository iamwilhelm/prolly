# Prolly

**Prolly is a Domain Specific Language (DSL) for expressing probabilities in code.** 
Just like a database has a query language (SQL), this is a query language
specifically for answering questions about probabilities of events based on the
samples you've seen before.

So instead of counting all the events yourself, you just express
probabilities much like how math books express it. Being able to express
probabilities is useful for writing machine learning algorithms at a higher level
of abstraction. The right level abstraction makes things easier to build.

We can now making decisions in code not just based on the current data, like `if`
statements do, but we can make decisions based on the chance of prior data and 
the current data, and that makes for smarter software.

## What can I use this for?

There are examples of using Prolly to write learning algorithms.

- [Decision Tree](https://github.com/iamwilhelm/prolly/tree/master/examples/decision_tree)


## Quick intro

Prolly makes it easy to express probabilities from data. It can also calculate
entropies of random variables as well as the information gain.

Here's how to express Bayes Rule in Prolly:

```
Ps.rv(color: blue).given(size: red).prob * Ps.rv(size: red).prob
  / Ps.rv(color: blue).prob
```

And the above will calculate P(Size=red | Color= blue)

## Installing

Use ruby gems to install

`gem install prolly`

If you use Bundler, just add it to your Gemfile, and then run `bundle install`

## Usage

We first add samples of observable events to be able to estimate the probability of the events we've seen. Then we can query it with Prolly to know the probability of different events.

### Adding samples

Now we add the samples of data that we've observed for the random variable. Presumably, we have a large
enough dataset that we can reasonably estimate each specified RV.

```
require 'prolly'
include Prolly

Ps.add({ color: :blue, size: :small })
Ps.add({ color: :blue, size: :big })
Ps.add({ color: :blue, size: :big })
Ps.add({ color: :green, size: :big })
Ps.add({ color: :green, size: :small })
```

Now that we have samples to estimate our probabilities, we're good to go on how to express them.

>Note that you need you'll need to `include Prolly` into whatever namespace you're using it in, in order to call `Ps.add`. Otherwise, you'll need
to type: `Prolly::Ps.add`, if `Ps` is already taken in your namespace.

### Expressing Stochastics through Probability Space

`Ps` is short for Probability Space. It's normally denoted by &Omega;, U (for universal set), or S (for sample set) in probability textbooks. It's the set of all events that could happen.

You start with probability space.
```
Ps
```
then pick an specified random variable to examine
```
Ps.rv(color: :blue)
```
And if necessary, pick a conditional random variable
```
Ps.rv(color: :blue).given(size: :small)
```
Then pick the operation, where it can be `count`, `prob`, `pdf`, `entropy`, or `infogain`.
```
Ps.rv(color: :blue).given(size: :small).prob
```
And that will give you the probability of the random variable Color is :blue given that the Size was :small. 

### Random Variables and Operations

A random variable can be specified `Ps.rv(:color)` or unspecified `Ps.rv(color: :blue)`. So too can conditional random variables be specified or unspecified. 

Prolly currently supports five operations.

- .prob &middot; Calculates probability, a fractional number representing the belief you have that an event will occur; based on the amount of evidence you've seen for that event.
- .pdf &middot; Calculates probability density function, a hash of all possible probabilities for the random variable. 
- .entropy &middot; Calculates entropy, a fractional number representing the spikiness or smoothness of a density function, which implies how much information is in the random variable.
- .infogain &middot; Calculates information gain, a fractional number representing the amount of information (that is, reduction in uncertainty) that knowing either variable provides about the other.
- .count &middot; Counts the number of events satisfying the conditions.

Each of the operations will only work with certain combinations of random variables. The possibilities are listed below, and Prolly will throw an exception if it's violated. 

Legend:
 - &#10003; available for this operator
 - &Delta;! available, but not yet implemented for this operator.

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
		<th>Ps.rv(color: :blue)</th>
		<th></th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(:size)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(size: :small)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
  <tr>
    <th>Ps.rv(color: [:blue, :green])</th>
    <th></th>
    <th>&#10003;</th>
    <th></th>
    <th></th>
    <th></th>
    <th>&#10003;</th>
  </tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th></th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(:size)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(size: :small)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(color: :blue, texture: :rough)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th>&#10003;</th>
		<th></th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(:size)</th>
		<th></th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(size: :small)</th>
		<th></th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th></th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color)</th>
		<th>.given(:size, weight: :fat)</th>
		<th></th>
		<th></th>
		<th>&#10003;</th>
		<th>&#10003;</th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th></th>
		<th></th>
		<th>&Delta;!</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(:size)</th>
		<th></th>
		<th>&Delta;!</th>
		<th>&Delta;!</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(size: :small)</th>
		<th></th>
		<th>&Delta;!</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(size: :small, weight: :fat)</th>
		<th></th>
		<th>&Delta;!</th>
		<th>&Delta;!</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
	<tr>
		<th>Ps.rv(:color, :texture)</th>
		<th>.given(:size, weight: :fat)</th>
		<th></th>
		<th>&Delta;!</th>
		<th>&#10003;</th>
		<th></th>
		<th>&#10003;</th>
	</tr>
</table>

## Examples

There are examples of using Prolly to write learning algorithms.

- [Decision Tree](https://github.com/iamwilhelm/prolly/tree/master/examples/decision_tree)

### Probabilities

What is the probability there is a blue marble?
```ruby
# P(C = blue)
Ps.rv(color: :blue).prob
```

What is the joint probability there is a blue marble that also has a rough texture?
```ruby
# P(C = blue, T = rough)
Ps.rv(color: :blue, texture: :rough).prob
```

What is the probability a marble is small or med sized?
```ruby
# P(S = small, med)
Ps.rv(size: [:small, :med]).prob
```

What is the probability of a blue marble given that the marble is small?
```ruby
# P(C = blue | S = small)
Ps.rv(color: :blue).given(size: :small).prob
```

What is the probability of a blue marble and rough texture given that the marble is small?
```ruby
# P(C = blue, T = rough | S = small)
Ps.rv(color: :blue, texture: :rough).given(size: :small).prob
```

### Probability density functions

Probability density for a random variable.
```ruby
Ps.rv(:color).pdf
```

Probability density for a conditional random variable.
```ruby
Ps.rv(:color).given(size: :small).pdf
```

### Entropy

Entropy of the RV color.
```ruby
# H(C)
Ps.rv(:color).entropy
```

Entropy of color given the marble is small
```ruby
# H(C | S = small)
Ps.rv(:color).given(size: :small).entropy
```

### Information Gain

Information gain of color and size.
```ruby
# IG(C | S)
Ps.rv(:color).given(:size).infogain
```
### Counts

At the base of all the probabilities are counts of stuff.
```ruby
Ps.rv(color: :blue).count
```

```ruby
Ps.rv(:color).given(:size).count
```

## Stores

Prolly can use different stores to remember the prior event data from which it 
calculates the probability. Currently Prolly implements a RubyList store and a
Mongodb store. 

### Implementing new stores

The interface for a new store is pretty easy. It just needs to implement six methods:

#### initialize

This just brings up the store, and connects to it, and whatever else you need to do in the beginning.

#### reset

This should just clear the entire store of the data in the collection.

#### add(datum)

Adds one row of data to the store.

#### count(rvs, options = {})

Counts the number of samples that satisfy the RVs requested. `rvs` can be either an Array or a Hash. When it's an array, you must count all
samples that have all the RVs. 

When it's a hash, you must look for all samples that not only have the random variables, but also have the matching designated 
values. Note that the values can be an array. When that happens, the user is indicating that it also would like any of the values the RV to match.

#### rand_vars

Return a list of all random variables

#### uniq_vals(name)

Return a list of all uniq values of a random variable.

## Motivation

A couple years back, I was reading [a blog post](http://weblog.raganwald.com/2008/02/naive-approach-to-hiring-people.html) by Raganwald, where I read this quote:

<blockquote>
A very senior Microsoft developer who moved to Google told me that Google works and thinks at a higher level of abstraction than Microsoft. “Google uses Bayesian filtering the way Microsoft uses the if statement,” he said.

—Joel Spolsky, Microsoft Jet
</blockquote>

That got me thinking very literally. What would it look like if we have probability 
statements to use natively like we have "if" statements? How would that change how 
we code? That would mean we could make decisions not just on the information we 
have on hand, but the prior information we saw before.

## Contributing

Write some specs, make sure the entire thing passes. Then submit a pull request.

## Contributors

- Wil Chung 

## License

MIT license

## Changelog

### v0.0.1

- Initial release with counts, probs, pdf, entropy, and infogain.
- implements two stores, RubyList and Mongodb
