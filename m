From: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Wed, 26 Nov 2014 00:15:31 +0100
Message-ID: <CAFLxGvzyhHC+QF-bFfp-yNBpCkS3JJ+RAr+5iCj0k_su9wJbGw@mail.gmail.com>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
	<87vbpm4f4y.fsf@x220.int.ebiederm.org>
	<20140821131257.GA4264@infradead.org> <53F5F2AD.5010607@nod.at>
	<87k362vsr5.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k362vsr5.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Eric,

On Thu, Aug 21, 2014 at 4:09 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:
>
>> Am 21.08.2014 15:12, schrieb Christoph Hellwig:
>>> On Wed, Aug 20, 2014 at 09:53:49PM -0700, Eric W. Biederman wrote:
>>>> Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>>
>>>>> On Wed, Aug 6, 2014 at 2:57 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>>>
>>>>> This commit breaks libvirt-lxc.
>>>>> libvirt does in lxcContainerMountBasicFS():
>>>>
>>>> The bugs fixed are security issues, so if we have to break a small
>>>> number of userspace applications we will.  Anything that we can
>>>> reasonably do to avoid regressions will be done.
>>>
>>> Can you explain the security issues in detail?  Breaking common
>>> userspace like libvirt-lxc with just a little bit of handwaiving is
>>> entirely unacceptable.
>>
>> It looks like commit 87b47932f40a11280584bce260cbdb3b5f9e8b7d in
>> git.kernel.org/cgit/linux/kernel/git/ebiederm/user-namespace.git for-next
>> unbreaks libvirt-lxc.
>> I hope it hits Linus tree and -stable before the offending commit hits users.
>
> I plan to send the pull request to Linus as soon as I have caught my
> breath (from all of the conferences this week) that I can be certain I
> am thinking clearly and not rushing things.

Today I've upgraded my LXC testbed to the most recent kernel and found
libvirt-lxc broken again (sic!).
Remounting /proc/sys/ is failing.
Investigating into the issue showed that commit "mnt: Implicitly add
MNT_NODEV on remount as we do on mount"
is not mainline.
Why did you left out this patch? In my previous mails I explicitly
stated that exactly this commit unbreaks libvirt-lxc.

Now the userspace breaking changes are mainline and hit users hard. :-(

-- 
Thanks,
//richard
