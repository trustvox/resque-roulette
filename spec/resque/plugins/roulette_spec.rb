require 'spec_helper'

describe Resque::Plugins::Roulette do
  context 'with our own priorities' do
    before { described_class.instance_variable_set(:@priorities, nil) }

    describe 'queues' do
      let(:worker) { Resque::Worker.new(*queues) }
      let(:queues) { ['b', 'd', 'a', 'c'] }

      context 'under a Monte Carlo test' do
        let(:counts) { {'a' => 0, 'b' => 0, 'c' => 0, 'd' => 0} }
        let(:n) { 100000 }

        before do
          priorities.each do |queue, priority|
            described_class.prioritize(queue, priority)
          end

          n.times { counts[worker.queues_randomly_ordered.first] += 1 }
          counts.each { |k, v| counts[k] /= n.to_f }
        end

        context "with weights 4, 3, 2, 1" do
          let(:priorities) { { 'a' => 4, 'b' => 3, 'c' => 2, 'd' => 1 } }

          it 'returns probablistically proportional to their weights' do
            expect(counts['a']).to be_between(0.38, 0.42)
            expect(counts['b']).to be_between(0.28, 0.32)
            expect(counts['c']).to be_between(0.18, 0.22)
            expect(counts['d']).to be_between(0.01, 0.12)
          end
        end

        context "with weights 7, 1, 2, 0" do
          let(:priorities) { { 'a' => 7, 'b' => 1, 'c' => 2, 'd' => 0 } }

          it 'returns probablistically proportional to their weights' do
            expect(counts['a']).to be_between(0.68, 0.72)
            expect(counts['b']).to be_between(0.08, 0.12)
            expect(counts['c']).to be_between(0.19, 0.22)
            expect(counts['d']).to be_zero
          end
        end
      end

      context 'when priorities is not set' do
        it 'consistenty gives the original order' do
          10.times do
            expect(worker.queues_randomly_ordered).to eq(queues)
          end
        end
      end
    end
  end
end
