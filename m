From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Tue, 29 Apr 2014 16:07:50 -0700
Message-ID: <CALCETrVgxfNgNuh62non-sB=JTxGN-vSoj-nyRytzgb54WO9EQ@mail.gmail.com>
References: <535FADDA.2070803@1h.com> <20140429183534.GB19325@thunk.org>
	<20140429185251.GA27969@ubuntumail> <53601E5B.5050004@1h.com>
	<20140429220234.GC28410@ubuntumail> <536026B3.1020905@1h.com>
	<20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<20140429230624.GA28966@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140429230624.GA28966-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Marian Marinov <mm-108MBtLGafw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 29, 2014 at 4:06 PM, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> wrote:
> On Tue, Apr 29, 2014 at 03:45:24PM -0700, Andy Lutomirski wrote:
>>
>> Wait, what?
>>
>> Inodes aren't owned by user namespaces; they're owned by users.  And any
>> user can arrange to have a user namespace in which they pass an
>> inode_capable check on any inode that they own.
>>
>> Presumably there's a reason that CAP_SYS_IMMUTABLE is needed.  If this
>> gets merged, then it would be better to just drop CAP_SYS_IMMUTABLE
>> entirely.
>>
>> Nacked-by: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
>
> Right, but you can't set a mapping in a child namespace unless you
> have CAP_SETUID in the parent namespace, right?

Nope.  You can't set a mapping for someone else's uid, but you can
certainly map your own.

> Otherwise user
> namespaces are completely broken from a security perspective, since
> inode_capable() could never do the right thing.

I don't know what inode_capable's "right thing" is, but at least one
of the existing callers is blatantly wrong.  Patches coming shortly.

>
> Personally, reading how user namespaces work, it makes the hair rise
> on the back of my neck.  I'm not sure the concept works at all from a
> security perspective, but hey, I'm not using user namespaces, and some
> fool thought it was worth merging.  :-)

I like them.  I've also found quite a few serious bugs in them.  So go figure :)

--Andy
