From: Dave Hansen <dave@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] ipc namespaces: implement support for posix
	msqueues
Date: Wed, 17 Dec 2008 10:54:59 -0800
Message-ID: <1229540099.17206.426.camel@nimitz>
References: <20081217175513.GA23291@us.ibm.com>
	 <20081217175549.GB23331@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752313AbYLQSz1@vger.kernel.org>
In-Reply-To: <20081217175549.GB23331@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: lkml <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>
List-Id: containers.vger.kernel.org

On Wed, 2008-12-17 at 11:55 -0600, Serge E. Hallyn wrote:
> -void free_ipc_ns(struct kref *kref)
> +void put_ipc_ns(struct ipc_namespace *ns)
>  {
> -       struct ipc_namespace *ns;
> +       if (ns && atomic_dec_and_lock(&ns->count, &mq_lock)) {
> +               mq_clear_sbinfo(ns);
> +               spin_unlock(&mq_lock);
> +               mq_put_mnt(ns);
> +               free_ipc_ns(ns);
> +       }
> +}

OK, I see now why you wanted to remove the kref and add an atomic_t.
That's probably worth a sentence in the patch description.

I know that atomic_dec_and_lock() can be a nice logical thing to do, but
is it necessary here?  Basically, is there something that happens under
mq_lock that can re-raise the ns->count?

-- Dave
