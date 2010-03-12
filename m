From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: user-cr: Extra unshare() calls ?
Date: Fri, 12 Mar 2010 08:44:11 -0600
Message-ID: <20100312144411.GA9783@us.ibm.com>
References: <20100308201338.GA16446@us.ibm.com>
	<20100308205851.GB21490@us.ibm.com>
	<20100308211135.GB14607@us.ibm.com>
	<20100312015823.GB6444@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100312015823.GB6444-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
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
> Sukadev Bhattiprolu [sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org] wrote:
> | Serge E. Hallyn [serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org] wrote:
> | | Quoting Sukadev Bhattiprolu (sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org):
> | | > 
> | | > Came across this while testing LXC.
> | | > 
> | | > 
> | | > 1. Does ckpt_remount_proc() need to unshare() ? Or can we have the
> | | >    clone() that calls __ckpt_coordinator() clone with CLONE_NEWNS|CLONE_FS
> | | >    instead ?
> | | > 
> | | >    The problem with the unshare() in ckpt_remount_proc() is that it
> | | >    creates an extra level in cgroup hierarchy (see below) after restart.
> | | >    So applications expecting the cgroup hierarchy before chckpoint will
> | | >    be surprised.
> | | > 
> | | > 2. When --mount-pty (or --mntns) is specified, do we need to unshare() 
> | | >    in the parent process ? Considering only the full-container restart
> | | >    for now (ignore self-restart and subtree restart), can we just
> | | >    specify (CLONE_NEWNS|CLONE_FS) at the time of creating the first
> | | >    restarted process ?
> | | 
> | | And then move remounting of devpts into ckpt_remount_proc() called
> | | from __ckpt_coordinator() as well?
> | 
> | Yes, I missed that in the hack.
> 
> Here is a more involved fix, but not sure if there is a more efficient
> way to solve.

I don't know what you mean by more efficient - this looks good to me.
(Apart from probably also pulling the self-restart stuff off into a helper)

-serge
