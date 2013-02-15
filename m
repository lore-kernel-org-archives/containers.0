From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 52/85] sunrpc: Properly encode kuids and kgids in
	auth.unix.gid rpc pipe upcalls.
Date: Fri, 15 Feb 2013 10:47:28 -0800
Message-ID: <87ip5tv2gv.fsf@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-52-git-send-email-ebiederm@xmission.com>
	<20130213210545.GO14195@fieldses.org> <874nhfrjgg.fsf@xmission.com>
	<20130213215047.GR14195@fieldses.org> <8738wzq1z6.fsf@xmission.com>
	<20130213225840.GV14195@fieldses.org> <87ip5vn6iv.fsf@xmission.com>
	<20130215170052.GN8343@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130215170052.GN8343-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Fri, 15 Feb 2013 12:00:52 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc: Stanislav Kinsbursky <skinsbursky-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:

> On Wed, Feb 13, 2013 at 03:22:32PM -0800, Eric W. Biederman wrote:
>
> I've committed his patches to
>
> 	git://linux-nfs.org/~bfields/linux.git for-3.9
>
> which should also get pulled into next.  Let me know if there's another
> patch I should take.

I don't currently see any problems.

My changes are now in:

        git://git.kernel.org/pub/scm/linux/kernel/git/ebiederm/user-namespace.git for-next

So we will get whatever linux-next testing there is.

>> I am a touch concerned about /proc/fs/nfsd/exports after my patches
>> and Stanislavs patches both come in.  As I think that will allow for
>> cases where net->user_ns != &init_userns.  But we can cross that bridge
>> when we come to it.
>
> OK, let me know of anything I can do to make your life easier....

/proc/fs/nfsd/exports is read-only so it turns out not be be a problem.

That we can not mount nfs or the nfsd control filesystem outside of
init_userns prevents any other problems.  Details are in my conversation
with Stanislav.

Eric

p.s. It would be nice if /proc/fs/nfsd/exports became a symlink to
/proc/net/nfsd/exports so the code didn't have to use current to figure
out how to do the right thing.

p.p.s Full user namespace support probably isn't much more than using
net->user_ns and adding the FS_USERNS_MOUNT flag. 
