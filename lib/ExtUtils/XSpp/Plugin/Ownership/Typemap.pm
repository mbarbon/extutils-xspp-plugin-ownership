package ExtUtils::XSpp::Plugin::Ownership::Typemap;

use strict;
use warnings;

use base 'ExtUtils::XSpp::Typemap::wrapped';

sub init {
    my ($self, %args) = @_;
    $self->SUPER::init(%args);

    $self->{OWN} = $args{own};
}

sub cpp_type {
    my ($self) = @_;
    my $cpp_type = $self->SUPER::cpp_type;

    if ($self->_is_reference && $self->type->is_const) {
        $cpp_type = 'const ' . $cpp_type;
    }

    return $cpp_type;
}

sub cleanup_code {
    my ($self, $pvar, $cvar) = @_;

    return sprintf "Xsp::Plugin::Ownership::xsp_set_perl_owned(aTHX_ %s, %s)",
               $pvar, ($self->{OWN} ? 'true' : 'false');
}

sub call_function_code {
    my ($self, @args) = @_;

    if ($self->_is_reference) {
        return $_[2] . ' = &(' . $_[1] . ')';
    } else {
        return $self->SUPER::call_function_code(@args);
    }
}

sub _is_reference {
    my ($self) = @_;

    return $self->{TYPEMAP}->isa('ExtUtils::XSpp::Typemap::reference');
}

1;
