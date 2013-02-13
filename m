From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 52/85] sunrpc: Properly encode kuids and kgids in
	auth.unix.gid rpc pipe upcalls.
Date: Wed, 13 Feb 2013 16:05:45 -0500
Message-ID: <20130213210545.GO14195__42645.5447487116$1360789585$gmane$org@fieldses.org>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-52-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360777934-5663-52-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Wed, Feb 13, 2013 at 09:51:41AM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> When a new rpc connection is established with an in-kernel server, the
> traffic passes through svc_process_common, and svc_set_client and down
> into svcauth_unix_set_client if it is of type RPC_AUTH_NULL or
> RPC_AUTH_UNIX.
> 
> svcauth_unix_set_client then looks at the uid of the credential we
> have assigned to the incomming client and if we don't have the groups
> already cached makes an upcall to get a list of groups that the client
> can use.
> 
> The upcall encodes send a rpc message to user space encoding the uid
> of the user whose groups we want to know.  Encode the kuid of the user
> in the initial user namespace as nfs mounts can only happen today in
> the initial user namespace.

OK, I didn't know that.

(Though I'm unclear how it should matter to the server what user
namespace the client is in?)

> When a reply to an upcall comes in convert interpret the uid and gid values
> from the rpc pipe as uids and gids in the initial user namespace and convert
> them into kuids and kgids before processing them further.
> 
> When reading proc files listing the uid to gid list cache convert the
> kuids and kgids from into uids and gids the initial user namespace.  As we are
> displaying server internal details it makes sense to display these values
> from the servers perspective.

All of these caches are already per-network-namespace.  Ideally wouldn't
we also like to associate a user namespace with each cache somehow?

--b.

> 
> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  net/sunrpc/svcauth_unix.c |   14 +++++++++-----
>  1 files changed, 9 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
> index faf1719..bdea0a1 100644
> --- a/net/sunrpc/svcauth_unix.c
> +++ b/net/sunrpc/svcauth_unix.c
> @@ -470,7 +470,7 @@ static void unix_gid_request(struct cache_detail *cd,
>  	char tuid[20];
>  	struct unix_gid *ug = container_of(h, struct unix_gid, h);
>  
> -	snprintf(tuid, 20, "%u", ug->uid);
> +	snprintf(tuid, 20, "%u", from_kuid(&init_user_ns, ug->uid));
>  	qword_add(bpp, blen, tuid);
>  	(*bpp)[-1] = '\n';
>  }
> @@ -486,7 +486,8 @@ static int unix_gid_parse(struct cache_detail *cd,
>  			char *mesg, int mlen)
>  {
>  	/* uid expiry Ngid gid0 gid1 ... gidN-1 */
> -	int uid;
> +	int id;
> +	kuid_t uid;
>  	int gids;
>  	int rv;
>  	int i;
> @@ -498,9 +499,12 @@ static int unix_gid_parse(struct cache_detail *cd,
>  		return -EINVAL;
>  	mesg[mlen-1] = 0;
>  
> -	rv = get_int(&mesg, &uid);
> +	rv = get_int(&mesg, &id);
>  	if (rv)
>  		return -EINVAL;
> +	uid = make_kuid(&init_user_ns, id);
> +	if (!uid_valid(uid))
> +		return -EINVAL;
>  	ug.uid = uid;
>  
>  	expiry = get_expiry(&mesg);
> @@ -554,7 +558,7 @@ static int unix_gid_show(struct seq_file *m,
>  			 struct cache_detail *cd,
>  			 struct cache_head *h)
>  {
> -	struct user_namespace *user_ns = current_user_ns();
> +	struct user_namespace *user_ns = &init_user_ns;
>  	struct unix_gid *ug;
>  	int i;
>  	int glen;
> @@ -570,7 +574,7 @@ static int unix_gid_show(struct seq_file *m,
>  	else
>  		glen = 0;
>  
> -	seq_printf(m, "%u %d:", ug->uid, glen);
> +	seq_printf(m, "%u %d:", from_kuid_munged(user_ns, ug->uid), glen);
>  	for (i = 0; i < glen; i++)
>  		seq_printf(m, " %d", from_kgid_munged(user_ns, GROUP_AT(ug->gi, i)));
>  	seq_printf(m, "\n");
> -- 
> 1.7.5.4
> 
