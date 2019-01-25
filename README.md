resque-roulette
===============

### Why?

I've many resque workers created in the same way using splat operator to run for every queue (QUEUE=*), but to don't wait a given queue process all your jobs, 
I've been looking for a plugin to make that shuffle to me, and then I've found this magic plugin [resque-unfairly](https://github.com/seomoz/resque-unfairly) 
but this is a old project and it's not in published at rubygems, so I've forked the repo and make some changes to could be published and used from rubygems instead of git directly.

Thanks for the awesome job Evan! :beers: 

Usually Resque workers work on queues in the given order (if there is something in the first, work it, otherwise if the there is something in the second, work on it, and
so on). This plugin randomizes the order of the queues based on weights, so that a given queue will be the first queue to try based on a probability weight. Given queues A, B, C, D and
weights 4, 3, 2, 1, repsectively, A will be first 40% of the time, B 30%, C 20%, and D 10%. In addition, when B is first, A will be second 4/7ths of the time (4 / [4+2+1]), and so on. The
project is inspired by [resque-fairly](https://github.com/pezra/resque-fairly) by Peter Williams, which unfortunately mathematically does not give you this control over the weights.

### Example usage

``` ruby
require 'resque'
require 'resque/plugins/roulette'

Resque::Plugins::Roulette.prioritize('myqueue' 1)
Resque::Plugins::Roulette.prioritize('myotherqueue', 3)
Resque::Plugins::Roulette.prioritize('someotherqueue', 6)
```

Now, workers processing all three queues will (assuming all queues have jobs) take jobs from someotherqueue 60% of the time, myotherqueue 30% of the time, and myqueue 10% of the time. This is achieved
by reordering the queues, so if someotherqueue is empty, the workers will take jobs from myotherqueue 75% (3/4) of the time.


### Authors

- **Mantainer** - Bruno Casali @brunoocasali
- **Creator**   - Evan Battaglia @evanbattaglia
