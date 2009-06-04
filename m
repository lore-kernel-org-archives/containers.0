From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Enhance checkpoint/restart Kconfig options
Date: Thu, 4 Jun 2009 15:41:14 -0500
Message-ID: <20090604204114.GA3513@us.ibm.com>
References: <20090604184504.F1BCB2F8@kernel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090604184504.F1BCB2F8@kernel>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dave Hansen (dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> I spent way too much time yesterday trying to figure out why
> my c/r tests weren't running.  It turned out that I didn't
> have any of the namespaces enabled, the sys_unshare() was
> failing, and the debugging didn't explain any of this.
> 
> So, to protect the world from repeating my mistakes, let's
> improve the Kconfig options a bit.
> 
> 1. Don't say "Enable" in the c/r menu, that's just silly
> 2. move the c/r menu next to the namespaces
> 3. make CHECKPOINT select all of the namespaces
> 4. put a Kconfig 'comment' in explaining how everything
>    got selected.
> 5. Put the namespaces in their own menu
> 
> Perhaps I should break this up a bit and we can push some
> of this to the beginning of the series.  Thoughts?

Yes the selects are needed imo.

-serge
