require 'spec_helper'

RSpec.describe Robots::DorRepo::WasSeedPreassembly::EndWasSeedPreassembly do
  describe 'perform' do
    let(:druid) { 'druid:ab123cd4567' }
    let(:service) { instance_double(Dor::Services::Client::Object) }
    let(:instance) { described_class.new }

    subject(:perform) { instance.perform(druid) }

    before do
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(service)
      allow(Dor::Config.workflow).to receive(:client).and_return(wf_client)
    end

    context 'for new objects' do
      let(:wf_client) { instance_double(Dor::Workflow::Client, workflow_status: nil) }

      it 'initializes accessionWF' do
        expect(instance.workflow_service).to receive(:create_workflow_by_name).with(druid, 'accessionWF')
        perform
      end
    end

    context 'for already accessioned objects' do
      let(:wf_client) { instance_double(Dor::Workflow::Client, workflow_status: 'completed') }

      it 're-versions the object' do
        expect(service).to receive(:open_new_version)
        expect(service).to receive(:close_version).with(description: 'Updating the seed object through wasSeedPreassemblyWF', significance: 'Major')
        perform
      end
    end

    context 'for the objects that are under accessioning' do
      let(:wf_client) { instance_double(Dor::Workflow::Client) }
      before do
        allow(wf_client).to receive(:workflow_status).with('dor', 'druid:ab123cd4567', 'accessionWF', 'start-accession').and_return('completed')
        allow(wf_client).to receive(:workflow_status).with('dor', 'druid:ab123cd4567', 'accessionWF', 'end-accession').and_return(nil)
      end

      it 'issues an error' do
        expect { perform }.to raise_error('Druid object druid:ab123cd4567 is still in accessioning, reset the end-was-seed-preassembly after accessioning completion')
      end
    end

    context 'for the objects with unknown status' do
      let(:wf_client) { instance_double(Dor::Workflow::Client) }
      before do
        allow(wf_client).to receive(:workflow_status).with('dor', 'druid:ab123cd4567', 'accessionWF', 'start-accession').and_return(nil)
        allow(wf_client).to receive(:workflow_status).with('dor', 'druid:ab123cd4567', 'accessionWF', 'end-accession').and_return('completed')
      end

      it 'issues an error' do
        expect { perform }.to raise_error('Druid object druid:ab123cd4567 is unknown status')
      end
    end
  end
end
