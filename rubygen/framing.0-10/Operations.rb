#!/usr/bin/env ruby
# Usage: output_directory xml_spec_file [xml_spec_file...]
# 
$: << '..'
require 'cppgen'
require 'fileutils'
require 'etc'
require 'pathname'

class OperationsGen < CppGen

  def initialize(chassis, outdir, amqp)
    super(outdir, amqp)
    @chassis=chassis
    @classname="AMQP_#{@chassis.caps}Operations"
  end
  
  def handler_method (m)
    return_type = m.result ? m.result.cpptype.ret_by_val : "void"
    gen "\nvirtual #{return_type} #{m.cppname}("
    gen m.signature.join(",\n")
    gen ") = 0;\n"
  end

  def handler_classname(c) c.name.caps+"Handler"; end

  def methods_on(parent, chassis)
    chassis == "all" ?  parent.methods_ : parent.methods_on(chassis)
  end

  def handler_class(c)
    m = methods_on(c,@chassis)
    if (not m.empty?)
      handlerclass=handler_classname c
      gen <<EOS
// ==================== class #{handlerclass} ====================
class #{handlerclass} {
    // Constructors and destructors
  public:
    class Invoker;              // Declared in #{@chassis.caps}Invoker
      
    #{handlerclass}(){};
    virtual ~#{handlerclass}() {}
    // Protocol methods
EOS
      m.each { |m| handler_method(m) if !m.content() }
      gen <<EOS
}; // class #{handlerclass}


EOS
    end
  end

  def handler_get(c)
    m = methods_on(c,@chassis)
    if (not m.empty?)
      handlerclass=handler_classname c
      gen "virtual #{handlerclass}* get#{handlerclass}() = 0;\n"
    end
  end

  def generate()
    h_file("qpid/framing/#{@classname}.h") {
      gen <<EOS
#include <sstream> 
#include "qpid/framing/ProtocolVersion.h"
#include "qpid/framing/amqp_structs.h"

namespace qpid {
namespace framing {

class AMQMethodBody;

class #{@classname} {
  public:
    class Invoker;              // Declared in #{@chassis.caps}Invoker

    virtual ~#{@classname}() {}

    virtual ProtocolVersion getVersion() const = 0;

    // Inner classes
EOS
  indent { @amqp.classes.each { |c| handler_class(c) } }
  gen <<EOS

    // Method handler get methods

EOS
  indent { @amqp.classes.each { |c| handler_get(c) } }
  gen <<EOS
}; /* class #{@classname} */
}}
EOS
}
  end
end

OperationsGen.new("client",ARGV[0], $amqp).generate()
OperationsGen.new("server",ARGV[0], $amqp).generate()
OperationsGen.new("all",ARGV[0], $amqp).generate()

