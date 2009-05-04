From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [RFC][PATCH 6/7] Define do_fork_with_pids()
Date: Mon, 4 May 2009 11:32:45 -0700
Message-ID: <20090504183245.GC31892@linux.vnet.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
	<12414250652549-git-send-email-sukadev@linux.vnet.ibm.com>
	<20090504182621.GO11734@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090504182621.GO11734-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

| > +long do_fork(unsigned long clone_flags,
| > +	      unsigned long stack_start,
| > +	      struct pt_regs *regs,
| > +	      unsigned long stack_size,
| > +	      int __user *parent_tidptr,
| > +	      int __user *child_tidptr)
| > +{
| > +	return do_fork_with_pids(clone_flags, stack_start, regs, stack_size,
| > +			parent_tidptr, child_tidptr, NULL);
| > +}
| > +
| 
| Would it be better to add the pid parameters to do_fork() and adjust its callers
| instead?

A quick count showed 70 callers of do_fork() :-) hence the short-cut - at
least for the current version of the patchset.
