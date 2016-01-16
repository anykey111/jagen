-- Android rules

package { 'android-cmake' }

package { 'cmake-modules' }

package { 'libtool', 'host' }

package { 'chicken', 'host',
    { 'build',
        { 'android-cmake', 'unpack' }
    }
}

package { 'chicken-eggs', 'host',
    { 'install',
        { 'chicken', 'install', 'host' }
    }
}

local function firmware_package(rule)
    rule.config = 'target'
    table.insert(rule, { 'install', { 'firmware', 'unpack' } })
    package(rule)
end

package { 'firmware',
    { 'install',
        { 'hi-utils', 'install', 'target' },
        { 'chicken',        'install', 'target' },
        { 'chicken-eggs',   'install', 'target' },
        { 'ffmpeg',         'install', 'target' },
        { 'karaoke-player', 'install', 'target' },
        { 'libuv',          'install', 'target' },
    },
    { 'strip'  },
    { 'deploy' }
}

firmware_package { 'hi-utils',
    { 'build',
        { 'android-cmake', 'unpack' },
        { 'cmake-modules', 'unpack' },
    }
}

firmware_package { 'chicken',
    { 'build',
        { 'chicken', 'install', 'host' }
    }
}

firmware_package { 'chicken-eggs',
    { 'install',
        { 'chicken-eggs', 'install', 'host'   },
        { 'chicken',      'install', 'target' },
        { 'sqlite',       'install', 'target' },
    }
}

firmware_package { 'sqlite' }

firmware_package { 'ffmpeg' }

firmware_package { 'karaoke-player',
    { 'build',
        { 'astindex',      'unpack'            },
        { 'cmake-modules', 'unpack'            },
        { 'chicken-eggs',  'install', 'host'   },
        { 'chicken-eggs',  'install', 'target' },
        { 'ffmpeg',        'install', 'target' },
        { 'libuv',         'install', 'target' },
    },
    { 'install' }
}

package { 'astindex',
    { 'unpack', { 'karaoke-player', 'unpack' } }
}

firmware_package { 'libuv',
    build  = {
        options = '--disable-static'
    }
}