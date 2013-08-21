From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/11] cpuset: separate configured masks and effective
	masks
Date: Wed, 21 Aug 2013 10:21:55 -0400
Message-ID: <20130821142155.GL19286__40717.373454436$1377094935$gmane$org@mtj.dyndns.org>
References: <52148F52.0@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <52148F52.0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Hello, Li.

On Wed, Aug 21, 2013 at 05:58:42PM +0800, Li Zefan wrote:
> This patcheset introduces behavior changes, but only if you mount cgroupfs
> with sane_behavior option:
> 
> - We introduce new interfaces cpuset.effective_cpus and cpuset.effective_mems,
>   while cpuset.cpus and cpuset.mems will be configured masks.
> 
> - The configured masks can be changed by writing cpuset.cpus/mems only. They
>   won't be changed when hotplug happens.
> 
> - Users can config cpus and mems without restrictions from the parent cpuset.
>   effective masks will enforce the hierarchical behavior.
> 
> - Users can also config cpus and mems to have already offlined CPU/nodes.
> 
> - When a CPU/node is onlined, it will be brought back to the effective masks
>   if it's in the configured masks.
> 
> - We build sched domains based on effective cpumask but not configured cpumask.

Overall, it looks great.  Thank you so much for doing this.  Most of
my reviews are concerned with patch descriptions and documentation.  I
wish they showed clearer what are changed how and why that doesn't
affect !sane behaviors.

Thanks!

-- 
tejun
