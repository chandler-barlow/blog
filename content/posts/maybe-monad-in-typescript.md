---
author: Chandler Barlow
tags: [monads,typescript,javascript, functional programming]
title: "Bringing the Maybe Monad to Typescript"
description: "Implementing the Maybe monad in typescript for fun."
showTableOfContents: true
type: "post"
date: 2023-05-12
---

Hello! In this blog post I am going to be showing an example of how to implement the Maybe Monad in Typescript. It seems tremendously common for anyone learning functional programming to write their own version of an "Explaining Monads" blog post. I am glad to keep up the tradition.  

### Why worry about a Maybe type in the first place?
Good question! The day to day work of a web developer requires handling all kinds of values that may, or may not exist. Using a consistent unambiguous pattern for handling these potentially missing values is incredibly helpful. It not only makes your code easier to read, but less prone to errors as well.

Without further adieu, let's get into it.

#### The Maybe type
The Maybe type is actually rather simple. It is either a value of type T or nothing. Nothing being either `null` or `undefined` in Javascript land.  

Here's the Maybe type definition.

```typescript
type Maybe<T> = T | undefined | null;
```

This type helps with defining values in code that are potentially missing. For instance, imagine we receive a list of drinks from a server. The list of drinks contains `Drink` objects which contain fields `name`, `color`, and `caffieneContent` ( which may or may not be included based on the drink ). Let's build a function that looks up a drink by `name` and prints the `caffeineContent` value if it exists using the Maybe type.

```typescript
type Drink = {
  name: string;
  color: string;
  caffieneContent: Maybe<number>;
};

const drinks: Drink[] = [
  {
    name: "coffee",
    color: "black",
    caffeineContent: 79
  },
  {
    name: "sprite",
    color: "clear",
    caffeineContent: null
  }
];

function lookupCaffeineCont(name: string, drinks: Drink[]): Maybe<number> {
  const drink: Maybe<Drink> = drinks.find((drink) => drink.name === name);
  if(drink !== undefined && drink !== null){
    if(drink.caffieneContent !== undefined && drink.caffieneContent !== null){
      return drink.caffieneContent;
    }
    return null;
  }
  return null;
}
```
## Unwrapping the Maybe type

In this example the `Maybe` type saves us time by not forcing us to explicitly type each potentially missing value. At each step we have to handle each `Maybe` value before moving on. These if statements are kind of messy. To help clean this up we can use a helper function `exists`.

```typescript
function exists<T>(val: T): val is Exclude<T, null | undefined> {
  return val !== undefined && val !== null;
}
```
We can then refactor the previous example.  
*Note: It is possible to combine both if statements into a single statement, but I want each step to be discernible. This will help with understanding what the Maybe Monad is abstracting away.*

```typescript
type Drink = {
  name: string;
  color: string;
  caffieneContent: Maybe<number>;
};

const drinks: Drink[] = [
  {
    name: "coffee",
    color: "black",
    caffeineContent: 79
  },
  {
    name: "sprite",
    color: "clear",
    caffeineContent: null
  }
];

function lookupCaffeineCont(name: string, drinks: Drink[]): Maybe<number> {
  const drink: Maybe<Drink> = drinks.find((drink) => drink.name === name);
  if(exists(drink)){
    if(exists(drink.caffieneContent)){
      return drink.caffieneContent;
    }
    return null;
  }
  return null;
}
```

This is quite cumbersome and annoying to deal with though. This tactic require wrapping every resulting value in a Maybe type, un-boxing it, using the un-boxed value, and then repeating.

### The Monad ( Abstracting away unwrapping and re-wrapping Maybe )

It turns out that a Monad is actually exactly what we need to abstract away all of this annoying un-boxing stuff.

The Maybe Monad includes four functions.

*map*: This unwraps the `MaybeM` type, injects it into a function `T -> R` and wraps it into a `MaybeM` type on return. If the inner value is `Nothing` then it just immediately returns `Nothing`.

*fMap:* This function takes a function of type `T -> MaybeM<R>`. It un-boxes the internal value of MaybeM and injects the un-boxed value into the given function if the internal value is defined. If the internal value is undefined fMap just returns `MaybeM.none()`. None being a valid member of `MaybeM<R>`.

*lift:* This function takes some value of type T and returns `Maybe<T>`.

*unwrap*: This just unwraps the inner value. Generally Monads don't provide a function to do this, but `unwrap` makes using the monad in Typescript easier.

### The Implementation

```typescript
class MaybeM<T> {
  val: Maybe<T>;
  constructor(value: Maybe<T>) {
    this.val = value;
  }
  static lift<T>(value: Maybe<T>){
    if(exists(value)){
      return new MaybeM<T>(value);
    }
    return new MaybeM<T>(null);
  }
  static some<R>(value: R){
    return MaybeM.lift<R>(value);
  }
  static none<R>(){
    return MaybeM.lift<R>(null);
  }
  fMap<R>(fn: (arg: T) => MaybeM<R>): MaybeM<R> {
    if(exists(this.val)){
      return fn(this.val);
    }
    return MaybeM.none<R>();
  }
  map<R>(fn: (arg: T) => R): MaybeM<R> {
    if(exists(this.val)){
      return MaybeM.some<R>(fn(this.val));
    }
    return MaybeM.none<R>();
  }
  unwrap(): T {
    return this.val;
  }
}
```
### Usage of MaybeM

We can then use the Monadic Maybe like so.

```typescript
type Drink = {
  name: string;
  color: string;
  caffieneContent: Maybe<number>;
};

const drinks: Drink[] = [
  {
    name: "coffee",
    color: "black",
    caffeineContent: 79
  },
  {
    name: "sprite",
    color: "clear",
    caffeineContent: null
  }
];

function lookupCaffeineCont(name: string, drinks: Drink[]): Maybe<number> {
  const caffiene = 
    MaybeM.lift(drinks.find((d) => d.name === name))
    .map((drink) => drink.caffeineContent)
    .unwrap();
  return caffiene;
}
```

We could even find the caffeine content for every drink, determine if it is high, and make a new list of all high caffeine drinks.

```typescript
const allCaffeine: string[] = drinks.map(drink => {
  const level: Maybe<string> = MaybeM.lift(drink)
                              .fMap(drink => MaybeM.lift(drink.caffeineContent))
                              .map(caff => caff > 50 ? "HIGH" : "LOW" )
                              .unwrap();
  return exists(level) ? level : "N/A";
});
```

This will never hit the final logging statement. The Maybe Monad abstracts away the continual/nested checking required when handling potentially missing values!

We use `fMap` because `drink.caffeineContent` is potentially undefined. Because it could be missing we need to lift it into `MaybeM`. `fMap` doesn't wrap the result of it's function in `MaybeM` like `map` does. Using `fMap` allows us to "flatten" our result so that we don't end nested.

