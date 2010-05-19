From: Thomas Renninger <trenn-l3A5Bk7waGM@public.gmane.org>
Subject: Re: [PATCH 2/2] scheduler: cgroups cpuaccouting: Make cpuusage atomic
Date: Wed, 19 May 2010 21:13:51 +0200
Message-ID: <201005192113.52535.trenn__12614.1758905307$1274296513$gmane$org@suse.de>
References: <1274264877.5605.10541.camel@twins>
	<1274295539-7798-3-git-send-email-trenn@suse.de>
	<1274295743.1674.1545.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1274295743.1674.1545.camel@laptop>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mike-z5hGa2qSFaRBDgjK7y7TUQ@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Wednesday 19 May 2010 09:02:23 pm Peter Zijlstra wrote:
> On Wed, 2010-05-19 at 20:58 +0200, Thomas Renninger wrote:
> > and avoid locking on 32 bit.
> > This resolves an ugly dependency in cgroups_cpuaccount.c
> > to per_cpu runqueues lock variable.
>
> While I totally agree with the sentiments here, atomic64_t isn't
> available on all 32bit archs and is _terribly_ expensive on ARCH=i386.
Speed on i386 shouldn't count that much here.
Big machines run x86_64 and cgroup cpu accounting doesn't make much
sense on old i386 single core machines.

Would still be great to see the first patch go in then.
The idea of splitting was to:
  a) show the real change
  b) make at least the first go in if the snd does not work out

Thanks,

     Thomas
