#!/usr/bin/env ruby -S rspec

require 'spec_helper'

type_class = Puppet::Type.type(:network_config)

describe type_class do
  before do
    @class = type_class

    @provider_class = stub 'provider class', :name => "fake", :suitable? => true, :supports_parameter? => true
    @provider = stub 'provider', :class => @provider_class
    @provider_class.stubs(:new).returns @provider

    @class.stubs(:defaultprovider).returns @provider_class
    @class.stubs(:provider).returns @provider_class

    @resource = stub 'resource', :resource => nil, :provider => @provider
  end

  describe "when validating the attribute" do

    [:name, :reconfigure].each do |param|
      it "should have the '#{param}' param" do
        @class.attrtype(param).should == :param
      end
    end

    [:ensure, :ipaddress, :netmask, :method, :family, :onboot, :attributes].each do |property|
      it "should have the '#{property}' property" do
        @class.attrtype(property).should == :property
      end
    end

    it "should ensure that the name param is the namevar" do
      @class.key_attributes.should == [:name]
    end

    describe "attributes" do
      it "should be a descendant of the KeyValue property"
    end
  end

  describe "when validating the attribute value" do

    describe "ensure" do
      it "should be an ensurable value" do
        @class.propertybyname(:ensure).ancestors.should include(Puppet::Property::Ensure)
      end
    end
    describe "ipaddress" do
      it "should require that a passed address is a valid IPv4 address"
      it "should require that a passed address is a valid IPv6 address"
      it "should fail if a malformed address is used" do
        lambda do
          @class.new(:name => 'yay', :ipaddress => 'This is clearly not an IP address')
        end.should raise_error
      end
    end

    describe "netmask" do
      it "should validate a CIDR netmask"
      it "should fail if an invalid CIDR netmask is used" do
        lambda do
          @class.new(:name => 'yay', :netmask => 'This is clearly not a netmask')
        end.should raise_error
      end
    end

    describe "method" do
      [:static, :manual, :dhcp].each do |mth|
        it "should consider '#{mth}' a valid configuration method" do
          @class.new(:name => 'yay', :method => mth)
        end
      end
    end

    describe "family" do
      [:inet, :inet6].each do |family|
        it "should consider '#{family}' a valid address family" do
          @class.new(:name => 'yay', :family => family)
        end
      end
    end

    describe 'onboot' do
      [true, false].each do |bool|
        it "should accept '#{bool}' for onboot" do
          @class.new(:name => 'yay', :onboot => true)
        end
      end
    end

    describe 'reconfigure' do
      [true, false].each do |bool|
        it "should accept '#{bool}' for reconfigure" do
          @class.new(:name => 'yay', :reconfigure => true)
        end
      end
    end

    describe "attributes" do
      it "should accept an empty hash" do
        lambda do
          @class.new(:name => "valid", :attributes => {})
        end.should_not raise_error
      end

      it "should use an empty hash as the default" do
        lambda do
          @class.new(:name => "valid")
        end.should_not raise_error
      end
      it "should fail if a non-hash is passed" do
        lambda do
          @class.new(:name => "valid", :attributes => "geese" )
        end.should raise_error
      end
    end
  end
end
