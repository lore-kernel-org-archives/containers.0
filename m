From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH 6/8] scm: Capture the full credentials of the scm sender.
Date: Tue, 15 Jun 2010 12:08:48 +0400
Message-ID: <4C173510.4030007@openvz.org>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1d3vvgirx.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1d3vvgirx.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, Daniel Lezcano <daniel.lezcano@free.fr>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

> +static __inline__ void scm_destroy_cred(struct scm_cookie *scm)
> +{
> +	put_pid(scm->pid);
> +	scm->pid  = NULL;
> +
> +	if (scm->cred)
> +		put_cred(scm->cred);
> +	scm->cred = NULL;
> +}
> +
>  static __inline__ void scm_destroy(struct scm_cookie *scm)
>  {
> +	scm_destroy_cred(scm);
>  	if (scm && scm->fp)
>  		__scm_destroy(scm);
>  }

I'm a bit worried by the "if (scm" check. It makes me think scm can
be NULL here and thus scm_destroy_cred can oops.
