require 'spec_helper'

set :os, :family => 'base'

describe 'postfix_config' do
  let(:command_result) do
    result = CommandResult.new(
      :stdout      => stdout,
      :stderr      => '',
      :exit_status => 0,
      :exit_signal => nil,
    )
  end

  before do
    expect(Specinfra.backend).to receive(:run_command).with(expected_command).and_return(command_result)
  end

  describe postfix_config('myorigin') do
    describe 'value' do
      let(:expected_command) { 'postconf -h myorigin' }
      let(:stdout) { "$myhostname\n" }

      its(:value) { should eq '$myhostname' }
    end

    describe 'expanded_value' do
      let(:expected_command) { 'postconf -h -x myorigin' }
      let(:stdout) { "localhost.localdomain\n" }

      its(:expanded_value) { should eq 'localhost.localdomain' }
    end

    describe 'configured?' do
      let(:expected_command) { 'postconf -h myorigin' }

      context 'when configured' do
        let(:stdout) { "$myhostname\n" }

        it { should be_configured }
      end

      context 'when configured with empty value' do
        let(:stdout) { "\n" }

        it { should be_configured }
      end

      context 'when not configured' do
        let(:stdout) { '' }

        it { should_not be_configured }
      end
    end
  end

  describe postfix_config('myorigin', override: {'myhostname' => 'example.com'}) do
    describe 'value' do
      let(:expected_command) { 'postconf -h -o myhostname\=example.com myorigin' }
      let(:stdout) { "$myhostname\n" }

      its(:value) { should eq '$myhostname' }
    end

    describe 'expanded_value' do
      let(:expected_command) { 'postconf -h -x -o myhostname\=example.com myorigin' }
      let(:stdout) { "example.com\n" }

      its(:expanded_value) { should eq 'example.com' }
    end
  end
end
