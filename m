Received: from mail.hallyn.com (mail.hallyn.com [178.63.66.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 129BDA21
	for <containers@lists.linux.dev>; Tue, 24 May 2022 15:05:58 +0000 (UTC)
Received: by mail.hallyn.com (Postfix, from userid 1001)
	id 4813166D; Tue, 24 May 2022 10:05:51 -0500 (CDT)
Date: Tue, 24 May 2022 10:05:51 -0500
From: "Serge E. Hallyn" <serge@hallyn.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: "Serge E. Hallyn" <serge@hallyn.com>, linux-integrity@vger.kernel.org,
	zohar@linux.ibm.com, christian.brauner@ubuntu.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org,
	jpenumak@redhat.com, Christian Brauner <brauner@kernel.org>
Subject: Re: [PATCH v12 03/26] ima: Define ima_namespace struct and start
 moving variables into it
Message-ID: <20220524150551.GA14813@mail.hallyn.com>
References: <20220420140633.753772-1-stefanb@linux.ibm.com>
 <20220420140633.753772-4-stefanb@linux.ibm.com>
 <20220521023351.GA9107@mail.hallyn.com>
 <81730e47-21f4-b678-6585-f21e57620a60@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <81730e47-21f4-b678-6585-f21e57620a60@linux.ibm.com>
User-Agent: Mutt/1.9.4 (2018-02-28)

On Tue, May 24, 2022 at 10:57:13AM -0400, Stefan Berger wrote:
> 
> 
> On 5/20/22 22:33, Serge E. Hallyn wrote:
> 
> > > diff --git a/security/integrity/ima/ima_queue_keys.c b/security/integrity/ima/ima_queue_keys.c
> > > index 93056c03bf5a..e366a21dd8be 100644
> > > --- a/security/integrity/ima/ima_queue_keys.c
> > > +++ b/security/integrity/ima/ima_queue_keys.c
> > > @@ -10,6 +10,7 @@
> > >   #include <linux/user_namespace.h>
> > >   #include <linux/workqueue.h>
> > > +#include <linux/ima.h>
> > >   #include <keys/asymmetric-type.h>
> > >   #include "ima.h"
> > > @@ -42,7 +43,7 @@ static bool timer_expired;
> > >   static void ima_keys_handler(struct work_struct *work)
> > >   {
> > >   	timer_expired = true;
> > > -	ima_process_queued_keys();
> > > +	ima_process_queued_keys(&init_ima_ns);
> > >   }
> > >   /*
> > > @@ -130,11 +131,15 @@ bool ima_queue_key(struct key *keyring, const void *payload,
> > >    * This function sets ima_process_keys to true and processes queued keys.
> > >    * From here on keys will be processed right away (not queued).
> > >    */
> > > -void ima_process_queued_keys(void)
> > > +void ima_process_queued_keys(struct ima_namespace *ns)
> > >   {
> > >   	struct ima_key_entry *entry, *tmp;
> > >   	bool process = false;
> > > +	/* only applies to init_ima_ns */
> > 
> > Hm, yes, it seems to, but it should be unreachable with
> > ns != &init_ima_ns, ever, right?
> > 
> > So it seems better to either not have this hunk at all, (both
> > here and at ima_keys_handler()) or to actually have a BUG_ON.
> > 
> > Or am I completely misreading the situation?
> 
> No, you are right. This function is only calledwith ns = &init_ima_ns at the
> moment. How about changing it to this here?
> 
> if (WARN_ON(ns != &init_ima_ns))
>         return;

Sounds good, thanks.
