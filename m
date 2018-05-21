From: Steve Grubb <sgrubb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] audit: add containerid support for IMA-audit
Date: Mon, 21 May 2018 12:58:28 -0400
Message-ID: <2397631.78oLu0QVqb__10687.2625452981$1526921798$gmane$org@x2>
References: <1520257393.10396.291.camel@linux.vnet.ibm.com>
	<20180308112104.z67wohdvjqemy7wy@madcap2.tricolour.ca>
	<efb6c164-febe-67bb-43a9-795476c4902f@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <efb6c164-febe-67bb-43a9-795476c4902f-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Stefan Berger <stefanb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux-Audit Mailing List <linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-integrity <linux-integrity-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Mimi Zohar <zohar-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thursday, May 17, 2018 10:18:13 AM EDT Stefan Berger wrote:
> > audit_log_container_info() then releasing the local context.  This
> > version of the record has additional concerns covered here:
> > https://github.com/linux-audit/audit-kernel/issues/52
> 
> Following the discussion there and the concern with breaking user space,
> how can we split up the AUDIT_INTEGRITY_RULE that is used in
> ima_audit_measurement() and ima_parse_rule(), without 'breaking user
> space'?
> 
> A message produced by ima_parse_rule() looks like this here:
> 
> type=INTEGRITY_RULE msg=audit(1526566213.870:305): action="dont_measure"
> fsmagic="0x9fa0" res=1

Why is action and fsmagic being logged as untrusted strings? Untrusted 
strings are used when an unprivileged user can affect the contents of the 
field such as creating a file with space or special characters in the name.

Also, subject and object information is missing. Who loaded this rule?

> in contrast to that an INTEGRITY_PCR record type:
> 
> type=INTEGRITY_PCR msg=audit(1526566235.193:334): pid=1615 uid=0 auid=0
> ses=2 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
> op="invalid_pcr" cause="open_writers" comm="scp"
> name="/var/log/audit/audit.log" dev="dm-0" ino=1962625 res=1

Why is op & cause being logged as an untrusted string? This also has 
incomplete subject information.

> Should some of the fields from INTEGRITY_PCR also appear in
> INTEGRITY_RULE? If so, which ones? 

pid, uid, auid, tty, session, subj, comm, exe, res.  <- these are required to 
be searchable

> We could probably refactor the current  integrity_audit_message() and have
> ima_parse_rule() call into it to get those fields as well. I suppose adding
> new fields to it wouldn't be considered breaking user space?

The audit user space utilities pretty much expects those fields in that order 
for any IMA originating events. You can add things like op or cause before 
that. The reason why you can do that is those additional fields are not 
required to be searchable by common criteria.

-Steve
