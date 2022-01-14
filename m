Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC55D29CA
	for <containers@lists.linux.dev>; Fri, 14 Jan 2022 13:45:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BA136C36AEA;
	Fri, 14 Jan 2022 13:45:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1642167935;
	bh=6gqibBkBClRmRyQBZY5HwyitOU+GVwVvJirzhTxQSlc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=k9IglTIKG8eAefGuuATD9ZeuKdDDAErx/crdeut+QVtYOZZxDqdXiiiGuIWkXce0H
	 RL5hDILud+ZFPtKbIIoCpqVeFcIeuTV68T1B7eHUnaP+NQFFYNKxilwY9ir0N2rX30
	 1cJQVE5I32eTBT51LKNLZzydSAU4pLGCiSuEZ4gZ+EUrM9vw4bT5VY3mZqTP8jm1W4
	 ReMGQvw99QUW2paPrwatblpbJHWsWxJ+tQLBhREGBNRxNFx+ifSDI4E9VRyUE2Jo+r
	 2mVhfM3SOmXCY79Cx9keSQXRWRqtxdnYWbkc8VQ94FhD1jHUtqGKcxk9CFuOb026zK
	 vXEiPJL+hFmRg==
Date: Fri, 14 Jan 2022 14:45:27 +0100
From: Christian Brauner <brauner@kernel.org>
To: Stefan Berger <stefanb@linux.vnet.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	christian.brauner@ubuntu.com, containers@lists.linux.dev,
	dmitry.kasatkin@gmail.com, ebiederm@xmission.com,
	krzysztof.struczynski@huawei.com, roberto.sassu@huawei.com,
	mpeters@redhat.com, lhinds@redhat.com, lsturman@redhat.com,
	puiterwi@redhat.com, jejb@linux.ibm.com, jamjoom@us.ibm.com,
	linux-kernel@vger.kernel.org, paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	Stefan Berger <stefanb@linux.ibm.com>
Subject: Re: [PATCH v8 18/19] ima: Show owning user namespace's uid and gid
 when displaying policy
Message-ID: <20220114134527.bk5ijfrqwt334ypr@wittgenstein>
References: <20220104170416.1923685-1-stefanb@linux.vnet.ibm.com>
 <20220104170416.1923685-19-stefanb@linux.vnet.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20220104170416.1923685-19-stefanb@linux.vnet.ibm.com>

On Tue, Jan 04, 2022 at 12:04:15PM -0500, Stefan Berger wrote:
> From: Stefan Berger <stefanb@linux.ibm.com>
> 
> Show the uid and gid values of the owning user namespace when displaying
> the IMA policy rather than the kernel uid and gid values. Now the same uid
> and gid values are shown in the policy as those that were used when the
> policy was set.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---
>  security/integrity/ima/ima_policy.c | 19 +++++++++++++------
>  1 file changed, 13 insertions(+), 6 deletions(-)
> 
> diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
> index 15c68dc5da9e..b7dbc687b6ff 100644
> --- a/security/integrity/ima/ima_policy.c
> +++ b/security/integrity/ima/ima_policy.c
> @@ -1997,6 +1997,7 @@ static void ima_policy_show_appraise_algos(struct seq_file *m,
>  
>  int ima_policy_show(struct seq_file *m, void *v)
>  {
> +	struct user_namespace *user_ns = ima_user_ns_from_file(m->file);

Hm, so when looking at the policy entries via seq_file's .show method
and displaying the {g,u}id values of the rules we don't want the values
resolved according to the user namespace the securityfs instances was
mounted in. That would be misleading for callers that are in an
ancestor userns (which we allow in .permission).

So we want to make sure that we see the values as the opener of the file
would see them. This is similar to e.g. looking at a task's ids through
/proc/<pid>/status. So this should be seq_user_ns(m) instead of
ima_user_ns_from_file().

>  	struct ima_rule_entry *entry = v;
>  	int i;
>  	char tbuf[64] = {0,};
> @@ -2074,7 +2075,8 @@ int ima_policy_show(struct seq_file *m, void *v)
>  	}
>  
>  	if (entry->flags & IMA_UID) {
> -		snprintf(tbuf, sizeof(tbuf), "%d", __kuid_val(entry->uid));
> +		snprintf(tbuf, sizeof(tbuf),
> +			 "%d", from_kuid(user_ns, entry->uid));

This should be from_k{g,u}id_munged().
