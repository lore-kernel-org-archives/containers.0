From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: Re: [PATCH 02/11] mtd: Check permissions towards mtd block device
	inode when mounting
Date: Sat, 23 Dec 2017 13:56:51 +0100
Message-ID: <65834980.AClogkzgvk__49763.2456747398$1514034115$gmane$org@blindfold>
References: <cover.1512741134.git.dongsu@kinvolk.io>
	<CAFLxGvwzRBGJf0-jCAwGts1HwV_nT072+yhHLP079sxQezoTFQ@mail.gmail.com>
	<CANxcAMtVqgLmQaTtfJocGGgsn5dSX2CDwzh6bwv6OnjUUwsTrg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CANxcAMtVqgLmQaTtfJocGGgsn5dSX2CDwzh6bwv6OnjUUwsTrg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>
Cc: Miklos Szeredi <mszeredi-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alban Crequy <alban-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org>, "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>, Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, "linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org" <linux-mtd-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Id: containers.vger.kernel.org

Dongsu,

Am Samstag, 23. Dezember 2017, 13:18:30 CET schrieb Dongsu Park:
> Hi,
> 
> On Fri, Dec 22, 2017 at 10:06 PM, Richard Weinberger
> 
> <richard.weinberger-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> > Dongsu,
> > 
> > On Fri, Dec 22, 2017 at 3:32 PM, Dongsu Park <dongsu-lYLaGTFnO9sWenYVfaLwtA@public.gmane.org> wrote:
> >> From: Seth Forshee <seth.forshee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
> >> 
> >> Unprivileged users should not be able to mount mtd block devices
> >> when they lack sufficient privileges towards the block device
> >> inode.  Update mount_mtd() to validate that the user has the
> >> required access to the inode at the specified path. The check
> >> will be skipped for CAP_SYS_ADMIN, so privileged mounts will
> >> continue working as before.
> > 
> > What is the big picture of this?
> > Can in future an unprivileged user just mount UBIFS?
> 
> I'm not sure I'm aware of all use cases w.r.t mtd & ubifs.
> To my understanding, in these days many container runtimes allow
> unprivileged users to run containers. (docker, lxc, runc, bubblewrap, etc)
> That's why the kernel should deal with additional permission checks
> that might have not been necessary in the past.
> This MTD patch is one of those special cases.

My fear is that a corner case is forgotten and all of a sudden someone can do 
funky things with MTD in a container...

Thanks,
//richard
