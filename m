From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 49/85] sunrpc: Update svcgss xdr handle to
	rpsec_contect cache
Date: Mon, 04 Mar 2013 09:11:16 -0800
Message-ID: <87txorjdjf.fsf__37975.1444132582$1362417127$gmane$org@xmission.com>
References: <87621w14vs.fsf@xmission.com>
	<1360777934-5663-1-git-send-email-ebiederm@xmission.com>
	<1360777934-5663-49-git-send-email-ebiederm@xmission.com>
	<20130304141230.GE20389@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130304141230.GE20389-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> (J. Bruce Fields's message
	of "Mon, 4 Mar 2013 09:12:30 -0500")
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
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org> writes:


> krb5 mounts started failing for me as of this patch (upstream as
> 683428fae8c73d7d7da0fa2e0b6beb4d8df4e808),

Ouch!

>  and I believe the problem is
> these uid/gid_valid checks: if I recall correctly, gssd uses -1 uid/gid
> values to indicate "authentication succeeded, but treat this user as
> anonymous".  We delay mapping -1 id's to the (configurable-per-export)
> anonymous id's till fs/nfsd/auth.c:nfsd_setuser():
>
>         if (uid_eq(new->fsuid, INVALID_UID))
> 		new->fsuid = exp->ex_anon_uid;
> 	if (gid_eq(new->fsgid, INVALID_GID))
> 		new->fsgid = exp->ex_anon_gid;
>
> (We wouldn't be able to do that earlier because we don't know the export
> yet.)
>
> Confirmed that the following fixes the regression.
>
> Eric, any objection to removing those checks?

Not strongly.  As long as we have the uid ang gid valid checks in
there somewhere before we start using these uids and gids much.
This does seems to be the case of using out of range uids and gids
to mean out of range uids and gids.

In the description of my original patch before I split it up, I
noted that one of the small dangers might be that I had added
some possibly unneceessary uid and gid valid checks.  So it seems I had
even considered this slight possibility once and noted that there was a
slight chance we might have to remove a few of these.

It would be nice to have a comment to say that we expect this to happen
so people don't start wondering why there are missing checks on this
path.

There is also a gid_valid check in the secondary uids.  It looks like we
should keep that as we don't have any checks for invalid gids in
nfsd_setuser.  Is that possibly an oversight in nfsd_setuser?

Also looking towards a future in which all of these things don't reside
in the initial user namespace.  Is mapping any out of range uid to
INVALID_UID and then into ex_anon_uid the always the right thing to do?

Or is -1 a very special case in this instance.  In which case we
probably want checks that look like:

        if (-1 == id) {
        	rsci.cred.cr_uid = INVALID_UID;
	} else {
	  	rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
        	if (!uid_valid(rsci.cred.cr_uid))
			goto out;
        }

Eric

> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
> index f7d34e7..59a089d 100644
> --- a/net/sunrpc/auth_gss/svcauth_gss.c
> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
> @@ -449,15 +449,11 @@ static int rsc_parse(struct cache_detail *cd,
>  
>  		/* uid */
>  		rsci.cred.cr_uid = make_kuid(&init_user_ns, id);
> -		if (!uid_valid(rsci.cred.cr_uid))
> -			goto out;
>  
>  		/* gid */
>  		if (get_int(&mesg, &id))
>  			goto out;
>  		rsci.cred.cr_gid = make_kgid(&init_user_ns, id);
> -		if (!gid_valid(rsci.cred.cr_gid))
> -			goto out;
>  
>  		/* number of additional gid's */
>  		if (get_int(&mesg, &N))
