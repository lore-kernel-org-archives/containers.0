From: Ryo Tsuruta <ryov-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Implementation of dm-ioband as a dm-driver (Re: [dm-devel] [PATCH
	1/2] dm-ioband: I/O bandwidth controller v1.10.0: Source code and
	patch)
Date: Thu, 29 Jan 2009 12:41:33 +0900 (JST)
Message-ID: <20090129.124133.179945157.ryov__40266.7095223025$1233200625$gmane$org@valinux.co.jp>
References: <20090122161218.GA28795@redhat.com>
	<20090123.191404.39168431.ryov@valinux.co.jp>
	<20090126162951.GI31802@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090126162951.GI31802-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Cc: dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arozansk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jens.axboe-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, paolo.valente-rcYM44yAMweonA0d6jMUrA@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fernando-w0OK63jvRlAuJ+9fw/WgBHgSJqDPrsil@public.gmane.org, riel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, fchecconi-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi Vivek,

This mail is about implement IO controller as a dm-driver.

> In this case first you are forcing some functionalilty to go in a kernel
> module and then coming up with tools for configuration. I never understood
> that why don't you let the controller be inside the kernel, let it
> directly interact with cgroup subsystem and work instead of first taking
> the functionality out of kernel in a module and then justifying the case
> that now we need new ways of configuring that module because cgroup
> infrastructure is not sufficient.  

It is possible the algorithm of dm-ioband can be directly implemented
in the kernel. I've been investigating how to do it.

> > > - Need of a dm device for every device we want to control
> > > 
> > > 	- This requirement looks odd. It forces everybody to use dm-tools
> > > 	  and if there are lots of disks in the system, configuation is
> > > 	  pain.
> > 
> > I don't think it's so pain. I think you are already using LVM devices on
> > your boxes. Setting up dm-ioband is the same as that for LVM. And some
> > scripts or something similar will help you set up them.
> 
> Not everybody uses LVM. Balbir had asked once, if there are thousands of 
> disks in the system, does that mean I need to create this dm-ioband device
> for all the disks?

I think it could be easily done by a small script of several lines.

Thanks,
Ryo Tsuruta
