Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A7E82CB6
	for <containers@lists.linux.dev>; Wed,  8 Dec 2021 12:10:03 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BAA2C341CA;
	Wed,  8 Dec 2021 12:09:57 +0000 (UTC)
Date: Wed, 8 Dec 2021 13:09:54 +0100
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Stefan Berger <stefanb@linux.ibm.com>
Cc: linux-integrity@vger.kernel.org, zohar@linux.ibm.com, serge@hallyn.com,
	containers@lists.linux.dev, dmitry.kasatkin@gmail.com,
	ebiederm@xmission.com, krzysztof.struczynski@huawei.com,
	roberto.sassu@huawei.com, mpeters@redhat.com, lhinds@redhat.com,
	lsturman@redhat.com, puiterwi@redhat.com, jejb@linux.ibm.com,
	jamjoom@us.ibm.com, linux-kernel@vger.kernel.org,
	paul@paul-moore.com, rgb@redhat.com,
	linux-security-module@vger.kernel.org, jmorris@namei.org
Subject: Re: [PATCH v4 10/16] ima: Implement hierarchical processing of file
 accesses
Message-ID: <20211208120954.nnawb6d2bpp54yll@wittgenstein>
References: <20211207202127.1508689-1-stefanb@linux.ibm.com>
 <20211207202127.1508689-11-stefanb@linux.ibm.com>
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20211207202127.1508689-11-stefanb@linux.ibm.com>

On Tue, Dec 07, 2021 at 03:21:21PM -0500, Stefan Berger wrote:
> Implement hierarchical processing of file accesses in IMA namespaces by
> walking the list of IMA namespaces towards the init_ima_ns. This way
> file accesses can be audited in an IMA namespace and also be evaluated
> against the IMA policies of parent IMA namespaces.
> 
> Signed-off-by: Stefan Berger <stefanb@linux.ibm.com>
> ---
>  security/integrity/ima/ima_main.c | 29 +++++++++++++++++++++++++----
>  1 file changed, 25 insertions(+), 4 deletions(-)
> 
> diff --git a/security/integrity/ima/ima_main.c b/security/integrity/ima/ima_main.c
> index 2121a831f38a..e9fa46eedd27 100644
> --- a/security/integrity/ima/ima_main.c
> +++ b/security/integrity/ima/ima_main.c
> @@ -200,10 +200,10 @@ void ima_file_free(struct file *file)
>  	ima_check_last_writer(iint, inode, file);
>  }
>  
> -static int process_measurement(struct ima_namespace *ns,
> -			       struct file *file, const struct cred *cred,
> -			       u32 secid, char *buf, loff_t size, int mask,
> -			       enum ima_hooks func)
> +static int _process_measurement(struct ima_namespace *ns,

Hm, it's much more common to use double underscores then single
underscores to

__process_measurement()

reads a lot more natural to people perusing kernel code quite often.

> +				struct file *file, const struct cred *cred,
> +				u32 secid, char *buf, loff_t size, int mask,
> +				enum ima_hooks func)
>  {
>  	struct inode *inode = file_inode(file);
>  	struct integrity_iint_cache *iint = NULL;
> @@ -405,6 +405,27 @@ static int process_measurement(struct ima_namespace *ns,
>  	return 0;
>  }
>  
> +static int process_measurement(struct ima_namespace *ns,
> +			       struct file *file, const struct cred *cred,
> +			       u32 secid, char *buf, loff_t size, int mask,
> +			       enum ima_hooks func)
> +{
> +	int ret = 0;
> +	struct user_namespace *user_ns;
> +
> +	do {
> +		ret = _process_measurement(ns, file, cred, secid, buf, size, mask, func);
> +		if (ret)
> +			break;
> +		user_ns = ns->user_ns->parent;
> +		if (!user_ns)
> +			break;
> +		ns = user_ns->ima_ns;
> +	} while (1);

I'd rather write this as:

	struct user_namespace *user_ns = ns->user_ns;

	while (user_ns) {
		ns = user_ns->ima_ns;

   		ret = __process_measurement(ns, file, cred, secid, buf, size, mask, func);
   		if (ret)
   			break;
		user_ns = user_ns->parent;
		
	}

because the hierarchy is only an implicit property inherited by ima
namespaces from the implementation of user namespaces. In other words,
we're only indirectly walking a hierarchy of ima namespaces because
we're walking a hierarchy of user namespaces. So the ima ns actually
just gives us the entrypoint into the userns hierarchy which the double
deref writing it with a while() makes obvious.

But that's just how I'd conceptualize it. This you should do however you
prefer.
