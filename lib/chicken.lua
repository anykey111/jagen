-- CHICKEN Scheme

define_rule { 'chicken', 'host' }

define_rule { 'chicken-eggs', 'host' }

define_rule { 'chicken', 'target',
    { 'configure', { 'chicken', 'install', 'host' } }
}

define_rule { 'chicken-eggs', 'target',
    requires = {
        'dbus',
        'sqlite',
    },
    { 'configure',
        { 'chicken-eggs', 'install', 'host' }
    }
}

if Jagen.flag('new_chicken') then
    define_rule { 'chicken', 'host',
        requires = { 'chicken-boot' }
    }
end
