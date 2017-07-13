From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Wed, 12 Jul 2017 21:34:25 -0500
Message-ID: <20170713023425.GA24103@mail.hallyn.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com>
	<20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170713011554.xwmrgkzfwnibvgcu-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, tycho-FCduhRhOUaTQT0dZR+AlfA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, christian.brauner-cl+VPiYnx/1AfugRpC6u6w@public.gmane.org, amir73il-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Theodore Ts'o (tytso-3s7WtUTddSA@public.gmane.org):
> I'm really confused what problem that is trying to be solved, here,
> but it **feels** really, really wrong.

Hi,

The intro to my original patch might help (or maybe not), as it
has a different motivating text:

http://lkml.org/lkml/2016/11/19/158

We want file capabilities to be supported in unprivileged containers,
so that a piece of software can count on them being available rather
than having to supporting multiple ways of getting+dropping privilege
(for instance, being installed as uid 1000 with cap_net_raw=pe, versus
being installed setuid-root and being expected to do PR_SET_KEEPCAPS
and setuid).

If subuids 10000-20000 are delegated to uid 1001 on the host, and uid
1001 sets up a container with subuid 100000 mapped to container uid 0,
then the container root should be able to write file capabilities
which affect (that is, delegate container root's privilege to) all ids
over which it has privilege (all uids mapped into the container), but
should not have privilege over any uids not mapped into the container.
With regular file capabilities, this is impossible, since any filecap
he writes can then be exercised on the host by uid 1000.

The point of this set (and the ones before it) is to make it so that
the filecap written by the container root is tagged on disk as belonging
to subuid 100000.

> Why do we need to store all of this state on a per-file basis, instead
> of some kind of per-file system or per-container data structure?

This needs to be writeable by an unprivileged user, with no help from
the admin.  AFAICS that rules out per-fs data structure.

Note we are not assuming a filesystem per container.  The typical case
is (for instance) ~/.local/share/lxc/c1/rootfs being the root of
container c1's filesystem.  Mounting a filesystem from inside a user
namespace is still mostly science fiction today.

> And how many of these security.foo@uid=bar xattrs do you expect there
> to be?  How many "foo", and how many "bar"?

For now I'm expecting two foos - security and ima.  The '@uid=bar' is
generic enough that it *can* be re-used for a different kind of
property if we decide to later, but I have no intention of adding
anything.

Casey has mentioned 'smack=', but i think only to keep the option open.
I don't believe he has concrete plans.

> Maybe I missed the full write up, in which case please send me a link
> to the full writeup --- ideally in the form of a design doc that
> explains the problem statement, gives some examples of how it's going
> to be used, what were the other alternatives that were considered, and
> why they were rejected, etc.

As I'd mentioned in an even older patch, http://lkml.org/lkml/2016/5/18/622 ,
I had considered using a completely separate xattr name, but that would
have required invasive userspace changes.

There's no design doc as such, mainly a progressive series of patches to
lkml.  I am very seriously considering writing a paper to detail both
this design and the user ns design in general, as it has become clear
(in unrelated conversations) there is still a lot of confusiong out
there regarding uid namespaces and targeted capabilities.  But it's not
written yet.

-serge
