// Animal base class
const Animal = createClass("Animal", {

```
speak() {
    console.log("Generic sound");
}
```

});

// Dog subclass
const Dog = createClass(
"Dog",
{

```
    speak() {
        console.log("Woof");
    }

},
Animal
```

);

const dog = new Dog();

objj_msgSend(dog, "speak");
