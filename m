From: David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 4/8] Use vmalloc for large cgroups pidlist allocations
Date: Thu, 20 Aug 2009 15:56:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.00.0908201542440.29906__12904.0164560594$1250809026$gmane$org@chino.kir.corp.google.com>
References: <20090818235059.22531.42618.stgit@menage.mtv.corp.google.com>
	<20090818235827.22531.60306.stgit@menage.mtv.corp.google.com>
	<20090820141400.f6d3d5a6.akpm@linux-foundation.org>
	<20090820163510.27942b62@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090820163510.27942b62-vw3g6Xz/EtPk1uMJSBkQmQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>
Cc: bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org, Dave Hansen <haveblue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 20 Aug 2009, Jonathan Corbet wrote:

> On Thu, 20 Aug 2009 14:14:00 -0700
> Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> 
> > Hang on.  Isn't this why Dave just wrote and I just rush-merged
> > lib/flex_array.c?
> > 
> > Was that code evaluated for this application and judged unsuitable?  If so,
> > for what reason?
> 
> Should it be helpful: I wrote an overview of the flex_array API here:
> 
> 	http://lwn.net/Articles/345273/
> 
> I could format it up for addition to Documentation/ if people want.
> 

It's definitely helpful for this use case, flex array can store 261,632 
pid_t's on 64 bit.

Instead of reallocating new memory when the pidlist becomes smaller, it 
would then be sufficient to simply shrink the flex array by freeing parts 
members that are newly unused (which also avoids the oom possibility in 
pidlist_resize()).

flex_array_shrink(struct flex_array *) would require element poisoning 
when an element is cleared, but that's probably not far off anyways 
because it has additional advantages such as preventing flex_array_get() 
on an element that has not been put.
