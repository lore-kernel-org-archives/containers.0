From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 0/1]a new optional function for task assignment to
	cgroup
Date: Wed, 5 Mar 2008 12:43:38 +0530
Message-ID: <20080305071338.GA7588__30390.3913860724$1204701445$gmane$org@linux.vnet.ibm.com>
References: <47CE322A.9060907@ak.jp.nec.com>
	<6599ad830803042156y5a28978fi995eb9050f8f5320@mail.gmail.com>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <6599ad830803042156y5a28978fi995eb9050f8f5320-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Kazunaga Ikeno <k-ikeno-l0HG/lpvHE58UrSeD/g0lQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Mar 04, 2008 at 09:56:13PM -0800, Paul Menage wrote:
> Hi Kazunaga,
> 
> On Tue, Mar 4, 2008 at 9:39 PM, Kazunaga Ikeno <k-ikeno-l0HG/lpvHE58UrSeD/g0lQ@public.gmane.org> wrote:
> > Hi -
> >
> >  This is a patch of a new optional function for task assignment to cgroup, RFC.
> >
> >
> >  == Purpose =================================================
> >
> >  To provide the function that leads a task, corresponding to the conditions specified
> >  beforehand, to a specific cgroup directory.
> >
> 
> This is something that's been discussed before, originally as part of
> CKRM with a complex rule engine in the kernel space.
> 
> Basically, the general agreement was that it's a case where a simple
> API is going to be too simple for the majority of users, and a complex
> API that satisfies everyone is going to be too messy/heavyweight.
> 
> This is something that can be done in a userspace daemon via the
> process events connector - when you get a PROC_EVENT_UID event, you
> can move the process into the appropriate cgroup (you may also need to
> check any recently-forked children). This also gives you more
> flexibility than you can have in the kernel - you can base your
> decision on more complex factors than simply the uid of the process.
> 
> Dhaval Giani had a prototype implementation of such a daemon.
> 

The daemon was posted at
http://article.gmane.org/gmane.linux.kernel/553267 . At that point
control groups were called containers. These corrections will have to
made for it to run.

If I can get the time, I will clean it up and try to put it up
somewhere.

Thanks,

-- 
regards,
Dhaval
