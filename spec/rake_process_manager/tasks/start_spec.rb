require 'spec_helper'

describe RakeProcessManager::Tasks::Start do
  include_context :rake

  it 'adds a start task in the namespace in which it is created' do
    namespace :something do
      subject.define(
          process_name: 'process',
          process_description: 'some process')
    end

    expect(Rake::Task.task_defined?('something:start')).to(be(true))
  end

  it 'gives the start task a description' do
    namespace :something do
      subject.define(
          process_name: 'dev-server',
          process_description: 'local development server')
    end

    expect(Rake::Task["something:start"].full_comment)
        .to(eq("Start local development server."))
  end

  it 'allows the task name to be overridden' do
    namespace :something do
      subject.define(
          name: :provision,
          process_name: 'process',
          process_description: 'some process')
    end

    expect(Rake::Task.task_defined?("something:provision"))
        .to(be(true))
  end

  it 'allows multiple start tasks to be declared' do
    namespace :something1 do
      subject.define(
          process_name: 'process1',
          process_description: 'some process')
    end

    namespace :something2 do
      subject.define(
          process_name: 'process2',
          process_description: 'some process')
    end

    expect(Rake::Task.task_defined?("something1:start")).to(be(true))
    expect(Rake::Task.task_defined?("something2:start")).to(be(true))
  end

  it 'configures the task with the provided arguments if specified' do
    argument_names = [:deployment_identifier, :region]

    namespace :something do
      subject.define(
          argument_names: argument_names,
          process_name: 'process',
          process_description: 'some process')
    end

    expect(Rake::Task['something:start'].arg_names)
        .to(eq(argument_names))
  end

  it 'creates the specified log directory on invocation' do
    stub_puts

    namespace :something do
      subject.define(
          process_name: 'process',
          process_description: 'some process',
          log_file_path: 'logs/process/out.log')
    end

    rake_task = Rake::Task["something:start"]
    test_task = rake_task.creator

    allow(test_task).to(receive(:mkdir_p))
    expect(test_task)
        .to(receive(:mkdir_p).with('logs/process'))

    Rake::Task["something:start"].invoke
  end

  it 'creates the specified pid directory on invocation' do
    stub_puts

    namespace :something do
      subject.define(
          process_name: 'process',
          process_description: 'some process',
          pid_file_path: 'pids/process/main.pid')
    end

    rake_task = Rake::Task["something:start"]
    test_task = rake_task.creator

    allow(test_task).to(receive(:mkdir_p))
    expect(test_task)
        .to(receive(:mkdir_p).with('pids/process'))

    Rake::Task["something:start"].invoke
  end

  xit 'uses the provided main namespace when specified' do
    stub_puts

    expect(RubyProcessManager)
        .to(receive(:uberjar)
            .with(
                main_namespace: 'some.namespace',
                profile: nil))

    namespace :something do
      subject.define(main_namespace: 'some.namespace')
    end

    Rake::Task["something:build"].invoke
  end

  xit 'uses the provided profile when specified' do
    stub_puts

    expect(RubyProcessManager)
        .to(receive(:uberjar)
            .with(
                main_namespace: nil,
                profile: "test"))

    namespace :something do
      subject.define(profile: "test")
    end

    Rake::Task["something:build"].invoke
  end

  xit 'changes directory if the directory parameter is specified' do
    stub_puts

    directory = "some/other/directory"

    expect(Dir).to(receive(:chdir).with(directory).and_yield)

    expect(RubyProcessManager)
        .to(receive(:uberjar))

    namespace :something do
      subject.define(directory: directory)
    end

    Rake::Task["something:build"].invoke
  end

  def stub_puts
    allow_any_instance_of(Kernel).to(receive(:puts))
  end
end
