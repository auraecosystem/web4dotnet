// ================================
// Minimal Objective-J Style Runtime
// ================================

// Global class registry
const ClassRegistry = {};

// ================================
// Create Class
// ================================

function createClass(name, methods = {}, superClass = null) {

```
function ClassConstructor() {

    this.__className = name;

    if (methods.init) {
        methods.init.apply(this, arguments);
    }
}

// Inheritance
if (superClass) {
    ClassConstructor.prototype =
        Object.create(superClass.prototype);
}

// Attach methods
for (const key in methods) {

    if (key !== "init") {
        ClassConstructor.prototype[key] = methods[key];
    }
}

// Register class
ClassRegistry[name] = ClassConstructor;

return ClassConstructor;
```

}

// ================================
// Message Send System
// ================================

function objj_msgSend(receiver, selector, ...args) {

```
if (!receiver) {
    throw new Error(
        `Cannot send '${selector}' to null`
    );
}

const method = receiver[selector];

if (typeof method !== "function") {

    throw new Error(
        `Method '${selector}' not found`
    );
}

return method.apply(receiver, args);
```

}

// ================================
// Example Class
// ================================

const Person = createClass("Person", {

```
init(name) {
    this.name = name;
},

speak() {
    console.log(
        `Hello, my name is ${this.name}`
    );
},

add(a, b) {
    return a + b;
}
```

});

// ================================
// Instantiate Object
// ================================

const user = new Person("Yakub");

// ================================
// Objective-J Style Messaging
// ================================

objj_msgSend(user, "speak");

const result =
objj_msgSend(user, "add", 5, 9);

console.log(result);
