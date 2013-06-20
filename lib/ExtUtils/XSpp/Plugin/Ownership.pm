package ExtUtils::XSpp::Plugin::Ownership;

use strict;
use warnings;

use File::ShareDir;

use ExtUtils::XSpp::Node::Type;
use ExtUtils::XSpp::Plugin::Ownership::Typemap;

our $VERSION = '0.01';

=head1 NAME

ExtUtils::XSpp::Plugin::Ownership - default ownership handling for XS++

=cut

sub register_plugin {
    my ($class, $parser) = @_;

    $parser->add_toplevel_tag_plugin(plugin => $class,
                                     tag    => 'InitializeOwnership');
    $parser->add_class_tag_plugin(plugin => $class,
                                  tag    => 'DestroyIfOwned');
    $parser->add_method_tag_plugin(plugin => $class,
                                   tag    => 'TransferToCpp');
    $parser->add_method_tag_plugin(plugin => $class,
                                   tag    => 'TransferToPerl');
    $parser->add_argument_tag_plugin(plugin => $class,
                                     tag    => 'TransferToCpp');
    $parser->add_argument_tag_plugin(plugin => $class,
                                     tag    => 'TransferToPerl');
}

sub handle_toplevel_tag {
    my ($self, undef, $tag, %args) = @_;
    my @rows;

    push @rows, sprintf qq{#include "%s"},
      File::ShareDir::dist_file('ExtUtils-XSpp-Plugin-Ownership',
                                'ownership.h');
    if (($args{positional}[0] || '') eq 'implement') {
        push @rows, sprintf qq{#include "%s"},
          File::ShareDir::dist_file('ExtUtils-XSpp-Plugin-Ownership',
                                    'ownership.cpp');
    }

    return (1, ExtUtils::XSpp::Node::Raw->new(rows => \@rows));
}

sub handle_class_tag {
    my ($self, $class, $tag, %args) = @_;
    my $code = <<EOC;
        if (Xsp::Plugin::Ownership::xsp_is_perl_owned(aTHX_ ST(0)))
            delete THIS;
EOC

    my $destructor = ExtUtils::XSpp::Node::Destructor->new
                         (cpp_name => $class->cpp_name,
                          code     => [$code],
                          );
    # TODO exceptions, condition

    return (1, $destructor);
}

sub handle_method_tag {
    my ($self, $method, $tag, %args) = @_;

    $method->set_ret_typemap(_wrap_typemap($method->ret_typemap, own => 0));

    return 1;
}

sub handle_argument_tag {
    my ($self, $argument, $tag, %args) = @_;
    die;

    return 1;
}

sub _wrap_typemap {
    my ($typemap, %args) = @_;

    return ExtUtils::XSpp::Plugin::Ownership::Typemap->new
               (typemap => $typemap, %args);
}

1;
