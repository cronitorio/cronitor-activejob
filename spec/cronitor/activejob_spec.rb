# frozen_string_literal: true

class DummyJob < ActiveJob::Base
  def perform; end
end

class CronitorJob < ActiveJob::Base
  include Cronitor::ActiveJob
  def perform; end
end

class BadJob < ActiveJob::Base
  include Cronitor::ActiveJob
  def perform
    raise "This is an exception"
  end
end

class DisabledJob < CronitorJob
  cronitor_disabled true
end

class ExplicitJob < CronitorJob
  cronitor_key "my-explicit-key"
end

RSpec.describe Cronitor::ActiveJob do
  it "has a version number" do
    expect(Cronitor::ActiveJob::VERSION).not_to be nil
  end

  let(:monitor) { double(ping: true) }

  context "on a plain ActiveJob" do
    it "does not ping cronitor" do
      expect(Cronitor::Monitor).to_not receive(:new)
      expect(Cronitor).to_not receive(:job)
      DummyJob.perform_now
    end
  end

  context "an ActiveJob with Cronitor included" do
    context "with no options set" do
      it "should default to class name for job key" do
        expect(CronitorJob.cronitor_job_key).to eq "CronitorJob"
      end

      it "should default to not disabled" do
        expect(CronitorJob.cronitor_disabled?).to be false
      end
    end

    context "able to set options" do
      it "should allow job key to be set" do
        CronitorJob.cronitor_key "my_test_job_key"
        expect(CronitorJob.cronitor_job_key).to eq "my_test_job_key"
        CronitorJob.cronitor_key nil
        expect(CronitorJob.cronitor_job_key).to eq "CronitorJob"
      end

      it "should accept being disabled" do
        CronitorJob.cronitor_disabled true
        expect(CronitorJob.cronitor_disabled?).to be true
        CronitorJob.cronitor_disabled false
      end
    end

    describe "#perform_now" do
      before(:each) do
        allow(Cronitor::Monitor).to receive(:new).and_return(monitor)
      end

      context "without an api key set" do
        it "should not notify cronitor" do
          Cronitor.api_key = nil
          expect(Cronitor::Monitor).to_not receive(:new)
          expect(Cronitor).to_not receive(:job)
          CronitorJob.perform_now
        end
      end

      context "with an api key set" do
        before(:all) do
          Cronitor.api_key = "my_cronitor_key"
        end
        context "with a good job" do
          it "notifies cronitor" do
            expect(Cronitor::Monitor).to receive(:new).once.with("CronitorJob")
            expect(monitor).to receive(:ping).once.with(hash_including(state: "run"))
            expect(monitor).to receive(:ping).once.with(hash_including(state: "complete"))
            expect(monitor).not_to receive(:ping).with(hash_including(state: "fail"))
            CronitorJob.perform_now
          end

          context "with an explicit job key" do
            it "notifies cronitor" do
              expect(Cronitor::Monitor).to receive(:new).once.with("my-explicit-key")
              expect(monitor).to receive(:ping).once.with(hash_including(state: "run"))
              expect(monitor).to receive(:ping).once.with(hash_including(state: "complete"))
              expect(monitor).not_to receive(:ping).with(hash_including(state: "fail"))
              ExplicitJob.perform_now
            end
          end

          context "with cronitor disabled" do
            it "does not notify cronitor" do
              expect(Cronitor::Monitor).to_not receive(:new)
              expect(Cronitor).to_not receive(:job)
              DisabledJob.perform_now
            end
          end
        end

        context "with a bad job" do
          it "notifies crontior" do
            expect(Cronitor::Monitor).to receive(:new).once.with("BadJob")
            expect(monitor).to receive(:ping).once.with(hash_including(state: "run"))
            expect(monitor).not_to receive(:ping).with(hash_including(state: "complete"))
            expect(monitor).to receive(:ping).once.with(
              hash_including(state: "fail", message: "This is an exception")
            )
            expect { BadJob.perform_now }.to raise_error RuntimeError
          end
        end
      end
    end
  end
end
