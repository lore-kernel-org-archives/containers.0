From: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH] scheduler: Extract cgroups_cpuaccount code from
	sched.c into own file
Date: Wed, 19 May 2010 11:37:36 +0200
Message-ID: <1274261856.5605.10439.camel__6274.32227270237$1274262012$gmane$org@twins>
References: <1274232620-23003-1-git-send-email-mike@android.com>
	<1274232620-23003-4-git-send-email-mike@android.com>
	<201005191130.42851.trenn@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <201005191130.42851.trenn-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Cc: khilman-1D3HCaltpLuhEniVeURVKkEOCMrvLtNR@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cpufreq-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Mike Chan <mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org>, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, 2010-05-19 at 11:30 +0200, Thomas Renninger wrote:
> 
> This is a cleanup against current linux-2.6 Linus tree.
>     
> Having CONFIG_CGROUP_CPUACCT code in kernel/sched.c looks wrong.
> Move this out to kernel/cgroup_cpuaccount.c
>     
> Test compiled with and without CONFIG_CGROUP_CPUACCT set on x86_64.

Sure, works for me, less code to look at :-)
