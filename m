From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] i/o bandwidth controller documentation
Date: Sat, 21 Jun 2008 12:35:02 +0200
Message-ID: <485CD956.3070209@gmail.com>
References: <1213956335-29866-2-git-send-email-righi.andrea@gmail.com>
	<20080620100825.eff22c44.randy.dunlap@oracle.com>
Reply-To: righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080620100825.eff22c44.randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Randy Dunlap <randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, roberto-5KDOxZqKugI@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Thanks Randy, I've applied all your fixes to my local documentation,
next patchset version will include them. A few small comments below.

Randy Dunlap wrote:
>> +* Run a benchmark doing I/O on /dev/sda1 and /dev/sda5; I/O limits and usage
>> +  defined for cgroup "foo" can be shown as following:
>> +  # cat /mnt/cgroup/foo/blockio.bandwidth
>> +  === device (8,1) ===
>> +    bandwidth limit: 1024 KiB/sec
>> +  current i/o usage: 819 KiB/sec
>> +  === device (8,5) ===
>> +    bandwidth limit: 1024 KiB/sec
>> +  current i/o usage: 3102 KiB/sec
> 
> Ugh, this makes it look like the output does "pretty printing" (formatting),
> which is generally not a good idea.  Let some app be responsible for that,
> not the kernel.  Basically this means don't use leading spaces just to make the
> ":"s line up in the output.

Sounds reasonable. I think the output could be further reduced,
the following format should be explanatory enough.

device: %u,%u
bandwidth: %lu KiB/sec
usage: %lu KiB/sec

>> +WARNING: per-block device limiting rules always refer to the dev_t device
>> +number. If a block device is unplugged (i.e. a USB device) the limiting rules
>> +associated to that device persist and they are still valid if a new device is
> 
> associated with (?)

what about:

...the limiting rules defined for that device...

-Andrea
