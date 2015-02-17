# Prolly

**Prolly makes writing machine learning algorithms easier.** Prolly is a Domain Specific Language (DSL) for expressing probabilities in code.

## Quick intro

Prolly makes it easy to express probabilities from data. It can also calculate entropies of random variables 
as well as the information gain.

Say you have a jar with green and blue marbles, and the sizes can be big or small. How do you express
the probabilities of drawing different scenarios out of a jar?

### Probability that the color is blue
```
# P(C = blue)
Ps.rv(color: :blue).prob
```

### Probability that the color is blue given the size is small
```
# P(C = blue | S = small)
Ps.rv(color: :blue).given(size: :small).prob
```

### Entropy of color given size is small
```
# H(C | S = small)
Ps.rv(:color).given(size: :small).entropy
```

### Information Gain of color given size
```
# IG(C | S)
Ps.rv(:color).given(:size).infogain
```


