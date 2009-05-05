From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH 3/7] Add target_pid parameter to alloc_pidmap()
Date: Tue, 5 May 2009 18:01:44 -0500
Message-ID: <20090505230144.GA10121@us.ibm.com>
References: <12414250653025-git-send-email-sukadev@linux.vnet.ibm.com>
	<12414250651744-git-send-email-sukadev@linux.vnet.ibm.com>
	<20090504200318.GA29491@us.ibm.com>
	<20090505222342.GB20515@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20090505222342.GB20515-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | I think this whole patchset is still NACKed until you tag
> | pid_namespaces with a creator uid, and ensure that
> | current_uid()==pid_ns->creator_uid() at each level where
> | the caller is specifying a pid.
> 
> I currently have CAP_SYS_ADMIN check in clone_with_pids() and was
> thinking that the tagging of pid namespaces can be done indpendent
> of this patchset (as would integrating your patch of making pid_max
> a property of pid-namespace).

Didn't notice that check in patch 7.  Yeah, that's fine.

> | 
> | I don't see that in this set.
> | 
> | OTOH, your approach of pulling alloc_pidmap_page() out of
> | alloc_pidmap() and re-using it may be what Eric wanted to
> | see.
> 
> Yes, I think the first few helper patches in the set would be needed/
> useful to restart a process with a pid (not just for the clone-with-pids
> syscall).

thanks,
-serge
