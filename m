From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [GIT PULL] namespace updates for v3.17-rc1
Date: Thu, 21 Aug 2014 08:43:14 -0500
Message-ID: <87y4uix8jx.fsf@x220.int.ebiederm.org>
References: <87fvhav3ic.fsf@x220.int.ebiederm.org>
	<CAFLxGvwi-iJRyfwv8v9fcRkiSu2d-az8W55xMPbp_d8wQKmwjg@mail.gmail.com>
	<87vbpm4f4y.fsf@x220.int.ebiederm.org>
	<20140821131257.GA4264@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140821131257.GA4264-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> (Christoph Hellwig's
	message of "Thu, 21 Aug 2014 06:12:57 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <libvir-list-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-fsdevel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> writes:

> On Wed, Aug 20, 2014 at 09:53:49PM -0700, Eric W. Biederman wrote:
>> Richard Weinberger <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> 
>> > On Wed, Aug 6, 2014 at 2:57 AM, Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>> >
>> > This commit breaks libvirt-lxc.
>> > libvirt does in lxcContainerMountBasicFS():
>> 
>> The bugs fixed are security issues, so if we have to break a small
>> number of userspace applications we will.  Anything that we can
>> reasonably do to avoid regressions will be done.
>
> Can you explain the security issues in detail?  Breaking common
> userspace like libvirt-lxc with just a little bit of handwaiving is
> entirely unacceptable.

The biggies ability for an unprivileged user to clear nosuid, nodev,
read-only, noexec with remount.

Apparently part of what libvirt-lxc clearing all mount flags except for
read-only on some filesystem it remounts read-only.  Which if root
mounted the filesystem with nosuid, nodev, or noexec is not supportable.

So if it isn't the implicit setting of nodev on mount but not on remount
causing problems (which I have the trivial fix for) there is a strong
chance I need to break libvirt-lxc.

I am several bugs deep already where fixing one bug reveals yet another
bug.  It is possible there is something else that that I have not
discovered that I am missing.  I am more to happy to investigate to see
if it possible to avoid breaking libvirt-lxc.

Apologies for being a little vague being at the conference I only have
access to email about an hour a day.

Eric
