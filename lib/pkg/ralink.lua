return {
    source = {
        type      = 'dist',
        location  = 'http://www.mediatek.com/AmazonS3/Downloads/linux/DPO_RT5572_LinuxSTA_2.6.1.3_20121022.tar.bz2',
        sha256sum = 'da1c12516b1354ebd692a6f3e62a699b47dab9ed87c20365b9fbedbabcc5281e'
    },
    patches = {
        { 'DPO_RT5572_LinuxSTA_2.6.1.3_20121022-no-tftpboot', 1 },
        { 'DPO_RT5572_LinuxSTA_2.6.1.3_20121022-encrypt',     1 }
    },
    build = {
        type = 'make',
        in_source = true
    },
    install = {
        modules = 'os/linux'
    }
}
