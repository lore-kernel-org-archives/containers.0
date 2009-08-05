From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: Re: [PATCH 5/5] c/r: Add AF_UNIX support (v7)
Date: Wed, 5 Aug 2009 08:29:48 -0500
Message-ID: <20090805132948.GA31272@us.ibm.com>
References: <1249331463-11887-1-git-send-email-danms@us.ibm.com> <1249331463-11887-6-git-send-email-danms@us.ibm.com> <20090804223141.GA14254@us.ibm.com> <8763d3dwmx.fsf@caffeine.danplanet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8763d3dwmx.fsf@caffeine.danplanet.com>
Sender: netdev-owner@vger.kernel.org
To: Dan Smith <danms@us.ibm.com>
Cc: containers@lists.osdl.org, Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org
List-Id: containers.vger.kernel.org

Quoting Dan Smith (danms@us.ibm.com):
> SH> why only free iov_base if ret!=0?
> 
> Because I was diagnosing a crash that only seemed to happen when I
> free()'d the buffer after it was used by sendmsg() and I forgot to
> remove this :(
> 
> >> +	a->sk_peercred.pid = task_tgid_vnr(current);
> >> +	a->sk_peercred.uid = ctx->realcred->uid;
> 
> SH> I don't know how much it matters, but of course root could be
> SH> restarting a set of tasks owned by several non-root uids, and the
> SH> peercred.uid's might need to be something other than
> ctx-> realcred->uid.  Or not?
> 
> Oh, so you're suggesting I use ctx->ecred instead?  I didn't actually
> notice the double declaration in the ckpt_ctx, but I guess that would
> be better.

No, I'm suggesting that the checkpointed application might have had
tasks owned by uids 0, 3, 55, and 1001, and a.peercred.uid might have
been 1001, right?  current, ctx->realcred->uid, and ctx->ecred might
all be different uids.  I think you just need to checkpoint the uid
(eventually an objref to a checkpointed user struct so we can also
catch the user namespace).

-serge
