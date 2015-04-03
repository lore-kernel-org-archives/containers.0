From: Lukasz Pawelczyk <l.pawelczyk-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH review 09/19] mnt: Fail collect_mounts when applied to
	unmounted mounts
Date: Fri, 03 Apr 2015 10:55:53 +0200
Message-ID: <1428051353.1924.2.camel__25364.2968870283$1428051376$gmane$org@samsung.com>
References: <87a8yqou41.fsf_-_@x220.int.ebiederm.org>
	<1428026183-14879-9-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-reply-to: <1428026183-14879-9-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: Andrey Vagin <avagin-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Willy Tarreau <w@1wt.eu>
List-Id: containers.vger.kernel.org

On czw, 2015-04-02 at 20:56 -0500, Eric W. Biederman wrote:
> The only users of collect_mounts are in audit_tree.c
> 
> In audit_tree_trees and audit_add_tree rule the path passed into

I think you meant audit_trim_trees.

Also you missed a _ in audit_add_tree_rule.


> collect_mounts is generated from kern_path passed an audit_tree
> pathname which is guaranteed to be an absolute path.   In those cases
> collect_mounts is obviously intended to work on mounted paths and
> if a race results in paths that are unmounted when collect_mounts
> it is reasonable to fail early.
> 
> The paths passed into audit_tag_tree don't have the absolute path
> check.  But are used to play with fsnotify and otherwise interact with
> the audit_trees, so again operating only on mounted paths appears
> reasonable.
> 
> Avoid having to worry about what happens when we try and audit
> unmounted filesystems by restricting collect_mounts to mounts
> that appear in the mount tree.
> 
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  fs/namespace.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/namespace.c b/fs/namespace.c
> index 2b12b7a9455d..acc5583764dc 100644
> --- a/fs/namespace.c
> +++ b/fs/namespace.c
> @@ -1669,8 +1669,11 @@ struct vfsmount *collect_mounts(struct path *path)
>  {
>  	struct mount *tree;
>  	namespace_lock();
> -	tree = copy_tree(real_mount(path->mnt), path->dentry,
> -			 CL_COPY_ALL | CL_PRIVATE);
> +	if (!check_mnt(real_mount(path->mnt)))
> +		tree = ERR_PTR(-EINVAL);
> +	else
> +		tree = copy_tree(real_mount(path->mnt), path->dentry,
> +				 CL_COPY_ALL | CL_PRIVATE);
>  	namespace_unlock();
>  	if (IS_ERR(tree))
>  		return ERR_CAST(tree);

-- 
Lukasz Pawelczyk
Samsung R&D Institute Poland
Samsung Electronics
