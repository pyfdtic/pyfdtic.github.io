

Vuex 是专门为 Vue.js 设计的状态管理库, 以利用 Vue.js 的细粒度数据响应机制来进行高效的状态更新.

**核心思想**: 将组件的共享状态抽取处理, 以一个全局单例模式管理. 同时, 通过定义和隔离状态管理中的各种状态并强制准守一定的规则, 我们的代码将更结构化且易于维护.

![Vuex 架构图](https://vuex.vuejs.org/vuex.png)

store 基本上就是一个容器, 他包含着应用中大部分的**状态(state)**. Vuex 和单纯的全局对象有一下两点不同:

1. Vuex 的状态存储是响应式的. 当 Vue 组件从 store 中读取状态的时候, 若 store 中的状态发生变化, 那么相应的组件也会相应得到高效更新.

2. 不能直接改变 store 中的状态. 改变 store 最后中的状态的唯一途径就是 **显式地提交 mutation**. 这样可方便的跟踪每一个状态的变化, 从而能实现一些工具帮助我们更好的理解我们的应用.



## 创建 store
仅需提供一个**初始 state** 和 一些 **mutation**.

```javascript
// 如果在模块化构建系统中, 请确保在开头调用了 Vue.use(Vuex)

const store = new Vuex.Store({
  state: {
    count: 0
  },
  mutations: {
    increment (state) {
      state.count++
    }
  }
})

// 触发状态变更
store.commit("increment")

// 获取状态对象
console.log(store.state.count)
```


## 核心概念

### State
**单一状态树**: 用一个对象就包含了全部的应用层级状态. 他是唯一数据源(SSOT). 这也意味着, 每个应用将仅仅包含一个 store 示例. 单一状态树 可以实现直接的定位任意特定的状态片段, 在调试的过程中也能轻易的取得整个当前应用状态的快照.



#### 获取 Store 状态方法

1. 在 Vue 组件中获得 Vuex 状态: 使用计算属性 --> 会导致组件依赖全局状态单例.

    ```javascript
    const Counter = {
      template: `<div>{{ count }}</div>`,
      computed: {
        count() {
          return store.state.count
        }
      }
    }
    ```

2. 将状态从根组件**注入**到每一个子组件中.
    
    需要调用 `Vue.use(Vuex)`
    通过在根实例中注册 store 选项, 该 store 实例会注入到根组件下的所有子组件中, 且**子组件**能通过 `this.$store` 访问到.

    ```javascript
    const app = new Vue({
      el: '#app',
      // 把 store 对象提供给 store 选项, 
      // 可以吧 store 的实例注入所有的子组件.
      store,
      components: { Counter },
      template:`
        <div class="app">
          <counter></counter>
        </div>
      `
    })

    // 修改 Counter 实现
    const Conter = {
      template: `<div>{{ count }} </div>`,
      computed: {
        count() {
          return this.$store.state.count
        }
      }

    }
    ```


#### mapState 辅助函数

当一个组件需要获取多个状态的时候, 讲这些状态都声明为计算属性有些重复和荣誉, 为了解决这个问题, 可以用使用 `mapState` 辅助函数帮助我们生成计算属性.

```javascript
// 在单独构建的版本中辅助函数为 Vuex.mapState
import { mapState } from 'Vuex'

export default {
  // ...
  computed: mapState({
      // 箭头函数可使代码更简洁
      count: state => state.count,

      // 传字符串参数 'count' 等同于 `state => state.count`
      countAlias: 'count',

      // 为了能够使用 'this' 获取局部状态, 必须使用常规函数
      countPlugLocalState(state){
        return state.count + this.localCount
      }
  })
}
```
当映射的计算属性的名称与 state 的子节点名称相同时, 也可以给 `mapState` 传一个字符串数组.
```javascript
computed: mapState([
  // 映射 this.count 为 store.state.count
  'count'
])
```


#### 对象展开运算符
`mapState` 函数返回的是一个对象. 通常, 我们需要使用一个工具函数将多个对象何必鞥为一个, 以使我们可以将最终对象传给 computed  属性. 

但自从有了**对象展开运算符**, 可以极大的简化写法:
```javascript
computed: {
    localComputed(){ /* ... */ },
    // 使用对象展开运算符将次对象混入到外部对象中
    ...mapState({
      // ... 
    })
}
```


#### 组件仍然保有局部状态
使用 Vuex 并不意味着需要将所有的状态放入 Vuex. 虽然将所有状态放到 Vuex 会使状态变化更显式和易调试, 但也会使代码变得冗长和不直观. 

如果有些状态严格属于单个组件, 最好还是作为组件的局部状态. 应当根据应用开发需要进行权衡和确定.


### Getter
有时需要从 store 中的 state 中派生出一些状态, 如对列表进行过滤并计数.

Vuex 允许在 store 中定义 `getter`(可以认为是 store 的计算属性). 就像计算属性一样, getter 的返回值会根据他的依赖被缓存起来, 且只有他的依赖值发生了改变才会被重新计算. 

`getter` 接受 `state` 作为其第一个参数
```javascript
const store = new Vuex.Store({
  state: {
    todos: [
      {id: 1, text: 'xxx', done: true},
      {id: 2, text: 'xxx', done: false}
    ]
  },
  getters: {
    doneTodos: state => {
      return state.todos.filter(todo => todo.done)
    }
  }
})
```


#### 通过 属性 访问
`getter` 会暴露为 `store.getters` 对象, 可以以属性的形式访问这些值.
```javascript
store.getters.doneTodos // -> [{id: 1, text: '...', done: true}]
```

`getter` 也可以接受其他 `getter` 作为第二参数:

```javascript
getters: {
  // ...
  doneTodosCount: (state, getters) => {
    return getters.doneTodos.length
  }
}


store.getters.doneTodosCount  // -> 1
```
可以很容易的在任何组件中使用它
```javascript
computed: {
  doneTodosCount() {
    return this.$store.getters.doneTodosCount
  }
}
```

**注意: getters 在通过属性访问时时作为 Vue 的响应式系统的一部分缓存其中的**.


#### 通过方法访问

可以通过让 `getter` 返回一个函数, 来实现给 getter 传参. 在对 store 里的数组进行查询时非常有用.
```javascript
getters: {
  // ... 
  getTodoById: (state) => (id) => {
    return state.todos.find(todo => todo.id === id)
  }
}


store.getters.getTodoById(2)    // -> {id: 2, text: '...', done: false}
```
**注意: getter 在通过方法访问时, 每次都会去进行调用, 而不会缓存结果**.


#### mapGetters 辅助函数
`mapGetters` 辅助函数仅仅是将 `store` 中的 `getter` 映射到局部计算属性:

```javascript
import { mapGetters } from 'vuex'

export default {
  // ...
  computed: {
    // 使用对象展开运算符 getter 混入 computed 对象中
    ...mapGetters([
      'doneTodosCount',
      'anotherGetter',
      // ... 
    ])
  }
}

// 如果将一个 getter 属性另取一个名字, 使用对象形式
mapGetters({
  // 把 `this.doneCount` 映射为 `this.$store.getters.doneTodosCount`
  doneCount: 'doneTodosCount'
})
```


### Mutation
**更改 Vuex 的 store 中的状态的唯一方法是提交 mutation**. Vuex 中的 mutation 非常类似于**事件**: 每个 mutation 都有一个字符串**事件类型(type)**和一个**回调函数(handler)**. 这个回调函数就是我们实际进行状态更改的地方, 并且他会接受 state 作为第一个参数:
```javascript
const store = new Vuex.Store({
  state: {
    count: 1
  },
  mutation: {
    increment (state) {
      // 更变状态
      state.count++
    }
  }
})
```

**不能直接调用 mutation handler**, 这个选项更像是事件注册: 当触发一个类型为 `increment` 的 `mutation` 时, 调用此函数. 要唤醒一个 `mutation handler`, 需要以相应的 `type` 调用 `store.commit` 方法.

```javascript
store.commit('increment')
```


#### 提交载荷
可以向 `store.commit` 传入额外的参数, 即 mutation 的 **载荷(payload)**
```javascript
// ...
mutation: {
  increment (state, n) {
    state.count += n
  }
}

// 调用
store.commit('increment', 10)
```
大多数情况下, **载荷应该是一个对象**, 这样可以包含多个字段并且记录的 mutation 会更易读:
```javascript
mutation: {
  increment (state, payload) {
    state.count += payload.amount
  }
}

// 调用
store.commit('increment', {
  amount: 10
})
```


#### 对象风格的提交
提交 mutation 的另一种方式是直接使用包含 **type** 属相的对象, mutation handler 保持不变.
```javascript
store.commit({
  type: 'increment',
  amount: 10
})
```


#### Mutation 需遵守 Vue 的相应规则
既然 Vuex 的 store 中的状态是响应式的, 那么, 当我们变更状态时, 监视状态的 Vue 组件也会自动更新. 这也意味着 Vuex 中的 Mutation 也需要与使用 Vue 一样遵守一些注意事项:

- 最好提前在 store 中初始化好所有所需属性.
- 当需要在对象上添加新属性时, 应该:
    - 使用 `Vue.set(obj, 'newProp', 123)`, 或者
    - 以新对象替换老对象. 如 利用 对象展开运算符 可以这样写

        ```javascript
        state.obj = {...state.obj, newProp: 123}
        ```


#### 使用常量替代 Mutation 事件类型
使用常量替代 mutation 事件类型在各种 Flux 实现中是很常见的模式. 这样可以使 linter 之类的工具发挥作用, 同时把这些常量放在单独的文件中可以让代码的合作者对整个 app 包含的 mutation 一目了然:
```javascript
// mutation-types.js
export const SOME_MUTATION = 'SOME_MUTATION'

// store.js
import Vuex from 'vuex'
import { SOME_MUTATION } from './mutation-types'

const store = new Vuex.Store({
  state: { ... },
  mutation: {
    // 我们可以使用 ES2015 风格的计算属性命名功能来使用一个常量作为函数名.
    [SOME_MUTATION](state){
      // mutate state
    }
  }
})
```


#### Mutation 必须是同步函数
在 Mutation 中混合异步调用, 会导致程序很难调试. 在 Vuex 中, mutation 都是同步事务.


#### mapMutation 在组件中提交 Mutation
可以在组件中使用 `this.$store.commit('xxx')` 提交 mutation, 或者使用 `mapMutations` 辅助函数将组件中的 methods 映射为 `store.commit` 调用(需要在根节点注入 `store`).

```javascript
import { mapMutation } form 'vuex'

export default{
  // ...
  methods: {
    ...mapMutations([
      'increment',    // 将 `this.increment()` 映射为 `this.$store.commit('increment')`
      // `mapMutations` 也支持 载荷
      'incrementBy'   // 将 `this.incrementBy(amount)` 映射为 `this.$store.commit('incrementBy', amount)`
    ]),
    ...mapMutations({
      add: 'increment'  // 将 `this.add()` 映射为 `this.$store.commit('increment')`
    })
  }
}
```

### Action
Action 类似于 mutation, 不同之处在于:
- Action 提交的是 mutation, 而不是直接变更状态.
- Action 可以包含任何异步操作.


#### 注册 action
```javascript
const store = new Vuex.Store({
    state: {
        count: 0
    },
    mutations: {
        increment (state) {
            state.count++
        }
    },
    actions: {
        increment (context) {
            context.commit('increment')
        }
    }
})
```

Action 函数接受一个与 store 实例具有相同方法和属性的 context 对象, 因此可以调用 `context.commit` 提交一个 `mutation`, 或者通过 `context.state` 和 `context.getters` 来获取 `state` 和 `getters`.

之后介绍 Modules 时, 就会明白 context 对象为什么**不是** store 实例本身.

实践中, 常用 ES2015 的[参数结构](https://github.com/lukehoban/es6features#destructuring)来简化代码(特别是需要调用 commit 很多次的时候)
```javascript
actions: {
    increment({ commit }) {
        commit('increment')
    }
}
```


#### 分发 Action

Action 通过 `store.dispatch` 方法触发:
```javascript
store.dispatch('increment')
```

由于 **mutation 必须同步执行**, 但是 Action 可以执行异步操作. 
```javascript
actions: {
    incrementAsync({ commit }) {
        setTimeout(() => {
            commit('increment')
        }, 1000)
    }
}
```
actions 支持 同样的**载荷方式**和**对象方式**进行分发
```javascript
// 以载荷方式分发
store.dispatch('incrementAsync', {
    amount: 10
})

// 以对象方式分发
store.dispatch({
    type: 'incrementAsync',
    amount: 10
})
```
一个购物车实例, 涉及**调用异步 API** 和 **分发多重 mutation**
```javascript
// 进行一系列的异步操作, 并且 通过提交 mutation 来记录 action 产生的副作用(即状态变更)

actions: {
    checkout ({commit, state}, products) {
        // 把当前购物车地物品备份起来
        const savedCartItems = [...stete.cart.added]
        // 发出结构请求, 然后乐观的晴空购物车
        commit(types.CHECKOUT_REQUEST)
        // 购物 API 接受一个成功回调和一个失败回调
        shop.buyProducts(
            products,
            // 成功操作
            () => commit(types.CHECKOUT_SUCCESS),
            // 失败操作
            () => commit(types.CHECKOUT_FAILURE, savedCartItems)
        )
    }
}
```


#### 在组件中分发 Action
在组件中使用 `this.$store.dispatch('xxx')` 分发 action, 或者使用 `mapActions` 辅助函数将组件的 methods 映射为 `store.dispatch` 调用(需要现在根节点注入 store).

```javascript
import { mapActions } from 'vuex'

export default {
    // ...
    methods: {
        ...mapActions([
            'increment',  // 将 `this.increment()` 映射为 `this.$store.dispatch('increment')`
            // `mapActions` 也支持载荷
            'incrementBy'  // 将 `this.incrementBy(amount)` 映射为 `this.$store.dispatch('incrementBy`, amount)`
        ]),
        ...mapActions({
            add: 'increment'    // 将 `this.add()` 映射为 `this.$store.dispatch('increment')`
        })
    }
}
```


#### 组合 Action
Action 通常是异步的, 那么如何知道 action 什么时候结束呢? 更重要的是, 如何才能组合多个 action, 以处理更加复杂的异步流程?

首先, `store.dispatch` 可以处理被触发的 action 的处理函数返回的 Promise, 并且 `store.dispatch` 仍然返回 Promise.
```javascript
actions: {
    actionA ({ commit }) {
        return new Promise((resolve, reject) => {
            setTimeout(() => {
                commit('someMutatin')
                resolve()
            }, 1000)
        })
    }
}
```
现在可以
```javascript
store.dispatch('actionA').then(() => {
    // ...
})
```
在另一个 action 中也可以
```javascript
actions: {
    // ...
    actionB({ dispatch, commit}) {
        return dispatch('actionA').then(() => {
            commit('someOtherMutation')
        })
    }
}
```
最后, 可以利用 [async/await](https://tc39.github.io/ecmascript-asyncawait/) , 可以如下组合 action:
```javascript
// 假设 getData() 和 getOtherData() 返回的是 Promise

