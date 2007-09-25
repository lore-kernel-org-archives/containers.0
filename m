From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] allow "unlimited" limit value.
Date: Tue, 25 Sep 2007 13:07:56 -0700 (PDT)
Message-ID: <alpine.DEB.0.9999.0709251304030.28350@chino.kir.corp.google.com>
References: <20070925193900.1af6d871.kamezawa.hiroyu@jp.fujitsu.com>
	<46F90DCA.5030209@linux.vnet.ibm.com> <46F90E48.6080603@openvz.org>
	<20070926000510.7d956db8.kamezawa.hiroyu@jp.fujitsu.com>
	<46F925ED.20303@openvz.org>
	<20070926003056.7df087a0.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0709251205390.19001@chino.kir.corp.google.com>
	<46F95FD7.3010204@linux.vnet.ibm.com>
	<6599ad830709251235u33dde9c8pfd56ed3d9d4fbe4b@mail.gmail.com>
	<alpine.DEB.0.9999.0709251236040.23337@chino.kir.corp.google.com>
	<6599ad830709251300sea126bam5a4b6f7c6bd366e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <6599ad830709251300sea126bam5a4b6f7c6bd366e0-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, 25 Sep 2007, Paul Menage wrote:

> > If I echo -n 8191 > memory.limit_in_bytes, I'm still only going to be able
> > to charge one page on my x86_64.  And then my program's malloc(5000) is
> > going to fail, which leads to the inevitable head scratching.
> 
> This is a very unrealistic argument. Page-size rounding really has no
> effect on any reasonable-sized memory cgroup.
> 

It doesn't matter.  When I cat my cgroup's memory.limit (or 
memory.limit_in_bytes), I should see the total number of bytes that my 
applications are allowed.  That's not an unrealistic expectation of a 
system that is expressly designed to control my memory.  I don't want to 
see a value that is close to what I'm allowed, thanks.

Storing it internally as the number of pages makes the implementation 
simpler since memory controls are only imposed on pages anyway and you get 
the added bonus of integer division truncating in C so that when you cat 
the file it will display the correct number of bytes modulo PAGE_SIZE.

> Expressing it in bytes seems reasonable to me, since they are after
> all the fundamental unit that's being counted ("kilobytes" are
> explicitly an aggregation of "bytes").
> 

That fundamental unit being charged are pages, so any memory limit that 
has a finer granularity than kilobytes is just plain wrong.

		David
