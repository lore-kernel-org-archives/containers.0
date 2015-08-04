From: Andrew Vagin <avagin-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH review 6/6] vfs: Cache the results of path_connected
Date: Tue, 4 Aug 2015 14:52:17 +0300
Message-ID: <20150804115215.GA317__3413.3167159327$1438689157$gmane$org@odin.com>
References: <871tncuaf6.fsf@x220.int.ebiederm.org>
	<87mw5xq7lt.fsf@x220.int.ebiederm.org>
	<87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<874moq9oyb.fsf_-_@x220.int.ebiederm.org>
	<871tfkawu9.fsf_-_@x220.int.ebiederm.org>
	<8738009i0h.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <8738009i0h.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Miklos Szeredi <miklos-sUDqSbJrdHQHWmgEVkV9KA@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On Mon, Aug 03, 2015 at 04:30:54PM -0500, Eric W. Biederman wrote:
> 
> Add a new field mnt_escape_count in nameidata, initialize it to 0 and
> cache the value of read_mnt_escape_count in nd->mnt_escape_count.
> 
> This allows a single check in path_connected in the common case where
> either the mount has had no escapes (mnt_escape_count == 0) or there
> has been an escape and it has been validated that the current path
> does not escape.
> 
> To keep the cache valid nd->mnt_escape_count must be set to 0 whenever
> the nd->path.mnt changes or when nd->path.dentry changes such that
> the connectedness of the previous value of nd->path.dentry does
> not imply the connected of the new value of nd->path.dentry.
> 
> Various locations in fs/namei.c are updated to set
> nd->mnt_escape_count to 0 as necessary.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namei.c | 26 +++++++++++++++++++++++---
>  1 file changed, 23 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index bccd3810ff60..79a5dca073f5 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -514,6 +514,7 @@ struct nameidata {
>  	struct nameidata *saved;
>  	unsigned	root_seq;
>  	int		dfd;
> +	unsigned	mnt_escape_count;
>  };
>  
>  static void set_nameidata(struct nameidata *p, int dfd, struct filename *name)
> @@ -572,12 +573,13 @@ static bool path_connected(struct nameidata *nd)
>  	struct vfsmount *mnt = nd->path.mnt;
>  	unsigned escape_count = read_mnt_escape_count(mnt);
>  
> -	if (likely(escape_count == 0))
> +	if (likely(escape_count == nd->mnt_escape_count))
>  		return true;

The size of mnt_escape_count is only 4 bytes. Looks like it possible to
make UINT_MAX / 2 operations for the resonable time and get the same
value of mnt_escape_count, path_connected() will return true, but the
path may be already detached. What do you think about this?

Thanks,
Andrew
