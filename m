From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [RFC][PATCH 2/3] CGroups: Use hierarchy_mutex in memory
	controller
Date: Fri, 12 Dec 2008 10:12:57 +0900
Message-ID: <20081212101257.9be5436f.kamezawa.hiroyu__41701.0023295463$1229044640$gmane$org@jp.fujitsu.com>
References: <20081210233654.563182000@menage.corp.google.com>
	<20081210234432.236302000@menage.corp.google.com>
	<20081211094938.85b00cf3.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812101652o25bc33f3r2a710e0879f9b196@mail.gmail.com>
	<20081211100501.bf538f0c.kamezawa.hiroyu@jp.fujitsu.com>
	<20081211063307.GL3008@balbir.in.ibm.com>
	<20081211155323.957eb73c.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830812110905k4e32363fp671bf88e18fbf349@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830812110905k4e32363fp671bf88e18fbf349-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Thu, 11 Dec 2008 09:05:47 -0800
Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org> wrote:

> On Wed, Dec 10, 2008 at 10:53 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> >
> > Could you write a document to explain what kind of nest of locks are allowed
> > before merging this ?
> 
> We should probably treat it similarly to the cpuset "callback_mutex".
> I.e. memory allocations are most likely forbidden when you're holding
> it.
> 
Hmm. Anyway, hierarchy mutex should not be aquired in deep stack of the kernel
calls. (and my patch will make memcg's hierarchy walk lockless.)

-Kame
