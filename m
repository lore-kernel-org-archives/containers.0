From: Jan Engelhardt <jengelh-9+2X+4sQBs8@public.gmane.org>
Subject: Re: [RFC][PATCH] net: Allow xt_owner in any user namespace
Date: Mon, 26 May 2014 10:28:24 +0200 (CEST)
Message-ID: <alpine.LSU.2.11.1405261025560.26860__36581.869578413$1401092919$gmane$org@nerf08.vanv.qr>
References: <537B7FF6.9050103@elastichosts.com>
	<877g5eg7wy.fsf@x220.int.ebiederm.org> <537D706D.4010303@1h.com>
	<87vbsus3wb.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87vbsus3wb.fsf_-_-JOvCrm2gF+uungPnsOpG7nhyD016LWXt@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter user mailing list <netfilter-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Alin Dobre <alin.dobre-1hSFou9RDDldEee+Cai+ZQ@public.gmane.org>, Jan Engelhardt <jengelh-nopoi9nDyk+ELgA04lAiVw@public.gmane.org>
List-Id: containers.vger.kernel.org


On Sunday 2014-05-25 09:39, Eric W. Biederman wrote:
>
>Making this work is a little tricky as it really isn't kosher to
>change the xt_owner_match_info in a check function.

It is ok if you set aside members for kernel internal use, though
that is going to require a new match revision. That may be justified
since it would alleviate repeated calls to make_kuid for each packet.

>@@ -48,9 +75,10 @@ owner_mt(const struct sk_buff *skb, struct xt_action_param *par)
> 		return ((info->match ^ info->invert) &
> 		       (XT_OWNER_UID | XT_OWNER_GID)) == 0;
> 
>+	net = sock_net(skb->sk);
> 	if (info->match & XT_OWNER_UID) {
>-		kuid_t uid_min = make_kuid(&init_user_ns, info->uid_min);
>-		kuid_t uid_max = make_kuid(&init_user_ns, info->uid_max);
>+		kuid_t uid_min = make_kuid(net->user_ns, info->uid_min);
>+		kuid_t uid_max = make_kuid(net->user_ns, info->uid_max);
> 		if ((uid_gte(filp->f_cred->fsuid, uid_min) &&
> 		     uid_lte(filp->f_cred->fsuid, uid_max)) ^
> 		    !(info->invert & XT_OWNER_UID))
