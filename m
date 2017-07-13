From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Thu, 13 Jul 2017 16:12:37 -0500
Message-ID: <87mv886ny2.fsf__48066.0181529403$1499980864$gmane$org@xmission.com>
References: <87mv89iy7q.fsf@xmission.com>
	<20170712170346.GA17974@mail.hallyn.com> <877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
	<87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
	<87k23cb6os.fsf@xmission.com>
	<847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
	<87bmoo8bxb.fsf@xmission.com> <20170713194842.GB4895@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20170713194842.GB4895-7LNsyQBKDXoIagZqoN9o3w@public.gmane.org> (Serge E. Hallyn's
	message of "Thu, 13 Jul 2017 14:48:42 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

"Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:

> Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
>> Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:
>> 
>> > On 07/13/2017 01:14 PM, Eric W. Biederman wrote:
>> >> Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> writes:
>> >>
>> >>> On Thu, Jul 13, 2017 at 07:11:36AM -0500, Eric W. Biederman wrote:
>> >>>> The concise summary:
>> >>>>
>> >>>> Today we have the xattr security.capable that holds a set of
>> >>>> capabilities that an application gains when executed.  AKA setuid root exec
>> >>>> without actually being setuid root.
>> >>>>
>> >>>> User namespaces have the concept of capabilities that are not global but
>> >>>> are limited to their user namespace.  We do not currently have
>> >>>> filesystem support for this concept.
>> >>> So correct me if I am wrong; in general, there will only be one
>> >>> variant of the form:
>> >>>
>> >>>     security.foo@uid=15000
>> >>>
>> >>> It's not like there will be:
>> >>>
>> >>>     security.foo@uid=1000
>> >>>     security.foo@uid=2000
>> >>>
>> >>> Except.... if you have an Distribution root directory which is shared
>> >>> by many containers, you would need to put the xattrs in the overlay
>> >>> inodes.  Worse, each time you launch a new container, with a new
>> >>> subuid allocation, you will have to iterate over all files with
>> >>> capabilities and do a copy-up operations on the xattrs in overlayfs.
>> >>> So that's actually a bit of a disaster.
>> >>>
>> >>> So for distribution overlays, you will need to do things a different
>> >>> way, which is to map the distro subdirectory so you know that the
>> >>> capability with the global uid 0 should be used for the container
>> >>> "root" uid, right?
>> >>>
>> >>> So this hack of using security.foo@uid=1000 is *only* useful when the
>> >>> subcontainer root wants to create the privileged executable.  You
>> >>> still have to do things the other way.
>> >>>
>> >>> So can we make perhaps the assertion that *either*:
>> >>>
>> >>>     security.foo
>> >>>
>> >>> exists, *or*
>> >>>
>> >>>     security.foo@uid=BAR
>> >>>
>> >>> exists, but never both?  And there BAR is exclusive to only one
>> >>> instances?
>> >>>
>> >>> Otherwise, I suspect that the architecture is going to turn around and
>> >>> bite us in the *ss eventually, because someone will want to do
>> >>> something crazy and the solution will not be scalable.
>> >> Yep.  That is what it looks like from here.
>> >>
>> >> Which is why I asked the question about scalability of the xattr
>> >> implementations.  It looks like trying to accomodate the general
>> >> case just gets us in trouble, and sets unrealistic expectations.
>> >>
>> >> Which strongly suggests that Serge's previous version that
>> >> just reved the format of security.capable so that a uid field could
>> >> be added is likely to be the better approach.
>> >>
>> >> I want to see what Serge and Stefan have to say but the case looks
>> >> pretty clear cut at the moment.
>
> I'm fine with that.  Now, we'll be doing the enforcement at xattr
> write time, meaning someone *can* come up with an fs image with >1
> such xattrs.  Which is *fine*, I believe, it won't break anything
> security-wise, and our goal is only to stop users from thinking it
> is legitimate two write multiple such xattrs, so that they don't later
> bug the fs folks like Ted saying "hey why can't I write 1000 of these,
> I think that's a bug."
>
> So at xattr write time,
>
> 	1. if there is already an xattr, and it is either the global
> 	non-namespaced xattr, or it has kuid=X where X is the kuid
> 	mapped to root in a parent of the container, then we refuse
> 	the write
> 	2. if there is already an xattr, and it is for a kuid=X where
> 	X is mapped into the container, then we overwrite the existing
> 	xattr.
>
> At read/use time, we use the rules we have now.
>
> Does that seem reasonable?

That sounds like it would keep us to one xattr of any given type so yes.

It occurs to me while I am writing this that this is also important
for ima/evm.  There is an xattr that has a hash of all of the other
security relevant xattrs.   Without a limit on the number of xattrs
calculating that security xattr could become time prohibitive.


Eric
