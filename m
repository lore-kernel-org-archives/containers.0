From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/5] user-cr: align powerpc sp for eclone, clean up
	__eclone
Date: Wed, 16 Dec 2009 20:53:03 -0800
Message-ID: <20091217045303.GE30702@count0.beaverton.ibm.com>
References: <1259989351-28552-1-git-send-email-ntl@pobox.com>
	<1259989351-28552-3-git-send-email-ntl@pobox.com>
	<20091217042925.GC30702@count0.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091217042925.GC30702-52DBMbEzqgQ/wnmkkaCWp/UQ3DHhIser@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Dec 16, 2009 at 08:29:25PM -0800, Matt Helsley wrote:
> On Fri, Dec 04, 2009 at 11:02:28PM -0600, Nathan Lynch wrote:

<snip>

> >  	/* Set up arguments for system call. */
> > -	mr	r3,r5	/* flags */
> > -	mr	r4,r7	/* clone_args */
> > -	mr	r5,r8	/* clone_args' size */
> > -	mr	r6,r9	/* pids */
> > +	mr	r3,r4	/* flags */
> > +	mr	r4,r6	/* clone_args */
> > +	mr	r5,r7	/* clone_args' size */
> > +	mr	r6,r8	/* pids */
> 
> Wouldn't it be possible to avoid some mr instructions above by re-arranging

(The 4 immediately above)

> the function arguments? Then you're just saving things in the two non-volatile
> gprs before making the eclone syscall. I think this amounts to making the
> prototype:
>
> int [r3] eclone(int flags [r3],
> 		struct clone_args *args [r4],
> 		size_t args_size [r6],
> 		pid_t *pids [r7],
> 		int (*fn)(void *arg) [r8],
> 		void *fn_arg [r9]);

Argh, should've been:

int [r3] __eclone(int flags [r3],
              struct clone_args *args [r4],
              size_t args_size [r5],
              pid_t *pids [r6],
              int (*fn)(void *arg) [r7],
              void *fn_arg [r8]);

Cheers,
	-Matt
