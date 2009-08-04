From: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [cr_tests PATCH] robust futex: handle -EINTR snafus
Date: Tue, 4 Aug 2009 16:34:25 -0700
Message-ID: <20090804233425.GA18261@count0.beaverton.ibm.com>
References: <20090804180303.GA8419@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090804180303.GA8419-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Tue, Aug 04, 2009 at 01:03:03PM -0500, Serge E. Hallyn wrote:
> [ will apply this patch to cr_tests unless Matt has comments ]
> 
> Freezing the robust futex waiters makes the syscall return with
> -EINTR.  The task then ends up caling futex_wait_restart.  If
> the futex value has already been changed by the parent, then
> the futex_wait_restart will return -EAGAIN.
> 
> If that happens, have the kid create a file called 'TBROK'
> and exit so the parent can reap it.  The run.sh shell is
> rewritten so it will rerun the test if the file TBROK has
> been created.
> 
> (note this has little to do with c/r, but rather with how
> the freezer affects the futex api)

Thanks for making and testing the fix.

Acked-by: Matt Helsley <matthltc-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

<snip>

Cheers,
	-Matt Helsley
