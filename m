From: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/3] Adds a read-only "procs" file similar to "tasks"
	that shows only unique tgids
Date: Tue, 14 Jul 2009 14:49:29 -0700
Message-ID: <1247608169.13426.16602.camel__23885.0424103022$1247608266$gmane$org@nimitz>
References: <20090710230043.16778.29656.stgit@hastromil.mtv.corp.google.com>
	<20090710230154.16778.58053.stgit@hastromil.mtv.corp.google.com>
	<1247596470.13426.16088.camel@nimitz>
	<2f86c2480907141426r16f8ccf3o9770e25cc8d2e509@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <2f86c2480907141426r16f8ccf3o9770e25cc8d2e509-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Benjamin Blum <bblum-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 2009-07-14 at 14:26 -0700, Benjamin Blum wrote:
> This method looks to be a compromise between Andrew's proposed
> generalized solution ( http://lkml.org/lkml/2009/7/2/518 ) and the
> current quick-fix. The problem with it is that it'll require a layer
> between whoever's using the array and managing the list structs (for
> the case where we need to chain multiple blocks together), and if
> we're going to put forth enough effort for that, we may as well go
> ahead and write up a generalized kernel-wide library to fix this size
> problem globally.

This "Andrew" guy seems to know what he's talking about. :)

We've also got a set of pgarrs (struct page arrays) in the
checkpoint/restart code that would make use of something generic like
this.  

-- Dave
