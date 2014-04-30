From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: ioctl CAP_LINUX_IMMUTABLE is checked in the wrong namespace
Date: Tue, 29 Apr 2014 17:33:41 -0700
Message-ID: <CALCETrU4KXbwvfgtBo=fZ-=DGzgTkEVP0G=FhvJhdoo=+K1g6g@mail.gmail.com>
References: <535FADDA.2070803@1h.com> <20140429183534.GB19325@thunk.org>
	<20140429185251.GA27969@ubuntumail> <53601E5B.5050004@1h.com>
	<20140429220234.GC28410@ubuntumail> <536026B3.1020905@1h.com>
	<20140429222913.GD28410@ubuntumail> <53602B84.1020304@mit.edu>
	<20140430001641.GA28969@ubuntumail> <20140430003236.GA6472@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140430003236.GA6472-AKGzg7BKzIDYtjvyW6yDsg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org>, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Marian Marinov <mm-108MBtLGafw@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, lxc-devel <lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Apr 29, 2014 at 5:32 PM, Theodore Ts'o <tytso-3s7WtUTddSA@public.gmane.org> wrote:
> On Wed, Apr 30, 2014 at 12:16:41AM +0000, Serge Hallyn wrote:
>> I forget the details, but there was another case where I wanted to
>> have the userns which 'owns' the whole fs available.  I guess we'd
>> have to check against that instead of using inode_capable.
>
> Yes, that sounds right.
>
> And *please* tell me that that under no circumstances can anyone other
> than root@init_user_ns is allowed to use mknod....

I haven't read the code, but I tried it the other day, and I got
-EPERM.  So we're okay for now.  (Well, other than the issue I just
sent to security-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, but that's not quite the same thing.)

--Andy
