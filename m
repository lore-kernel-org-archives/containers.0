From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 3/3] Quick vmalloc vs kmalloc fix to the case where
	array  size is too large
Date: Tue, 14 Jul 2009 10:47:32 -0700
Message-ID: <1247593652.13426.15938.camel@nimitz>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230205.16778.11707.stgit@hastromil.mtv.corp.google.com>
	<4A5AA3E7.9070800@cn.fujitsu.com>
	<20090713150303.70ab5176.kamezawa.hiroyu@jp.fujitsu.com>
	<2f86c2480907130827u7d2b062bw26bbb80a8e3de657@mail.gmail.com>
	<20090714084950.2401d9a6.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907132050n226aecb3ucab6746a4d0e81fa@mail.gmail.com>
	<20090714125334.b476aa78.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907132104o55d31ccexb15e5aa35c31416e@mail.gmail.com>
	<20090714132538.ac0bc44a.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830907141028y50f36d63h8ea06f73ff369591@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830907141028y50f36d63h8ea06f73ff369591-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-07-14 at 10:28 -0700, Paul Menage wrote:
> On Mon, Jul 13, 2009 at 9:25 PM, KAMEZAWA
> Hiroyuki<kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > My point is
> >  - More PIDs, More time necessary to read procs file.
> 
> Right now, many pids => impossible to read procs file due to kmalloc
> failure. (This was always the case with cpusets too). So using kmalloc
> in those cases is a strict improvement.

How big were those allocations that were failing?  The code made it
appear that order-2 (PAGE_SIZE*4) allocations were failing.  That's a
bit lower than I'd expect the page allocator to start failing.

-- Dave
