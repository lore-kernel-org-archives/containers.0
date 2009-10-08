From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 1/1] cr: lsm: actually cache entries
Date: Thu, 8 Oct 2009 16:41:11 -0500
Message-ID: <20091008214111.GA7588@us.ibm.com>
References: <20091008194720.GA648@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20091008194720.GA648-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> Somewhere along the way, the lsm c/r patchset seems to have
> dropped the code caching whether a particular void*security
> had already been checkpointed.  Note that checkpoint a
> void* security means allocing a struct containing the secref
> and the string representation of the context.  That leaves us
> with no way to tell, given only the void*security, whether
> that context has been checkpointed before (as part of checkpointing
> a different object of the same object type and security context).
> 
> This patch re-introduces a moronic unsorted per-checkpoint list
> of checkpointed contexts, used only at checkpoint time, so that
> we can re-use secrefs.  Converting this to an rblist or hash will
> be trivial, but isn't done here to try and make clear why we
> actually need this.
> 
> (applies on top of existing LSM c/r patches at
> git://git.kernel.org/pub/scm/linux/kernel/git/sergeh/linux-cr.git)
> 
> Signed-off-by: Serge E. Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

Matt called me on this over irc, and as a result I think I've
found a trivial way to do this much better...  pls ignore for
now.

thanks,
-serge
