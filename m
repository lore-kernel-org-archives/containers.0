From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH 1/2] fs: Extend mount_ns with support for a fast
	namespace to vfsmount function
Date: Sat, 24 Mar 2018 21:48:45 +0000
Message-ID: <20180324214845.GM30522__32131.6556459808$1521928016$gmane$org@ZenIV.linux.org.uk>
References: <20180323060457.sxgsd3j2obi33fyw@gordon>
	<87k1u3ti9e.fsf@xmission.com> <87fu4qo4ff.fsf_-_@xmission.com>
	<20180323231511.GK30522@ZenIV.linux.org.uk>
	<87in9ljvvx.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87in9ljvvx.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Sat, Mar 24, 2018 at 11:12:02AM -0500, Eric W. Biederman wrote:

> > This is completely wrong.  Look:
> > 	* SB_KERNMOUNT and !SB_KERNMOUNT cases are almost entirely isolated;
> > completely so once that ns_to_mnt becomes unconditionally non-NULL.  
> > 	* in !SB_KERNMOUNT passing ns_to_mnt() is pointless - you might as
> > well pass existing vfsmount (or ERR_PTR()) and use _that_.  fill_super()
> > is not used at all in that case.
> > 	* is SB_KERNMOUNT ns_to_mnt serves only as a flag, eventually
> > constant true.
> >
> > So let's split it in two helpers and give them sane arguments.
> 
> Everything I look at with multiple helpers feels even worse to me.
> The above has the advantage it is the minimal change to fix the
> regression.  So I am not worried about code correctness.

> I keep wondering is the intention long term to fix sget so it has an
> efficient data structure for finding super blocks (like an rbtree) or if
> the intention is to deprecate sget entirely and just have everything
> call alloc_super, and be responsible for their own data structures for
> finding existing superblocks.
>
> At this point since we are not in agreement on a proper fix I am going
> to plan on just queueing up a revert.   So that we don't ship 4.16 with
> a regression in a permission check.

Permission check is trivial to put back in; I'll do that.

FWIW, I don't believe that sget_userns() is a good place for any kind of
universal permission checks.  It's a library helper, not a place everything
must come through when mounting something.  So's mount_ns(), etc.

BTW, will you be at LSF?  I would suggest discussing the architectural
issues there - they are directly related to fsmount() proposals...
