From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Detecting if you are running in a container
Date: Tue, 01 Nov 2011 06:38:23 -0700
Message-ID: <m1ty6ormi8.fsf@fess.ebiederm.org>
References: <20111011013201.GA7948@thunk.org>
	<20111011020530.GG16723@count0.beaverton.ibm.com>
	<20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org>
	<203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu>
	<m17h4bfcuv.fsf@fess.ebiederm.org>
	<20111012175702.GA23231@fieldses.org>
	<CAGZ=bqJxadNqaPCW3HufrMmQ57x082=pCDa6-mWLsdtfxHgdPw@mail.gmail.com>
	<20111012190452.GA23845@fieldses.org>
	<CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com>
	<20111014155406.GC13119@thunk.org> <m17h478n5k.fsf@fess.ebiederm.org>
	<4E98B088.5030400@zytor.com> <m1ipnpl1c9.fsf@fess.ebiederm.org>
	<4EADAF69.80008@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EADAF69.80008@zytor.com> (H. Peter Anvin's message of "Sun, 30
	Oct 2011 13:11:21 -0700")
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ted Ts'o <tytso@mit.edu>, Kyle Moffett <kyle@moffetthome.net>, "J. Bruce Fields" <bfields@fieldses.org>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

"H. Peter Anvin" <hpa@zytor.com> writes:

> On 10/16/2011 02:42 AM, Eric W. Biederman wrote:
>>>
>>> Something based on UUIDs, perhaps?
>>>
>>> UUIDs are kind of exactly this, after all... a single namespace designed
>>> to be large and random enough to be globally unique without a central
>>> registration authority.
>> 
>> mount --bind /proc/self/ns/net /var/run/netns/<name>
>> 
>> When we want to refer to the namespace in syscalls we pass a file
>> descriptor we received from opening the namespace reference object.
>> 
>> That moves the entire naming problem into the file namespace.
>> 
>
> That doesn't solve what I think of as the *real* problem.

It solves the problem of not needing a namespace of namespaces and
it solves the problem not requiring universal agreement between all
filesystems on all operating systems on how things should look.

In not precluding different solutions it makes a large stride forward.

> The real problem is just another instance of what I sometimes refer to
> as the "alien metadata problem": the alien metadata problem (which crops
> up in *all kinds* of contexts, including containers, namespaces, virtual
> machines, building distribution disk images, and backups) is the fact
> that you would like to be able to store, manipulate and preserve, on
> disk and in a mounted filesystem, a set of metadata which may not be the
> "currently active" metadata.

When you throw network filesystems with different notions of meta-data
things get even more interesting.

> There are two forms of "solutions" to this: one where the filesystem
> still only contains one set of metadata, but it is not currently active,
> and one where the filesystem contains multiple sets of metadata for the
> same files at the same time, any one of which can be active (and
> different ones may be active for different namespaces.)

There is an important tool that seems to be missing from your toolbox.
- Mapping the metadata on the file into different contexts.

The way I see it classic unix filesystems have exactly one context
that their meta-data is expected to work in.  The context in which
the filesystem is mounted.

However it is very easy to conceive of that context being specified
at a per inode granularity.  In which case at least the backup and
the distribution disk image problem can be solved by trivially
specifying a different context, and associating a user namespace with
that context.  Then you switch into the user namespace to manipulate
"alien metadata".

Where mapping comes in is when those files are accessed from
from another context besides the one where all of their metadata
falls.  At which point you can map all of the files to be owned
by the user who is responsible for making backups.  The mapping
is a bit like the root squash setting.


For the common case I expect we will settle on a well defined acl across
the native unix filesystems that allows us to make this persistent.  For
network filesystems with their broader interoperability requirements how
to specify this gets a little more interesting.

For purposes of implementation it doesn't matter to me if that acl is
a uuid or a unique string.  For management of the data it might.

How I expect a native linux filesystem to work when it encounters a
filesystem with a user namespace acl is that it will work like nfsv4
and do an upcall into userspace, to ask the appropriate userspace
how do I understand this acl.  The the userapce mapping agent will
say.  Oh.  You want the usernamespace for "hpa-backups"?  Let's see:
/var/run/userns/hpa-backups exists let me just tell the kernel about
that mapping.  Or perhaps the usernamespace does not exist so the
mapping daemon would go out and create it be consulting configuration
files in etc to know that everything in "hpa-backups" should a child
user namespace with the user "hpa" being able to switch into that
usernamespace without root permission.

Files with meta-data for more than one usernamespace/context I expect
to work similarly.  Care needs to be take that it doesn't drive the
administrator crazy.

Eric
