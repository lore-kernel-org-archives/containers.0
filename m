From: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Subject: Re: [PATCH review  4/4] vfs: Do not allow escaping from bind mounts.
Date: Fri, 10 Apr 2015 04:14:57 +0100
Message-ID: <20150410031457.GD889__43155.5406343707$1428635716$gmane$org@ZenIV.linux.org.uk>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<87iod68aa3.fsf_-_@x220.int.ebiederm.org>
	<20150409232212.GX889@ZenIV.linux.org.uk>
	<874moo1ysg.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <874moo1ysg.fsf-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Thu, Apr 09, 2015 at 09:51:11PM -0500, Eric W. Biederman wrote:
> And a process opened /tmp/c/c/x.
> d_path on that file descriptor before __d_move would say:
> 
> /tmp/c/c/x
> 
> after the __d_move d_path would say:
> 
> /tmp/c/a/x

So what?

> Which is bizareely weird in this example, and could potentially be
> an expolitable information leak in the hands of someone who knew
> what they were doing.
> 
> I am not clever enough to take that deleted directory and walk up the
> tree, so the damage may be limited to seeing the true path on the
> fileystem.  But it just may be that I am dense today.
> 
> Furthermore all of the relevant changes to the dentry that happen 
> when exchange is true also happen when exchange is false, so I am very
> reluctant to believe that the non-exchange case is not exploitable by a
> sufficiently clever individual.

	Exploited how?  The same assistant might very well have done
echo "/tmp/c/a/x or whatever else I might want to pass to you" >/tmp/c/c/x
and pass whatever information they wanted _that_ way.

	As it is, you've created one hell of a DoS - *anyone* can poison
any vfsmount covering a subtree if they have access to a containing subtree
somewhere and write permissions on a directory inside and directory outside
of the victim one.
