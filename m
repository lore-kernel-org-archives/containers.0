From: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH] Containers: Avoid lockdep warning
Date: Thu, 23 Aug 2007 12:00:03 +0530
Message-ID: <20070823063003.GM4020@linux.vnet.ibm.com>
References: <20070822231710.E90B53D66A9@localhost>
Reply-To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20070822231710.E90B53D66A9@localhost>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Aug 22, 2007 at 04:17:10PM -0700, Paul Menage wrote:
> 
> I think this is the right way to handle the lockdep false-positive in
> the current containers patches, but I'm not that familiar with lockdep
> so any suggestions for a better approach are welcomed.
> 
> 
> In order to avoid a false-positive lockdep warning, we lock the root
> inode of a new filesystem mount prior to taking container_mutex, to
> preserve the invariant that container_mutex nests inside
> inode->i_mutex. In order to prevent a lockdep false positive when
> locking i_mutex on a newly-created container directory inode we use
> mutex_lock_nested(), with a nesting level of I_MUTEX_CHILD since the
> new inode will ultimately be a child directory of the parent whose
> i_mutex is nested outside of container_mutex.

Hi Paul,

Just tried it out, and it works for me.

-- 
regards,
Dhaval

I would like to change the world but they don't give me the source code!
