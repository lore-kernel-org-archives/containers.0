From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review  4/4] vfs: Do not allow escaping from bind mounts.
Date: Thu, 09 Apr 2015 21:51:11 -0500
Message-ID: <874moo1ysg.fsf__32987.725819885$1428634543$gmane$org@x220.int.ebiederm.org>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<87iod68aa3.fsf_-_@x220.int.ebiederm.org>
	<20150409232212.GX889@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20150409232212.GX889-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> (Al Viro's message of
	"Fri, 10 Apr 2015 00:22:13 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org> writes:

> On Wed, Apr 08, 2015 at 06:34:12PM -0500, Eric W. Biederman wrote:
>> +	if (ancestor) {
>> +		mark_violated_mounts(dentry, ancestor);
>> +		mark_violated_mounts(target, ancestor);
>> +	}
>
> Umm...  Both sides the same way, regardless of whether it's exchange or
> move?  Looks wrong...

I am pretty certain it can cause d_path to become an information leak
if we do not.

> Look:
>
> mkdir /tmp/a
> mkdir /tmp/b
> mkdir /tmp/c
> mkdir /tmp/b/c
> touch /tmp/a/x
> mount --bind /tmp/b /tmp/c
> mv /tmp/a/x /tmp/b/c/x
>
> should that make the vfsmount on /tmp/c violated?  And if so, why?

If /tmp is a mount point and before the move there was a:
touch /tmp/b/c/x

And a process opened /tmp/c/c/x.
d_path on that file descriptor before __d_move would say:

/tmp/c/c/x

after the __d_move d_path would say:

/tmp/c/a/x

Which is bizareely weird in this example, and could potentially be
an expolitable information leak in the hands of someone who knew
what they were doing.

I am not clever enough to take that deleted directory and walk up the
tree, so the damage may be limited to seeing the true path on the
fileystem.  But it just may be that I am dense today.

Furthermore all of the relevant changes to the dentry that happen 
when exchange is true also happen when exchange is false, so I am very
reluctant to believe that the non-exchange case is not exploitable by a
sufficiently clever individual.

Eric
