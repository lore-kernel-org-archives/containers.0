From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 2/3] c/r: Add UTS support (v6)
Date: Thu, 2 Apr 2009 12:48:38 -0500
Message-ID: <20090402174838.GA21178@us.ibm.com>
References: <1238533107-11796-1-git-send-email-danms@us.ibm.com>
	<1238533107-11796-3-git-send-email-danms@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1238533107-11796-3-git-send-email-danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> +static int cr_restore_utsns(struct cr_ctx *ctx, int ref)
> +{
> +	struct uts_namespace *uts;
> +	int ret;
> +
> +	uts = cr_obj_get_by_ref(ctx, ref, CR_OBJ_UTSNS);
> +	if (uts == NULL) {
> +		ret = cr_read_utsns(ctx, current);
> +		if (ret < 0)
> +			return ret;
> +
> +		return cr_obj_add_ref(ctx, current->nsproxy->uts_ns,
> +				      ref, CR_OBJ_UTSNS, 0);
> +	} else if (IS_ERR(uts)) {
> +		cr_debug("Failed to get UTS ns from objhash");
> +		return PTR_ERR(uts);
> +	}
> +
> +	ret = copy_namespaces(CLONE_NEWUTS, current);
> +	if (ret < 0)
> +		return ret;
> +
> +	put_uts_ns(current->nsproxy->uts_ns);
> +	get_uts_ns(uts);
> +	current->nsproxy->uts_ns = uts;

Oh, sorry, now I see.

It does seem all right, never mind...

-serge
