---
author: "Chandler Barlow"
tags: ["react", "javascript"]
title: "When To Use Redux"
date: "2019-08-12"
draft: false
---

![image](/redux_img.jpeg)
When should you use Redux in a React project?  
When using React, a state management library like Redux isn't always necessary. Out of the box React provides a few solutions for managing state. Therefore, not every React project requires Redux. So, when should Redux be used?
The main indicator of whether Redux is necessary is how complex the data flow in a project is.  
**State can be passed down**  
State can be passed to child components through props. If a child component needs some information, the parent can simply pass it to them.

```javascript
class Parent extends React.component(){
    render() {
        return <Child prop = {value to be passed down}/>;
    }
}
```

or as a functional component

```javascript
const parent = () => {
    return <Child prop = {value to be passed down}/>;
}
```

If your project only requires passing data downwards I don't recommend adding Redux. Redux could hurt in this case if you aren't already familiar with it. Passing data downwards is pretty easy in React and I don't think an outside solution is necessary. React is designed around passing state downwards.  
Okay, so passing data down is easy, but what if a project needs a child to pass information upwards to their parent? This could be quite the puzzle to inexperienced React developers. The problem being in React child components are completely isolated from their parent. Data can only be passed to the child, not the other way around. The most common way to address this issue is by a parent component passing a callback function as a prop to its child. The callback function can be called from the child to interact with the parent. The idea is that if the child needs to communicate with its parent, it can do so through the callback.  
State can be passed upwards

```javascript
class Parent extends React.component() {
  callback() {
    return;
  }
  render() {
    return (
      <Child
        prop={() => {
          callback();
        }}
      />
    );
  }
}
```

Again this is possible in functional components

```javascript
const Parent = () => {
  const callback = () => {
    return;
  };
  return (
    <Child
      prop={() => {
        callback();
      }}
    />
  );
};
```

Passing data upwards is achievable and not too difficult to manage, but still, things can get complicated quickly. What once was a simple project can now be difficult to debug or add anything new to. Functions will be scattered through child components. Tracking errors and information flow becomes a headache. This can leave developers asking.
It surely can't be this complicated to just pass data upwards can it?  
Like all good developers, they take to the internet for answers. Their Google searches bring up Redux as a possible solution. Yet, in every forum where a user presents Redux two more users are there to complain about it.

> Redux has too much boiler-plate

or

> Forced to write pure functions

The attitude towards Redux many developers have can be unsettling to those thinking about using it in their project. Many developers are completely turned off of Redux at this point, or they're trying really hard to prove to themselves they don't need Redux. They settle for callbacks and painful debugging. Honestly, I don't blame them for omitting Redux. I think it makes sense to stay away from Redux if you just need to pass data from parent to child and vice versa. So, if it's not necessary to use Redux when passing data down, and it isn't super necessary to use it when passing data up, when is it necessary?  
One word: siblings.  
Data should not be passed up then down, or through multiple components  
I'm not even going to include code snippets on how to do this because it's a headache and should be avoided. I will include a diagram on how this works though.

### Passing state to a sibling

![passing state to sibling](/redux_chart_1.png)

### Passing state to a sibling's child

![passing state to sibling](/redux_chart_2.png)
If you have data from a parent being passed to a child component, then passed back to the parent, and then finally being passed down to a sibling of the first child component, you probably need Redux.  
Why does that mean Redux? Because code will start getting unbelievably complex once state is being passed between siblings.  
To understand why passing state between siblings is a horrible idea, it is important to understand what React is actually doing when components render. Each component doesn't exist in space as a block that can be modified at will. React components, at their base level, are functions that output Html. State could be described as arguments to these functions.  
Therefore it's easy to pass data down, from component to component, but so difficult to pass information in other directions.  
So, if React components are basically just functions that output html based on their current state, wouldn't it be easier if we could organize all the data in our project in one place? One store of all our project's data to be used by our components? Bingo.  
That's exactly what Redux is.  
Redux stores all data in a single store  
Redux is not just for React. Redux is a JavaScript library that allows developers to pull all the data in their project out of their components and organize that state into a single place. Instead of tracking state across components and pulling hair out every time errors occur, developers can just look at the data store to determine where things went wrong. This makes things like sibling components interacting a breeze. With Redux, components can freely access the state Store. Connecting two components now means connecting them to the store. No longer is passing state up five components and then back down three a common occurrence in a project.
With Redux, state goes from being piped throughout an application from parent to child, to a clean debuggable single source of truth. Instead of components receiving state from other components, all components receive their state from the same source.  
When to use Redux:

- If your project requires complex interactions between components
- If state will change frequently or in unpredictable ways (async calls)
- If a project needs to be scalable/could become more complicated in the future

In summary, if you've never used Redux and your project just requires passing state downwards, then don't worry about Redux. You should still learn to use it (or a different state management library like Mobx) because you'll need some form of state management someday, but today is not that day. If your project requires passing data between multiple components in multiple directions, or through multiple children, it's better to just add Redux now and save yourself the headache.
