From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 52/85] sunrpc: Properly encode kuids and kgids in
	auth.unix.gid rpc pipe upcalls.
Date: Fri, 15 Feb 2013 12:00:52 -0500
Message-ID: <20130215170052.GN8343@fieldses.org>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-52-git-send-email-ebiederm@xmission.com>
	<20130213210545.GO14195@fieldses.org> <874nhfrjgg.fsf@xmission.com>
	<20130213215047.GR14195@fieldses.org> <8738wzq1z6.fsf@xmission.com>
	<20130213225840.GV14195@fieldses.org> <87ip5vn6iv.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <87ip5vn6iv.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 13, 2013 at 03:22:32PM -0800, Eric W. Biederman wrote:
> "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:
> 
> > On Wed, Feb 13, 2013 at 02:32:29PM -0800, Eric W. Biederman wrote:
> >> Now looking at the nfs server, seems to be hard coded to only start
> >> in the initial network namespace despite almost having support for
> >> starting in more.
> >
> > Right, Stanislav's got 4 more patches that should finish the job; see
> > http://mid.gmane.org/<20130201125210.3257.46454.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
> > and followups.  That should make it for 3.9, I just need to review
> > them....
> 
> Ok that is interesting.
> 
> There is an interesting corner case here where an unprivileged user
> can create a user namespace and then can create a network namespace.
> Depending on how we interpret things when Stanislaves patches reach
> there we might have to add:
> 
> if (net->user_ns != &init_user_ns)
> 	-EINVAL
> 
> Somewhere appropriate.

I'm assuming that's something that's needed only in kernels that have
*both* Stanislav's patches and yours.

I've committed his patches to

	git://linux-nfs.org/~bfields/linux.git for-3.9

which should also get pulled into next.  Let me know if there's another
patch I should take.

> I am a touch concerned about /proc/fs/nfsd/exports after my patches
> and Stanislavs patches both come in.  As I think that will allow for
> cases where net->user_ns != &init_userns.  But we can cross that bridge
> when we come to it.

OK, let me know of anything I can do to make your life easier....

--b.
