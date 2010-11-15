From: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: Re: Mounting blkio cgroup hierarchy
Date: Mon, 15 Nov 2010 08:49:40 +0800
Message-ID: <4CE083A4.4030206__21912.5076816001$1289782141$gmane$org@cn.fujitsu.com>
References: <87fwv6sbwr.fsf@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87fwv6sbwr.fsf-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Gamari <bgamari-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, libcg-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Ben Gamari wrote:
> I've been trying to configure cgroups and have encountered some very
> strange behavior. In particular, when I follow the instructions in
> Documentation/cgroups/blkio-controller.txt I quickly reach an error,
> 
> $ cd /mnt
> $ sudo mkdir -p cgroups/blkio
> $ # Confirm it's not already mounted:
> $ cat /proc/mounts
> $ sudo mount -t cgroup -o blkio none /mnt/cgroups/blkio
...
> mount: special device none does not exist
> 
> I've done quite a bit of Googling and yet it's very difficult to find
> good information on configuring cgroups. I would use the libcg
> toolset[1] but every attempt to configure it has ended in frustratingly
> vague error messages.
> 
> Any ideas?
> 

I suspect you didn't have blkio enabled in your kernel config.

So see if blkio is listed in /proc/cgroups or/and if CONFIG_BLK_CGROUP
is enabled in your kernel config.
