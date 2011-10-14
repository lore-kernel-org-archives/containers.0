From: Ted Ts'o <tytso@mit.edu>
Subject: Re: Detecting if you are running in a container
Date: Fri, 14 Oct 2011 11:54:06 -0400
Message-ID: <20111014155406.GC13119@thunk.org>
References: <20111011013201.GA7948@thunk.org>
 <20111011020530.GG16723@count0.beaverton.ibm.com>
 <20111011032523.GB7948@thunk.org>
 <m1ty7ghvvn.fsf@fess.ebiederm.org>
 <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
 <m17h4bfcuv.fsf@fess.ebiederm.org>
 <20111012175702.GA23231@fieldses.org>
 <CAGZ=bqJxadNqaPCW3HufrMmQ57x082=pCDa6-mWLsdtfxHgdPw@mail.gmail.com>
 <20111012190452.GA23845@fieldses.org>
 <CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kyle Moffett <kyle@moffetthome.net>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, "Eric W. Biederman" <ebiederm@xmission.com>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 12, 2011 at 03:12:34PM -0400, Kyle Moffett wrote:
> Well, you're going to need to introduce a bunch of new xattrs to
> handle the namespacing anyways.
> 
> As I understand it you can use RichACLs to grant all the same
> privileges as owner and group, so you can simply map the real
> namespaced owner and group into RichACLs (or another xattr) and force
> the inode uid/gid to be root/root (or maybe nobody/nogroup or
> something).

It's going to be all about mapping tables, and whether the mapping is
done in userspace or kernel space.  For example, you might want to
take a Kerberos principal name, and mapping it to a 128bit identifier
(64 bit realm id + 64 bit user id), and that in turn might require
mapping to some 32-bit Linux uid namespace.

If people want to support multiple 32-bit Linux uid namespaces, then
it's a question of how you name these uid name spaces, and how to
manage the mapping tables outside of kernel, and how the mapping
tables get loaded into the kernel.

> I am of course making it sound a million times easier than it's
> actually likely to be, but I do think it's possible without too many
> odd corner cases.

It's not the corner cases, it's all of the different name spaces that
different system administrators and their sites are going to want to
use, and how to support them all....

And of course, once we start naming uid name spaces, eventually
someone will want to virtualize containers, and then we will have
namespaces for namespaces.  (It's turtles all the way down!  :-)

						- Ted
