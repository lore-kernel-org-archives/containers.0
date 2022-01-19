Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F911173
	for <containers@lists.linux.dev>; Wed, 19 Jan 2022 09:23:56 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 410A2C004E1;
	Wed, 19 Jan 2022 09:23:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1642584236;
	bh=s5TLsbS1jbZfdwAl4SksLumG75G5qVlu5kgHf5Uedck=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=rHWHfaOzn+BCiUBPiUCLLa1AZe0Yj3kaE79fH4EQlShCDkqnjHCTnL9zXpw/ZVSn2
	 ezywBceniUMlhXh/j946h6xmpGDOFJ2AWeJ3pdNX9mHh7F+dqwFfZA4dVV4sH4NFr9
	 A2K/KieEVKb82fL2U8scKt5OndVrYKUqj7eSWbVFP+SuKZtmMykG1qgPi294363rxZ
	 0acgaSGLDKPXKuAobfs/OGBm95j2m99bCdu1RGNdem/mksMZTcRo5rD8EaypXFuOlF
	 bePsI+sQhHioFkQ8Aa8ne176WWInpkaFWRLK3fD+YEd6+4VqssnhZpby/RzTiObhw4
	 I8pENM+YTur9w==
Date: Wed, 19 Jan 2022 10:23:48 +0100
From: Christian Brauner <brauner@kernel.org>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: Stefan Berger <stefanb@linux.vnet.ibm.com>,
	linux-integrity@vger.kernel.org, zohar@linux.ibm.com,
	serge@hallyn.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org
Subject: Re: [PATCH v8 18/19] ima: Show owning user namespace's uid and gid
 when displaying policy
Message-ID: <20220119092348.soelk5xqaqbsb73m@wittgenstein>
References: <20220104170416.1923685-1-stefanb@linux.vnet.ibm.com>
 <20220104170416.1923685-19-stefanb@linux.vnet.ibm.com>
 <20220114134527.bk5ijfrqwt334ypr@wittgenstein>
 <971dc802-42b2-9f04-f143-89f9ae26f0fe@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <971dc802-42b2-9f04-f143-89f9ae26f0fe@linux.ibm.com>

On Tue, Jan 18, 2022 at 11:31:29AM -0500, Stefan Berger wrote:
> 
> On 1/14/22 08:45, Christian Brauner wrote:
> > On Tue, Jan 04, 2022 at 12:04:15PM -0500, Stefan Berger wrote:
> > > From: Stefan Berger <stefanb@linux.ibm.com>
> > > 
> > > Show the uid and gid values of the owning user namespace when displaying
> > > the IMA policy rather than the kernel uid and gid values. Now the same uid
> > > and gid values are shown in the policy as those that were used when the
> > > policy was set.
> > > 
> > > Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> > > ---
> > >   security/integrity/ima/ima_policy.c | 19 +++++++++++++------
> > >   1 file changed, 13 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/security/integrity/ima/ima_policy.c b/security/integrity/ima/ima_policy.c
> > > index 15c68dc5da9e..b7dbc687b6ff 100644
> > > --- a/security/integrity/ima/ima_policy.c
> > > +++ b/security/integrity/ima/ima_policy.c
> > > @@ -1997,6 +1997,7 @@ static void ima_policy_show_appraise_algos(struct seq_file *m,
> > >   int ima_policy_show(struct seq_file *m, void *v)
> > >   {
> > > +	struct user_namespace *user_ns = ima_user_ns_from_file(m->file);
> > Hm, so when looking at the policy entries via seq_file's .show method
> > and displaying the {g,u}id values of the rules we don't want the values
> > resolved according to the user namespace the securityfs instances was
> > mounted in. That would be misleading for callers that are in an
> > ancestor userns (which we allow in .permission).
> > 
> > So we want to make sure that we see the values as the opener of the file
> > would see them. This is similar to e.g. looking at a task's ids through
> > /proc/<pid>/status. So this should be seq_user_ns(m) instead of
> > ima_user_ns_from_file().
> > >   	struct ima_rule_entry *entry = v;
> > >   	int i;
> > >   	char tbuf[64] = {0,};
> > > @@ -2074,7 +2075,8 @@ int ima_policy_show(struct seq_file *m, void *v)
> > >   	}
> > >   	if (entry->flags & IMA_UID) {
> > > -		snprintf(tbuf, sizeof(tbuf), "%d", __kuid_val(entry->uid));
> > > +		snprintf(tbuf, sizeof(tbuf),
> > > +			 "%d", from_kuid(user_ns, entry->uid));
> > This should be from_k{g,u}id_munged().
> 
> Thanks, fixed.
> 
> When I run a runc container as uid=1000 I see uid = 0 when inside the
> container and when entering its mount namespace from root account via
> nsenter it shows 'uid = 1000' while before it was showing 'uid = 0'.

Yes, when you're only entering the mountns you should see uid 1000 as
that's what that {g,u}id is mapped to in your namespace and you've
opened __and read__ that file from the same namespace.

(Now, if you were to open that fd and send it back to a process running
in the container and that process does the read it would still see 1000.
But that's ok, because we care about the opener's creds.)