actions: {
    async actionA ({ commit }) {
        commit('gotData', await getData())
    },
    async actionB ({ dispatch, commit }) {
        await dispatch('actionA')   // 等待 actionA 完成
        commit('getOtherData', await getOtherData())
    }
}
```
一个 `store.dispath` 在不同模块中可以触发多个 action 函数. 在这种情况下, 只有当所有触发函数完成后, 返回的 Promise 才会执行.


### Module
Vuex 允许将 store 分割成**模块(module)**. 每个模块拥有自己的 state, mutation, action, getter, 甚至是嵌套子模块 -- 从上至下进行同样方式的分割.
```javascript
const muduleA = {
    state: { ... },
    mutations: { ... },
    actions: { ... },
    getters: { ... }
}

const muduleB = {
    state: { ... },
    mutations: { ... },
    actions: { ... }
}

const store = new Vuex.Store({
    mudules: {
        a: moduleA,
        b: moduleB
    }
})

store.state.a   // -> moduleA 的状态
store.state.b   // -> moduleB 的状态
```

对于模块内部的 mutation 和 getter, 接受的第一个参数是**模块的局部状态对象**.
```javascript
const moduleA = {
    state: { count: 0},
    mutations: {
        increment (state) {
            // 这里的 `state` 对象是模块的局部状态
            state.count++
        }
    },
    getters: {
        doubleCount (state) {
            return state.count * 2
        }
    }
}
```
同样, 对于模块内部的 `action`, 局部状态通过 `context.state` 暴露出来, 根节点状态为 `context.rootState`:
```javascript
const moduleA = {
    // ...
    actions: {
        incrementIfOddOnRootSum({state, commit, rootState}) {
            if ((state.count + rootState.count) % 2 === 1) {
                commit('increment')
            }
        }
    }
}
```
对于模块内部的 getter, 根节点状态会作为第三个参数暴露出来:
```javascript
const moduleA = {
    // ...
    getters: {
        sumWithRootCount(state, getters, rootState) {
            return state.count + rootState.count
        }
    }
}
```

#### 命名空间
默认情况下, 模块内部的 action, mutation 和 getter 是注册在**全局命名空间**的, 这使得多个模块能够对同一 mutaation 或者 aciton 做出响应.

如果希望模块具有更高的封装性和复用性, 可以通过添加 `namespaced: true` 的方式使其成为带命名空间的模块. 当模块被注册后, 他的所有的 getter, action 及 mutation 都会自动根据模块注册的路径调整命名.

启用了命令空间的 getter 和 action 会收到局部化的 getter, dispatch 和 commit. 换言之, 你在使用模块内容(module assets)时, 不需要在同一模块内额外添加空间名前缀. 更改  namespaced 属性后不需要修改模块内的代码.

```JavaScript
const store = new Vuex.Store({
    modules: {
        account: {
            namespaced: true,

            // 模块内容 (module assets)
            state: { ... },     // 模块内的状态已经是嵌套的了, 使用 `namespaced` 属性不会对其产生影响.
            getters: {
                isAdmin() { ... } // -> getters['account/asAdmin']
            },
            actions: {
                login() { ... }  // -> dispatch('account/login')
            },
            mutations: {
                login() { ... }     // commit('account/login')
            },

            // 嵌套模块
            modules: {
                // 继承父模块的命名空间
                myPage: {
                    state: { ... },
                    getters: {
                        profile() { ... }   // -> getters['account/profile']
                    }
                },

                // 进一步嵌套命名空间
                posts: {
                    namespaced: true,

                    state: { ... },
                    getters: {
                        popular() { ... }   // -> getters['account/posts/popular']
                    }
                }
            }

        }
    }
})
```

**在带命名空间的模块内访问全局内容(global assets)**

