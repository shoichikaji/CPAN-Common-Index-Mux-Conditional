requires 'perl', '5.008001';
requires 'CPAN::Common::Index';
requires 'Module::Load';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

