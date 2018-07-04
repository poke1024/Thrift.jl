using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    ExecutableProduct(prefix, "thrift", :thrift),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/tanmaykm/JuliaThriftBuilder/releases/download/julia0.6-thrift0.11.0-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, :glibc) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.aarch64-linux-gnu.tar.gz", "4e596c06a58a3f0315fed4be37e0a8e764eccb0693252f45ff15395ea89d3110"),
    Linux(:aarch64, :musl) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.aarch64-linux-musl.tar.gz", "5a454a48febc799416fa174c16621f66856e75b49ac6d52f0325871d30abb584"),
    Linux(:armv7l, :glibc, :eabihf) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.arm-linux-gnueabihf.tar.gz", "97be47ab4f7c3725f4d3d2fa3022b09fda914523822f24a15bd7f7c286b57c6e"),
    Linux(:armv7l, :musl, :eabihf) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.arm-linux-musleabihf.tar.gz", "31715516cdffeb7ddb59d0a3f9218fb9ad666d7c9d497612bd7ba2ce50a87d5a"),
    Linux(:i686, :glibc) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.i686-linux-gnu.tar.gz", "d41cd7da24714156940feb934713acfdcb67bd438871b99c53fc59406deb6919"),
    Linux(:i686, :musl) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.i686-linux-musl.tar.gz", "f8501430302b0307531a7924c1337352f37c311ad0476b1aaa64f2caeada8d3d"),
    Linux(:powerpc64le, :glibc) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.powerpc64le-linux-gnu.tar.gz", "ec684d29f0bc3d3bb2fbfd3ee3649a7f9bac78f8f5a1f0ea70c4c6be185942df"),
    MacOS(:x86_64) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.x86_64-apple-darwin14.tar.gz", "af12e5c6e96ddb4eceb8b407183c333d16743f389f8a08791a3b376143b91c5d"),
    Linux(:x86_64, :glibc) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.x86_64-linux-gnu.tar.gz", "3296dd2f3746787b8f9c680344a86973b9bde50f2a3defde5b87fbb9ee91a9fe"),
    Linux(:x86_64, :musl) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.x86_64-linux-musl.tar.gz", "6cb4679a5759b1c005bc36afa76a9a092c792bea030949aa40f4c9565750f223"),
    FreeBSD(:x86_64) => ("$bin_prefix/JuliaThriftBuilder.v1.0.0.x86_64-unknown-freebsd11.1.tar.gz", "c3e16db8903e725941500894ccdcd05bfc896919512703ca0e2af1abb7863c4a"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
if haskey(download_info, platform_key())
    url, tarball_hash = download_info[platform_key()]
    if unsatisfied || !isinstalled(url, tarball_hash; prefix=prefix)
        # Download and install binaries
        install(url, tarball_hash; prefix=prefix, force=true, verbose=verbose)
    end
elseif unsatisfied
    # If we don't have a BinaryProvider-compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform $(triplet(platform_key())) is not supported by this package!")
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products)
