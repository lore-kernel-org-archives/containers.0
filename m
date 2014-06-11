From: James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Subject: libcontainer for linux
Date: Wed, 11 Jun 2014 23:14:19 +0000
Message-ID: <1402528459.2523.89.camel__30751.1901985437$1402528951$gmane$org@dabdike.int.hansenpartnership.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Language: en-US
Content-ID: <199289E40FEB1140BACCD094D055219A-ruSsrxOD6xDby3iVrkZq2A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org" <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: "cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org" <devel-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
List-Id: containers.vger.kernel.org

[Cc'd cgroups because this affects cgroups as well as containers]

Hi All,

As some of you know, Parallels has been running a libct project to
expose the granular capabilities of containers for a while:

https://github.com/xemul/libct

This is a buildable linkable library with C/C++ and Python bindings.

At around the same time, Docker also started a libcontainer project
written in go so they could orchestrate containers natively instead of
relying on toolkits like LXC:

https://github.com/dotcloud/docker/tree/master/pkg/libcontainer/

This is a go language based project which currently only provides go
bindings.

As of yesterday, we agreed to merge both projects.  Initially the merger
will be a kind of chimera which really compiles the guts of libct and
libcontainer separately to provide all the bindings (Go/C/C++/Python)
but the long term goal is that we would merge the two so that the Go
part of libcontainer uses the libct API so that we eventually unify the
code paths.  When the code paths are unified it will give us the ability
to deploy docker on to the 2.6.32 OpenVZ kernel, and it should give
Docker the ability to do checkpoint/restore and live migration via the
CRIU project (the interface to which is also being integrated into
libct).

Just in the interests of full disclosure from the libct side, this is
our current list of requirements:

     1. C/C++ bindings                                      +
     2. Python bindings                                     +
     3. Fine grained support for namespaces and cgroups     +
     4. Extendable support for different private FS         +/-
     5. Extendable support for different NICs               +/-
     6. Support for external bind mounts                    +
     7. Ability to enter a CT                               +
     8. Ability to configure running CT                     -/+
     9. Integration with CRIU for checkpointing             -
    10. Integration with CRIU for migration                 -
    11. Ability to operate on remote host                   -
    12. Ability to be used by non-root App                  +
    13. Ability to resurrect after sudden App crash         -
    14. Ability to work on OpenVZ kernel (backend)          -
    15. Ability to run libct supporting tools on older (OpenVZ) kernels
        (depends on above)                                  -
    16. Theoretical ability to be compiled on Solaris/BSD for unified
        zones and jails management                          -
        (does it make any sense?)
    17. Integration with Docker libcontainer to give any container
        system implementing the ability to deploy docker
        packages                                            +/-

Where + means implemented, - means to be implemented and +/- means in
process of being implemented.  Some of these requirements may may be
rendered moot by the merger of the projects, but I thought this could be
a way of launching the discussion for anyone who's interested.

The purpose of this library is twofold: The main reason is to expose
application container features in a manner independent of all of our
current container "flavours" (an OpenVZ container is different from an
LXC container, which is different from a docker container etc.) which
should allow people who want to create new and interesting containerised
applications not to have to worry about what platform they pick.  The
second is because we can use libcontainers to base all of our current
toolkits on.  This may sound esoteric, but it would give you the ability
to run, say, docker or lxc containers securely on an OpenVZ 2.6.32
kernel (something that can't be done easily today).

At some point there will be a development list for libcontainers, but
for now containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org would seem to be usable
for this.

James
