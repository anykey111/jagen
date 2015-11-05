-- Sigma rules

local function rootfs_package(rule)
    rule.template = {
        config = 'target',
        { 'build', { 'rootfs', 'build' } },
    }
    package(rule)
end

-- base

package { 'ast-files' }

package { 'linux',
    source = { branch = 'ast50' }
}

package { 'xsdk',
    source = '${cpukeys}.tar.gz'
}

package { 'ucode', 'target',
    { 'unpack',  { 'mrua',     'build'  } },
    { 'install', { 'firmware', 'unpack' } }
}

-- tools

package { 'make', 'tools' }

if jagen.flag('debug') then
    package        { 'gdb', 'host' }
    rootfs_package { 'gdbserver' }
    package        { 'valgrind', 'rootfs' }
    rootfs_package { 'strace',   'rootfs' }
end

-- host

package { 'astindex',
    { 'unpack', { 'karaoke-player', 'unpack' } }
}

package { 'chicken', 'host' }

package { 'chicken-eggs', 'host',
    { 'install',
        needs = { 'chicken' }
    }
}

package { 'ffmpeg', 'host',
    { 'build', { 'ast-files', 'unpack' } }
}

package { 'utils', 'host' }

package { 'karaoke-player', 'host',
    source = { branch = 'master' },
    { 'build',
        { 'astindex', 'unpack' },
        needs = {
            'chicken',
            'chicken-eggs',
            'ffmpeg',
            'libuv'
        }
    }
}

package { 'libtool', 'host' }

-- kernel

local function kernel_package(rule)
    rule.template = {
        config = 'target',
        { 'build', { 'kernel', 'build' } },
    }
    package(rule)
end

package { 'kernel', 'target',
    source = { branch = 'sigma-2.6' },
    { 'build',
        { 'ezboot', 'build'  },
        { 'linux',  'unpack' },
        { 'rootfs', 'build'  },
    },
    { 'install' },
    { 'image',  { 'rootfs', 'install' } }
}

kernel_package { 'loop-aes' }

kernel_package { 'ralink' }

-- rootfs

package { 'rootfs', 'target',
    { 'build',
        { 'ast-files',  'unpack'            },
        { 'make',       'install', 'tools'  },
        { 'xsdk',       'unpack'            },
    },
    { 'install',
        { 'busybox',    'install'           },
        { 'gnupg',      'install'           },
        { 'kernel',     'install'           },
        { 'loop-aes',   'install'           },
        { 'mrua',       'modules'           },
        { 'ntpclient',  'install'           },
        { 'ralink',     'install'           },
        { 'util-linux', 'install'           },
        { 'utils',      'install', 'target' },
    }
}

package { 'mrua', 'target',
    { 'build',   { 'kernel',   'build'  } },
    { 'install', { 'firmware', 'unpack' } },
    { 'modules'  }
}

rootfs_package { 'ezboot',
    { 'build',
        { 'make', 'install', 'tools' }
    }
}

rootfs_package { 'busybox',
    { 'patch', { 'ast-files', 'unpack' } }
}

rootfs_package { 'gnupg' }

rootfs_package { 'ntpclient' }

rootfs_package { 'util-linux' }

rootfs_package { 'utils', 'target',
    { 'build',
        { 'dbus',  'install', 'target' },
        { 'gpgme', 'install' },
    }
}

rootfs_package { 'libgpg-error' }

rootfs_package { 'libassuan',
    { 'build', { 'libgpg-error', 'install' } }
}

rootfs_package { 'gpgme',
    { 'build', { 'libassuan', 'install' } }
}

-- firmare

local function firmware_package(rule)
    rule.template = {
        config = 'target',
        { 'install', { 'firmware', 'unpack' } },
    }
    package(rule)
end

firmware_package { 'firmware', 'target',
    { 'material',
        { 'mrua', 'build' }
    },
    { 'install',
        { 'ezboot', 'install' },
        { 'kernel', 'image'   },
        { 'mrua',   'install' },
        needs = {
            'karaoke-player',
            'rsync',
            'wpa_supplicant',
        }
    },
    { 'strip' }
}

firmware_package { 'karaoke-player',
    source = { branch = 'master' },
    { 'build',
        { 'astindex',     'unpack'            },
        { 'mrua',         'build'             },
        { 'chicken-eggs', 'install', 'host'   },
        needs = {
            'chicken-eggs',
            'connman',
            'dbus',
            'ffmpeg',
            'freetype',
            'libass',
            'libpng',
            'libuv',
            'soundtouch'
        }
    }
}

firmware_package { 'chicken',
    { 'build', { 'chicken',  'install', 'host' } }
}

firmware_package { 'chicken-eggs',
    { 'install',
        { 'chicken-eggs', 'install', 'host'   },
        needs = {
            'chicken',
            'dbus',
            'sqlite'
        }
    }
}
