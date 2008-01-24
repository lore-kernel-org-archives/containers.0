From: Hirokazu Takahashi <taka-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
Subject: Re: [dm-devel] [PATCH 0/2] dm-band: The I/O bandwidth controller:
 Overview
Date: Thu, 24 Jan 2008 19:14:56 +0900 (JST)
Message-ID: <20080124.191456.119427875.taka__20079.7885926024$1201169817$gmane$org@valinux.co.jp>
References: <20080124.012103.105433865.taka@valinux.co.jp>
	<20080124033807.42D7B1E3C0C@siro.lan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080124033807.42D7B1E3C0C-Pcsii4f/SVk@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: yamamoto-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org
Cc: xen-devel-GuqFBffKawuULHF6PoxzQEEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
List-Id: containers.vger.kernel.org

Hi,

> > > On Wed, Jan 23, 2008 at 09:53:50PM +0900, Ryo Tsuruta wrote:
> > > > Dm-band gives bandwidth to each job according to its weight, 
> > > > which each job can set its own value to.
> > > > At this time, a job is a group of processes with the same pid or pgrp or uid.
> > > 
> > > It seems to rely on 'current' to classify bios and doesn't do it until the map
> > > function is called, possibly in a different process context, so it won't
> > > always identify the original source of the I/O correctly:
> > 
> > Yes, this should be mentioned in the document with the current implementation
> > as you pointed out.
> > 
> > By the way, I think once a memory controller of cgroup is introduced, it will
> > help to track down which cgroup is the original source.
> 
> do you mean to make this a part of the memory subsystem?

I just think if the memory subsystem is in front of us, we don't need to
reinvent the wheel.

But I don't have a concrete image how the interface between dm-band and
the memory subsystem should be designed yet. I'd be appreciate if some of
the cgroup developers give some ideas about it.

Thanks,
Hirokazu Takahashi.


> YAMAMOTO Takashi
