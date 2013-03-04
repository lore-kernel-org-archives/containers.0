From: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH review 49/85] sunrpc: Update svcgss xdr handle to
	rpsec_contect cache
Date: Mon, 4 Mar 2013 09:12:30 -0500
Message-ID: <20130304141230.GE20389@fieldses.org>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-49-git-send-email-ebiederm@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1360777934-5663-49-git-send-email-ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
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

On Wed, Feb 13, 2013 at 09:51:38AM -0800, Eric W. Biederman wrote:
> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> 
> For each received uid call make_kuid and validate the result.
> For each received gid call make_kgid and validate the result.
> 
> Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
> Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ---
>  net/sunrpc/auth_gss/svcauth_gss.c |   18 +++++++++++++-----
>  1 files changed, 13 insertions(+), 5 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index 73e9573..ecd1d58 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -418,6 +418,7 @@ static int rsc_parse(struct cache_detail *cd,
>  {
>  	/* contexthandle expiry [ uid gid N <n gids> mechname ...mechdata... ] */
>  	char *buf = mesg;
> +	int id;
>  	int len, rv;
>  	struct rsc rsci, *rscp = NULL;
>  	time_t expiry;
> @@ -444,7 +445,7 @@ static int rsc_parse(struct cache_detail *cd,
>  		goto out;
>  
>  	/* uid, or NEGATIVE */
> -	rv = get_int(&mesg, &rsci.cred.cr_uid);
> +	rv = get_int(&mesg, &id);
>  	if (rv == -EINVAL)
>  		goto out;
>  	if (rv == -ENOENT)
> @@ -452,8 +453,16 @@ static int rsc_parse(struct cache_detail *cd,
>  	else {
>  		int N, i;
>  
> +		/* uid */
> +		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
> +		if (!uid_valid(rsci.cred.cr_uid))
> +			goto out;
> +
>  		/* gid */
> -		if (get_int(&mesg, &rsci.cred.cr_gid))
> +		if (get_int(&mesg, &id))
> +			goto out;
> +		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
> +		if (!gid_valid(rsci.cred.cr_gid))
>  			goto out;

krb5 mounts started failing for me as of this patch (upstream as
683428fae8c73d7d7da0fa2e0b6beb4d8df4e808), and I believe the problem is
these uid/gid_valid checks: if I recall correctly, gssd uses -1 uid/gid
values to indicate "authentication succeeded, but treat this user as
anonymous".  We delay mapping -1 id's to the (configurable-per-export)
anonymous id's till fs/nfsd/auth.c:nfsd_setuser():

        if (uid_eq(new->fsuid, INVALID_UID))
		new->fsuid = exp->ex_anon_uid;
	if (gid_eq(new->fsgid, INVALID_GID))
		new->fsgid = exp->ex_anon_gid;

(We wouldn't be able to do that earlier because we don't know the export
yet.)

Confirmed that the following fixes the regression.

Eric, any objection to removing those checks?

--b.

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index f7d34e7..59a089d 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -449,15 +449,11 @@ static int rsc_parse(struct cache_detail *cd,
 
 		/* uid */
 		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
-		if (!uid_valid(rsci.cred.cr_uid))
-			goto out;
 
 		/* gid */
 		if (get_int(&mesg, &id))
 			goto out;
 		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
-		if (!gid_valid(rsci.cred.cr_gid))
-			goto out;
 
 		/* number of additional gid's */
 		if (get_int(&mesg, &N))
