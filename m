From: Vivek Kashyap <kashyapv-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [linux-pm] [PATCH 0/5] Container Freezer v6: Reuse Suspend Freezer
Date: Tue, 12 Aug 2008 20:47:10 -0700 (Pacific Daylight Time)
Message-ID: <Pine.WNT.4.64.0808121927320.5336__6656.58282018757$1218599376$gmane$org@IBM-8DE7FFDE2AB>
References: <20080811235323.872291138@us.ibm.com>
	<20080812154429.c5377bd0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20080812154429.c5377bd0.akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 12 Aug 2008, Andrew Morton wrote:

> On Mon, 11 Aug 2008 16:53:23 -0700
> Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> wrote:
>
>> This patch series introduces a cgroup subsystem that utilizes the swsusp
>> freezer to freeze a group of tasks. It's immediately useful for batch job
>> management scripts. It should also be useful in the future for implementing
>> container checkpoint/restart.
>
> I don't think that this provides anything like sufficient detail to justify
> merging a whole bunch of stuff into Linux.
>
> What does "It's immediately useful for batch job management scripts."
> mean?  How is it useful?  Examples?  Why would an operator want this
> feature, and how would it be used?  _much_ more information is needed!

A batch-manager/job scheduler (such as loadleveler) must at times stop all 
tasks associated with a workload being run in a container. The workload may 
constitute of multiple tasks - some of which are in different sessions. 
A signal (STOP/CONT) to the Containers 'init' wont be transmitted to all 
the tasks in the Container. The 'freezer' mechanism allows this control
to be implemented in a clean way.

Vivek
>
> Once we've actually found out what this work is useful for, we can move
> onto identification of and discussion of alternatives.  One would be "why not
> use plain old SIGSTOP?"  Another alternative is, of course "that's not useful
> enough to justify merging the code".  But we don't know yet, coz you didn't
> tell us.
> _______________________________________________
> linux-pm mailing list
> linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/linux-pm
>

__

Vivek Kashyap
Linux Technology Center, IBM
