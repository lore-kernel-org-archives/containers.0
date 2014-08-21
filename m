From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Thu, 21 Aug 2014 09:09:50 -0500
Message-ID: <87k362vsr5.fsf@x220.int.ebiederm.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
	<87vbpm4f4y.fsf@x220.int.ebiederm.org>
	<20140821131257.GA4264@infradead.org> <53F5F2AD.5010607@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <53F5F2AD.5010607-/L3Ra7n9ekc@public.gmane.org> (Richard Weinberger's message of "Thu,
	21 Aug 2014 15:22:53 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Cc: "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org> writes:

> Am 21.08.2014 15:12, schrieb Christoph Hellwig:
>> On Wed, Aug 20, 2014 at 09:53:49PM -0700, Eric W. Biederman wrote:
>>> Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>>>
>>>> On Wed, Aug 6, 2014 at 2:57 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>>
>>>> This commit breaks libvirt-lxc.
>>>> libvirt does in lxcContainerMountBasicFS():
>>>
>>> The bugs fixed are security issues, so if we have to break a small
>>> number of userspace applications we will.  Anything that we can
>>> reasonably do to avoid regressions will be done.
>> 
>> Can you explain the security issues in detail?  Breaking common
>> userspace like libvirt-lxc with just a little bit of handwaiving is
>> entirely unacceptable.
>
> It looks like commit 87b47932f40a11280584bce260cbdb3b5f9e8b7d in
> git.kernel.org/cgit/linux/kernel/git/ebiederm/user-namespace.git for-next
> unbreaks libvirt-lxc.
> I hope it hits Linus tree and -stable before the offending commit hits users.

I plan to send the pull request to Linus as soon as I have caught my
breath (from all of the conferences this week) that I can be certain I
am thinking clearly and not rushing things.

Eric
