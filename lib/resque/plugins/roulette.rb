require 'resque/worker'

module Resque::Plugins
  module Roulette
    # Define an 'unfair' priority multiplier to queues
    def self.prioritize(queue, value)
      priorities[queue] = value
    end

    def self.priorities
      @priorities ||= {}
    end

    # Returns a list of queues to use when searching for a job. A
    # splat ("*") means you want every queue
    #
    # The queues will be ordered randomly and the order will change
    # with every call. This prevents any particular queue for being
    # starved. Workers will process queues in a random order each
    # time the poll for new work.
    #
    # If priorities have been established, the randomness of the order
    # will be weighted according to the multipliers
    def queues_randomly_ordered
      queue_priorities = queues_orig_ordered.map { |q| Roulette.priorities[q] }
      if queue_priorities.compact.any?
        weighted_order(queues_orig_ordered, queue_priorities.map { |p| p || 1 })
      else
        queues_orig_ordered
      end
    end

    def self.included(klass)
      klass.instance_eval do
        alias queues_orig_ordered queues
        alias queues queues_randomly_ordered
      end
    end

    private

    # Give the index of an item in weights based on the weights
    def weighted_rand_index(weights)
      rand_val = rand * weights.inject(&:+)
      weights.each_with_index do |weight, index|
        return index if (rand_val -= weight).negative?
      end
      0
    end

    def weighted_order(vals, weights)
      vals = vals.dup
      weights = weights.dup

      [].tap do |results|
        until vals.empty?
          val_index = weighted_rand_index(weights)
          results << vals[val_index]
          vals.delete_at val_index
          weights.delete_at val_index
        end
      end
    end
  end

  Resque::Worker.send(:include, Roulette)
end
