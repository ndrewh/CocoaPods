require File.expand_path('../../spec_helper', __FILE__)

describe "A Pod::Specification loaded from a Podfile" do
  before do
    @spec = Pod::Specification.from_podfile(fixture('Podfile'))
  end

  it "lists the project's dependencies" do
    @spec.dependencies.should == [
      Pod::Dependency.new('SSZipArchive',      '>= 1'),
      Pod::Dependency.new('ASIHTTPRequest',    '~> 1.8.0'),
      Pod::Dependency.new('Reachability',      '>= 0'),
      Pod::Dependency.new('ASIWebPageRequest', ' < 1.8.2')
    ]
  end

  it "returns the path to the Podfile" do
    @spec.defined_in_file.should == fixture('Podfile')
  end

  it "returns that it's loaded from a Podfile" do
    @spec.should.be.from_podfile
  end

  it "does not have a destroot" do
    @spec.pod_destroot.should == nil
  end
end

describe "A Pod::Specification loaded from a podspec" do
  before do
    @spec = Pod::Specification.from_podspec(fixture('banana-lib/BananaLib.podspec'))
  end

  it "returns that it's not loaded from a podfile" do
    @spec.should.not.be.from_podfile
  end

  it "returns the path to the podspec" do
    @spec.defined_in_file.should == fixture('banana-lib/BananaLib.podspec')
  end

  it "returns the directory where the pod should be checked out to" do
    @spec.pod_destroot.should == config.project_pods_root + 'BananaLib-1.0'
  end

  it "returns the pod's name" do
    @spec.read(:name).should == 'BananaLib'
  end

  it "returns the pod's version" do
    @spec.read(:version).should == Pod::Version.new('1.0')
  end

  it "returns a list of authors and their email addresses" do
    @spec.read(:authors).should == {
      'Banana Corp' => nil,
      'Monkey Boy' => 'monkey@banana-corp.local'
    }
  end

  it "returns the pod's homepage" do
    @spec.read(:homepage).should == 'http://banana-corp.local/banana-lib.html'
  end

  it "returns the pod's summary" do
    @spec.read(:summary).should == 'Chunky bananas!'
  end

  it "returns the pod's description" do
    @spec.read(:description).should == 'Full of chunky bananas.'
  end

  it "returns the pod's source" do
    @spec.read(:source).should == {
      :git => 'http://banana-corp.local/banana-lib.git',
      :tag => 'v1.0'
    }
  end

  it "returns the pod's source files" do
    @spec.read(:source_files).should == [
      Pathname.new('Classes/*.{h,m}'),
      Pathname.new('Vendor')
    ]
  end

  it "returns the pod's dependencies" do
    @spec.read(:dependencies).should == [
      Pod::Dependency.new('monkey', '~> 1.0.1', '< 1.0.9')
    ]
  end

  it "returns the pod's xcconfig settings" do
    @spec.read(:xcconfig).should == {
      'OTHER_LDFLAGS' => '-framework SystemConfiguration'
    }
  end
end

describe "A Pod::Specification that's part of another pod's source" do
  before do
    @spec = Pod::Specification.new
  end

  it "adds a dependency on the other pod's source, but not the library" do
    @spec.part_of 'monkey', '>= 1'
    @spec.should.be.part_of_other_pod
    dep = Pod::Dependency.new('monkey', '>= 1')
    @spec.read(:dependencies).should.not == [dep]
    dep.only_part_of_other_pod = true
    @spec.read(:dependencies).should == [dep]
  end

  it "adds a dependency on the other pod's source *and* the library" do
    @spec.part_of_dependency 'monkey', '>= 1'
    @spec.should.be.part_of_other_pod
    @spec.read(:dependencies).should == [Pod::Dependency.new('monkey', '>= 1')]
  end

  # TODO
  #it "returns the specification of the pod that it's part of" do
  #  @spec.part_of_specification
  #end
  #
  #it "returns the destroot of the pod that it's part of" do
  #  @spec.pod_destroot
  #end
end
