From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH v2] xattr: Enable security.capability in user namespaces
Date: Thu, 13 Jul 2017 12:49:20 -0500
Message-ID: <87bmoo8bxb.fsf@xmission.com>
References: <1499785511-17192-1-git-send-email-stefanb@linux.vnet.ibm.com>
	<1499785511-17192-2-git-send-email-stefanb@linux.vnet.ibm.com>
	<87mv89iy7q.fsf@xmission.com> <20170712170346.GA17974@mail.hallyn.com>
	<877ezdgsey.fsf@xmission.com>
	<74664cc8-bc3e-75d6-5892-f8934404349f@linux.vnet.ibm.com>
	<20170713011554.xwmrgkzfwnibvgcu@thunk.org>
	<87y3rscz9j.fsf@xmission.com>
	<20170713164012.brj2flnkaaks2oci@thunk.org>
	<87k23cb6os.fsf@xmission.com>
	<847ccb2a-30c0-a94c-df6f-091c8901eaa0@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <847ccb2a-30c0-a94c-df6f-091c8901eaa0-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> (Stefan
	Berger's message of "Thu, 13 Jul 2017 13:33:53 -0400")
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
Cc: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James.Bottomley-d9PhHud1JfjCXq6kfMZ53/egYHeGw8Jk@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org, lkp-JC7UmRfGjtg@public.gmane.org
List-Id: containers.vger.kernel.org

Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org> writes:

> On 07/13/2017 01:14 PM, Eric W. Biederman wrote:
>> Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> writes:
>>
>>> On Thu, Jul 13, 2017 at 07:11:36AM -0500, Eric W. Biederman wrote:
>>>> The concise summary:
>>>>
>>>> Today we have the xattr security.capable that holds a set of
>>>> capabilities that an application gains when executed.  AKA setuid root exec
>>>> without actually being setuid root.
>>>>
>>>> User namespaces have the concept of capabilities that are not global but
>>>> are limited to their user namespace.  We do not currently have
>>>> filesystem support for this concept.
>>> So correct me if I am wrong; in general, there will only be one
>>> variant of the form:
>>>
>>>     security.foo@uid=15000
>>>
>>> It's not like there will be:
>>>
>>>     security.foo@uid=1000
>>>     security.foo@uid=2000
>>>
>>> Except.... if you have an Distribution root directory which is shared
>>> by many containers, you would need to put the xattrs in the overlay
>>> inodes.  Worse, each time you launch a new container, with a new
>>> subuid allocation, you will have to iterate over all files with
>>> capabilities and do a copy-up operations on the xattrs in overlayfs.
>>> So that's actually a bit of a disaster.
>>>
>>> So for distribution overlays, you will need to do things a different
>>> way, which is to map the distro subdirectory so you know that the
>>> capability with the global uid 0 should be used for the container
>>> "root" uid, right?
>>>
>>> So this hack of using security.foo@uid=1000 is *only* useful when the
>>> subcontainer root wants to create the privileged executable.  You
>>> still have to do things the other way.
>>>
>>> So can we make perhaps the assertion that *either*:
>>>
>>>     security.foo
>>>
>>> exists, *or*
>>>
>>>     security.foo@uid=BAR
>>>
>>> exists, but never both?  And there BAR is exclusive to only one
>>> instances?
>>>
>>> Otherwise, I suspect that the architecture is going to turn around and
>>> bite us in the *ss eventually, because someone will want to do
>>> something crazy and the solution will not be scalable.
>> Yep.  That is what it looks like from here.
>>
>> Which is why I asked the question about scalability of the xattr
>> implementations.  It looks like trying to accomodate the general
>> case just gets us in trouble, and sets unrealistic expectations.
>>
>> Which strongly suggests that Serge's previous version that
>> just reved the format of security.capable so that a uid field could
>> be added is likely to be the better approach.
>>
>> I want to see what Serge and Stefan have to say but the case looks
>> pretty clear cut at the moment.
>
> The approach of virtualizing the xattrs on the name-side, which is
> what this patch does, provides a more general approach than to
> virtualizing it on the value side, which is what Serge does in his
> other patch for security.capability alone. With the virtualizing
> on-the-value side virtualizing the xattr becomes an exercise that
> needs to be repeated for every xattr name that one would want to
> virtualize. With this patch you would just add another xattr name to a
> list, a one-line patch in the end. Xattr with prefixes like trusted.*
> need a bit more work but this can be woven in as well
> (https://github.com/stefanberger/linux/commit/397b1a3b24045c67405fc83465e544fc865d402f).

Reusable code has merit, as it reduces the maintenance burden.

My big question right now is can you implement Ted's suggested
restriction.  Only one security.foo or secuirty.foo@... attribute ?

The maintenance gains are definitely worth taking if they do not
penalize the common case.

> For virtualizing the xattrs on the 'value' side I was looking for
> whether there's something like a 'wrapper' structure around the actual
> value of the xattr so that that wrapper could be extended to support
> different values at different uids and applied to any
> xattr. Unfortunately there's no such 'wrapper'.

Different values at different uids currently appear to be undesirable.
At least for security.capable it does not appear to be useful.

A wrapper structure is also a reasonable suggestion.  Put it's magic
number/version code where the existing version code is away we go.

Do you know of cases where we will truly want to have different
attributes for different containers?

The case that I can think of for IMA is that the signatures want to be
conntected to a key that goes with the filesystem image (so not a system
key) but that would not be something that would need to be changed
between containers.

Eric
