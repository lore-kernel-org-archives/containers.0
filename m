From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 14/14][user-cr] Minimize unshare() calls
Date: Tue, 23 Mar 2010 23:08:47 -0500
Message-ID: <20100324040847.GA2474@us.ibm.com>
References: <20100319062659.GA23838@us.ibm.com>
	<20100319063448.GN24844@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100319063448.GN24844-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> 
> From: Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
> Date: Mon, 8 Mar 2010 12:03:46 -0800
> Subject: [PATCH 14/14][user-cr] Minimize unshare() calls
> 
> We currently have a few unshare() calls at different points in the
> code. While these don't affect the restart application itself, the
> excess calls create additional levels in the cgroup hierarchy, which
> can surprise the administrator (or other users of the hierarchy
> such as LXC.
> 
> Rather than several unshare() calls, can we instead specify the
> appropriate clone_flags while creating the coordinator/root process
> of the application tree ? When this root process is created it can
> remount /proc, remount devpts, chroot() etc if necessary.
> 
> Note that for "new-container with init" and "subtree restart", the
> first process is also the root of the application process tree.
> 
> In the case of "new-container without init", the coordinator process
> which acts as the container-init can do the setup.
> 
> In case of self-restart, the main process itself can do the unshare.
> 
> This patch has been very gently tested :-) but wanted to get more feedback
> on the direction and see if there is an easier way.

No objection from me on the direction or the code.

Acked-by: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
