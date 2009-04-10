From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 01/30] headers: fixup cred.h, ipc_namespace.h
Date: Fri, 10 Apr 2009 17:17:01 +0400
Message-ID: <20090410131701.GA3683__2792.30310484326$1239369588$gmane$org@x200.localdomain>
References: <20090410023248.GB27788@x200.localdomain>
	<20090410084747.GB17962@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090410084747.GB17962-X9Un+BFzKDI@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
List-Id: containers.vger.kernel.org

On Fri, Apr 10, 2009 at 10:47:47AM +0200, Ingo Molnar wrote:
> 
> * Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> > +struct kern_ipc_perm;

> Please, not yet another forward declaration...
> 
> I believe this should be cleaned up properly, instead of sprinkling 
> the kernel with random placed forward declarations.

It's at the top of the file, there is no random placing going on.

> In a cleanly structured piace of code there's rarely any need for 
> forward declarations like this. There's two basic header types 
> needed:
> 
>    foo_types.h       declares all the data types and constants
>                      [no complex inline functions]
> 
>    foo.h             externs, complex inlines
> 
> foo.h includes all foo_types.h and bar_types.h headers it needs.
> 
> The foo_types.h file includes all other bar_types.h headers it 
> depends on for its data type definitions.
> 
> foo_types.h never includes a bar.h file.

This can be viewed as bad precedent created by mm_types.h.

Look how many headers mm_types.h includes. It doesn't change much
if one includes mm.h or mm_types.h.

Look how many places includes spinlock_types.h

> The end result will be a clean hieararchy of data types, separated 
> from methods. Complex inlines dont create the incestous 
> cross-dependency hell anymore and dont contaminate the foo_types.h 
> files.
> 
> Yes, this is quite a bit of work, but this has been done before for 
> several complex headers so it's possible to do it.

Forward declarations are currently well established.

Want to change rules? Fine, do it.
