From: Kyle Moffett <kyle@moffetthome.net>
Subject: Re: Detecting if you are running in a container
Date: Wed, 12 Oct 2011 15:12:34 -0400
Message-ID: <CAGZ=bqJjgmtBfyXJ2eK1C0PfzkgBVWFTjkTYkC211ZT+-5f-UQ@mail.gmail.com>
References: <20111010163140.GA22191@tango.0pointer.de> <m1mxd8lg0x.fsf_-_@fess.ebiederm.org>
 <20111011013201.GA7948@thunk.org> <20111011020530.GG16723@count0.beaverton.ibm.com>
 <20111011032523.GB7948@thunk.org> <m1ty7ghvvn.fsf@fess.ebiederm.org>
 <203BBB0D-293D-4BFB-A57B-41C56F58F9B3@mit.edu> <m17h4bfcuv.fsf@fess.ebiederm.org>
 <20111012175702.GA23231@fieldses.org> <CAGZ=bqJxadNqaPCW3HufrMmQ57x082=pCDa6-mWLsdtfxHgdPw@mail.gmail.com>
 <20111012190452.GA23845@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111012190452.GA23845@fieldses.org>
Sender: linux-kernel-owner@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, Theodore Tso <tytso@mit.edu>, Matt Helsley <matthltc@us.ibm.com>, Lennart Poettering <mzxreary@0pointer.de>, Kay Sievers <kay.sievers@vrfy.org>, linux-kernel@vger.kernel.org, harald@redhat.com, david@fubar.dk, greg@kroah.com, Linux Containers <containers@lists.osdl.org>, Linux Containers <lxc-devel@lists.sourceforge.net>, "Serge E. Hallyn" <serge@hallyn.com>, Daniel Lezcano <daniel.lezcano@free.fr>, Paul Menage <paul@paulmenage.org>
List-Id: containers.vger.kernel.org

On Wed, Oct 12, 2011 at 15:04, J. Bruce Fields <bfields@fieldses.org> w=
rote:
> On Wed, Oct 12, 2011 at 02:25:04PM -0400, Kyle Moffett wrote:
>> On Wed, Oct 12, 2011 at 13:57, J. Bruce Fields <bfields@fieldses.org=
> wrote:
>> > On Tue, Oct 11, 2011 at 02:16:24PM -0700, Eric W. Biederman wrote:
>> >> Where all of this winds up interesting in the field of oncoming k=
ernel
>> >> work is that uids are persistent and are stored in file systems. =
=C2=A0So
>> >> once we have all of the permission checks in the kernel tweaked t=
o care
>> >> about user namespaces we next look at the filesystems. =C2=A0 The=
 easy
>> >> initial implementation is going to be just associating a user nam=
espace
>> >> with a super block. =C2=A0But farther out being able to store uid=
s from
>> >> different user namespaces on the same filesystem becomes an inter=
esting
>> >> problem.
>> >
>> > Yipes. =C2=A0Why would anyone want to do that?
>>
>> Consider an NFS file server providing collaborative access to multip=
le
>> independently managed domains (EG: several different universities),
>> each with their own LDAP userid database and Kerberos services.
>>
>> The common server is in its own realm and allows cross-realm
>> authentication to the other university realms, using the origin real=
m
>> to decide what namespace to map each user into.
>>
>> If you are just doing read-only operations then you don't need any
>> kind of namespace persistence on the NFS server's storage. =C2=A0On =
the
>> other hand, if you want to allow users to collaborate and create ACL=
s
>> then you need something dramatically more involved.
>
> Yeah, OK, I suppose I'd imagined mapping into the server's id space
> somehow for that case, but I suppose this would be cleaner. =C2=A0Sti=
ll,
> seems like a big pain....
>
>> On the wire, the kerberos server would simply identify each NFSv4 AC=
L
>> entry with a particular realm ID, but in the backend it would need
>> some filesystem-level disambiguation (possibly the recently-proposed
>> RichACL features?)
>
> That doesn't help with owner and group.

Well, you're going to need to introduce a bunch of new xattrs to
handle the namespacing anyways.

As I understand it you can use RichACLs to grant all the same
privileges as owner and group, so you can simply map the real
namespaced owner and group into RichACLs (or another xattr) and force
the inode uid/gid to be root/root (or maybe nobody/nogroup or
something).

I am of course making it sound a million times easier than it's
actually likely to be, but I do think it's possible without too many
odd corner cases.

Cheers,
Kyle Moffett
