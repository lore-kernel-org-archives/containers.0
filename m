From: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: [PATCH v8.5 3/3] cgroups: make procs file writable
Date: Tue, 29 Mar 2011 16:39:17 -0700
Message-ID: <20110329163917.6b5d4149.akpm__1996.29495987228$1301442132$gmane$org@linux-foundation.org>
References: <20110208013542.GC31569@ghc17.ghc.andrew.cmu.edu>
	<20110208013950.GF31569@ghc17.ghc.andrew.cmu.edu>
	<AANLkTinEnNsu8=PEktXL_EECzGYqsgdf+uogGxe7k4W+@mail.gmail.com>
	<20110310061831.GA23736@ghc17.ghc.andrew.cmu.edu>
	<AANLkTikkmfwk0nV0p=omz2ddrw+ZqWF1Lx3EfO6dTjEQ@mail.gmail.com>
	<20110315211353.GA9992@ghc17.ghc.andrew.cmu.edu>
	<AANLkTim4z_x_UQE__f5t73Dimja8PTTXTKKgj2phv6FY@mail.gmail.com>
	<20110322051841.GA12055@ghc17.ghc.andrew.cmu.edu>
	<BANLkTikMgd5HvMyC1BTGzAtj_=Jk=wZm+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <BANLkTikMgd5HvMyC1BTGzAtj_=Jk=wZm+A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 29 Mar 2011 16:27:19 -0700
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Mon, Mar 21, 2011 at 10:18 PM, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org> wrote:
> > Makes procs file writable to move all threads by tgid at once
> >
> > From: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> >
> > This patch adds functionality that enables users to move all threads in a
> > threadgroup at once to a cgroup by writing the tgid to the 'cgroup.procs'
> > file. This current implementation makes use of a per-threadgroup rwsem that's
> > taken for reading in the fork() path to prevent newly forking threads within
> > the threadgroup from "escaping" while the move is in progress.
> >
> > Signed-off-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
> 
> Reviewed-by: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
> 
> OK, I guess this is ready to go in :-)

It all needs a refresh, retest and resend please.
