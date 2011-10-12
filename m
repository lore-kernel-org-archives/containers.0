From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Detecting if you are running in a container
Date: Wed, 12 Oct 2011 13:57:02 -0400
Message-ID: <20111012175702.GA23231@fieldses.org>
References: <20111007160113.GB14201@tango.0pointer.de>
 <m17h4g2jqy.fsf@fess.ebiederm.org>
 <20111010163140.GA22191@tango.0pointer.de>
 <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
 <20111011013201.GA7948@thunk.org>
 <20111011020530.GG16723@count0.beaverton.ibm.com>
 <20111011032523.GB7948@thunk.org>
 <m1ty7ghvvn.fsf@fess.ebiederm.org>
 <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
 <m17h4bfcuv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <m17h4bfcuv.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Theodore Tso <tytso@MIT.EDU>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Tue, Oct 11, 2011 at 02:16:24PM -0700, Eric W. Biederman wrote:
> It actually isn't much complexity and for the most part the code that
> I care about in that area is already merged.  In principle all I care
> about are having the identiy checks go from:
> (uid1 == uid2) to ((user_ns1 == user_ns2) && (uid1 == uid2))
> 
> There are some per subsystem sysctls that do make sense to make per
> subsystem and that work is mostly done.  I expect there are a few
> more in the networking stack that interesting to make per network
> namespace.
> 
> The only real world issue right now that I am aware of is the user
> namespace aren't quite ready for prime-time and so people run into
> issues where something like sysctl -a during bootup sets a bunch of
> sysctls and they change sysctls they didn't mean to.  Once the
> user namespaces are in place accessing a truly global sysctl will
> result in EPERM when you are in a container and everyone will be
> happy. ;)
> 
> 
> Where all of this winds up interesting in the field of oncoming kernel
> work is that uids are persistent and are stored in file systems.  So
> once we have all of the permission checks in the kernel tweaked to care
> about user namespaces we next look at the filesystems.   The easy
> initial implementation is going to be just associating a user namespace
> with a super block.  But farther out being able to store uids from
> different user namespaces on the same filesystem becomes an interesting
> problem.

Yipes.  Why would anyone want to do that?

--b.

> We already have things like user mapping in 9p and nfsv4 so it isn't
> wholly uncharted territory.  But it could get interesting.   Just
> a heads up.
