From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v4] Introduce v3 namespaced file capabilities
Date: Tue, 13 Jun 2017 18:55:21 -0500
Message-ID: <20170613235521.GC15685__41354.6094707728$1497398133$gmane$org@mail.hallyn.com>
References: <20170507092105.GA67584@inn.lkp.intel.com>
	<20170508044408.GA11400@mail.hallyn.com>
	<CACOXgS9a=avAWZEre1Q1CGjSHeq78Pkq1fYfwPjiyEX-u=B5wQ@mail.gmail.com>
	<20170508181156.GA23112@mail.hallyn.com>
	<9f80188c-df03-066a-5dac-785cc711d064@linux.vnet.ibm.com>
	<20170613171818.GA9070@mail.hallyn.com>
	<74e490f3-3c47-abfa-86ae-0fa0d1ddb43a@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <74e490f3-3c47-abfa-86ae-0fa0d1ddb43a-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, xiaolong.ye-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On 06/13/2017 01:18 PM, Serge E. Hallyn wrote:
> >Quoting Stefan Berger (stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> >>On 05/08/2017 02:11 PM, Serge E. Hallyn wrote:
> >>>Root in a non-initial user ns cannot be trusted to write a traditional
> >>>security.capability xattr.  If it were allowed to do so, then any
> >>>unprivileged user on the host could map his own uid to root in a private
> >>>namespace, write the xattr, and execute the file with privilege on the
> >>>host.
> >>>
> >>>However supporting file capabilities in a user namespace is very
> >>>desirable.  Not doing so means that any programs designed to run with
> >>>limited privilege must continue to support other methods of gaining and
> >>>dropping privilege.  For instance a program installer must detect
> >>>whether file capabilities can be assigned, and assign them if so but set
> >>>setuid-root otherwise.  The program in turn must know how to drop
> >>>partial capabilities, and do so only if setuid-root.
> >>Hi Serge,
> >>
> >>
> >>   I have been looking at patch below primarily to learn how we could
> >>apply a similar technique to security.ima and security.evm for a
> >>namespaced IMA. From the paragraphs above I thought that you solved
> >>the problem of a shared filesystem where one now can write different
> >>security.capability xattrs by effectively supporting for example
> >>security.capability[uid=1000] and security.capability[uid=2000]
> >>written into the filesystem. Each would then become visible as
> >>security.capability if the userns mapping is set appropriately.
> >>However, this doesn't seem to be how it is implemented. There seems
> >>to be only a single such entry with uid appended to it and, if it
> >>was a shared filesystem, the first one to set this attribute blocks
> >>everyone else from writing the xattr. Is that how it works? Would
> >Yes, that's how this works here.  I'd considered allowing multiple
> >entries, but I didn't feel that was needed for this case.  In a previous
> >implementation (which is probably in the lkml archives somewhere) I
> >supported variable length xattr so that multiple containers could
> >each write a value tagged with their own userns.rootid.  Instead,
> >in the final version, if root in any parent container writes an
> >xattr, it will take effect in child user namespaces.  Which is
> >sensible - the parent presumbly laid out the filesystem to create
> >the child container.
> >
> >>that work differently with an overlay filesystem ? I think a similar
> >Certainly an overlay filesystem should be an easy case as the container
> >can have its own copy of the inode with its own xattr.  Btrfs/zfs
> >would be nicer as the whole file wouldn't need to be copied.
> >
> >>model could also work for IMA, but maybe you have some thoughts. The
> >>only thing I would be concerned about is blocking the parent
> >>container's root user from setting an xattr.
> >So if you have container c1 creating child container c2 on host h1,
> >then if c1 creates an xattr, can c2 not use that?  And if h1 writes it,
> >can c1 and c2 use it?
> 
> In the case of IMA appraisal the extended attribute security.ima
> would be a signature. For c1 and c2 to use that file they would all
> have to have the same key on their (isolated IMA namespace )
> keyring. I think this type of setup could be arranged.

Ok.  If it's too much of a restriction then certainly we can make
it more flexible.  I don't think we want to support too many versions
of magic in this code, so if there's a chance we'll want to make it
more flexible later, then perhaps we should discuss the other options
in more detail now.

> Following your attack description in the introduction I would say
> that we would want to prevent malicious modification of a
> security.ima extended attribute:
> 
> "Root in a non-initial user ns cannot be trusted to write a traditional security.ima xattr. If it were allowed to do so, then any unprivileged user on the host could map his own uid to root in a private namespace, write the signature in the security.ima xattr, and prevent the file from being accessible on the host."

Of course.

The way this is handled with nsfscaps is not by just forbidding the
write, but by only respecting the xattr if the rootid which was
written in the xattr (which is translated and enforced by the kernel
at write time) is root in the caller's user_ns or a parent thereof.

I think that would suffice for ima as well?

> >If they can't, then I guess for IMA multiple xattrs would need to be
> >supported.
> 
> I am not sure about that. I suppose any extended attribute
> modifications would have to be designed for the case where a shared
> filesystem is used that also shares the extended attributes, not
> assuming an overlay filesystem that automatically isolates the
> extend attributes. With the shared filesystem I'd like to prevent
> any type of setting of extended attributes by a child container or
> more generally anyone mounting it as a '2nd consumer', which would
> make it a shared filesystem. Only the process that mounts a
> filesystem as the '1st consumer' would be able to set the extended
> attributes.

Right, again that's currently the case in the nscaps patch.

>  I am assuming that using an overlay fs would always make
> you the '1st consumer' -- I would hope that these conditions could
> be detected. And probably the process should also write along its
> host uid as part of writing out the xattr.

I think that's what the rootid in the nscaps xattr is.

>  If all extended
> attributes were to support this model, maybe the 'uid' could be
> associated with the 'name' of the xattr rather than its 'value' (not
> sure whether that's possible).

Right, I missed that in your original email when I saw it this morning.
It's not what my patch does, but it's an interesting idea.  Do you have
a patch to that effect?  We might even be able to generalize that to
namespace any security.* xattrs.  Wouldn't be automatically enabled
for anything but ima and capabilities, but we could make the infrastructure
generic and re-usable.
