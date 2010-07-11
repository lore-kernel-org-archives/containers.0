From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 01/24] pidns: Remove races by stopping the caching of proc_mnt
Date: Sun, 11 Jul 2010 07:25:18 -0700
Message-ID: <m1mxtyt7sh.fsf@fess.ebiederm.org>
References: <20100625192945.GA25532@redhat.com>
	<20100625212618.GA11917@us.ibm.com>
	<20100625212758.GA30474@redhat.com>
	<20100625220713.GA31123@us.ibm.com>
	<m1r5jd5l0v.fsf_-_@fess.ebiederm.org>
	<m1mxu15kv4.fsf_-_@fess.ebiederm.org>
	<20100709121425.GB18586@hawkmoon.kerlabs.com>
	<m1lj9k4xfx.fsf@fess.ebiederm.org>
	<20100709141324.GC18586@hawkmoon.kerlabs.com>
	<m1aaq04ph2.fsf_-_@fess.ebiederm.org>
	<20100711141406.GD18586@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100711141406.GD18586@hawkmoon.kerlabs.com> (Louis Rilling's message of "Sun\, 11 Jul 2010 16\:14\:07 +0200")
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Containers <containers@lists.osdl.org>, Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Pavel Emelyanov <xemul@openvz.org>, Oleg Nesterov <oleg@redhat.com>
List-Id: containers.vger.kernel.org

Louis Rilling <Louis.Rilling@kerlabs.com> writes:

> On 09/07/10  8:58 -0700, Eric W. Biederman wrote:
>> 
>> Having proc reference the pid_namespace and the pid_namespace
>> reference proc is a serious reference counting problem, which has
>> resulted in both leaks and use after free problems.  Mount already
>> knows how to go from a pid_namespace to a mount of proc, so we don't
>> need to cache the proc mount.
>> 
>> To do this I introduce get_proc_mnt and replace pid_ns->proc_mnt users
>> with it. Additionally I remove pid_ns_(prepare|release)_proc as they
>> are now unneeded.
>> 
>> This is slightly less efficient but it is much easier to avoid the
>> races.  If efficiency winds up being a problem we can revisit our data
>> structures.
>
> IIUC, the difference between this solution and the first one I proposed is that
> instead of pinning proc_mnt with mntget() at copy_process()-time, proc_mnt is
> looked for and, if possible, mntget() at release_task()-time.
>
> Could you elaborate on the trade-off, that is accessing proc_mnt at
> copy_process()-time vs looking up proc_mnt at release_task()-time?

A little code simplicity.  But Serge was right there is cost a noticeable
cost.  About 5%-7% more on lat_proc from lmbench.

The real benefit was simplicity.

Eric
