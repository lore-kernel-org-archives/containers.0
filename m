From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
Date: Thu, 9 Oct 2008 14:46:58 +0200
Message-ID: <20081009124658.GE2952__35801.1540993631$1223556689$gmane$org@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1223461197-11513-1-git-send-email-orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: jeremy-TSDbQ3PG+2Y@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, "H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org


* Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> wrote:

> These patches implement basic checkpoint-restart [CR]. This version 
> (v6) supports basic tasks with simple private memory, and open files 
> (regular files and directories only). Changes mainly cleanups. See 
> original announcements below.

i'm wondering about the following productization aspect: it would be 
very useful to applications and users if they knew whether it is safe to 
checkpoint a given app. I.e. whether that app has any state that cannot 
be stored/restored yet.

Once we can do that, if the kernel can reliably tell whether it can 
safely checkpoint an application, we could start adding a kernel driven 
self-test of sorts: a self-propelled kernel feature that would 
transparently try to checkpoint various applications as it goes, and 
restore them immediately.

When such a test-kernel is booted then all that should be visible is an 
occasional slowdown due to the random save/restore cycles of various 
processes - but no actual application breakage should ever occur, and 
the kernel must not crash either. This would work a bit like 
CONFIG_RCUTORTURE: a constant test that should be transparent in terms 
of functionality.

Also, the ability to tell whether a process can be safely checkpointed 
would allow apps to rely on it - they cannot accidentally use some 
kernel feature that is not saved/restored and then lose state across a 
CR cycle.

Plus, as a bonus, the inability to CR a given application would sure 
spur the development of proper checkpointing of that given kernel state. 
We could print some once-per-boot debug warning about exactly what bit 
cannot be checkpointed yet. This would create proper pressure from 
actual users of CR.

	Ingo
