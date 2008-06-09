From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: restarting tests/sleep
Date: Mon, 9 Jun 2008 13:19:12 -0500
Message-ID: <20080609181912.GA18341@us.ibm.com>
References: <484D2E7C.4060905@bull.net> <20080609143626.GA23253@us.ibm.com>
	<484D4364.2080509@bull.net> <20080609162309.GA32120@us.ibm.com>
	<1213029148.3508.25.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1213029148.3508.25.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, Nadia Derbey <Nadia.Derbey-6ktuUTfB/bM@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> On Mon, 2008-06-09 at 11:23 -0500, Serge E. Hallyn wrote:
> > 
> > 
> > Yeah that's insurmountable - notice the stack in the process which was
> > fork()ed to be the restarted process topped at bfcab000, while the
> > checkpointed stack topped at bfdae000.  You're not allowed to write
> > above the stack.  So the only things to do are
> > 
> >         1. keep trying the restart in the hopes you get a task with
> >            stack topping at or above bfdae000
> >         2. if the checkpointed stack is too high to be likely to be
> >            restartable, generate a new checkpoint image and you
> >            should get a lower stack top.
> > 
> > (Dave, maybe you had other ideas I haven't considered)
> 
> Have you tried turning of stack randomization?  It should make the stack
> more dependable at exec.  We could also provide a hint somewhere on
> exec() where to place the stack.  

Yup, that should prevent the spurious -EFAULTS.  Suka, you were getting
these too last week, so I recommend doing

	echo 0 > /proc/sys/kernel/randomize_va_space

on startup.

-serge
