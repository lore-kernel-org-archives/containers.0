Return-Path: <SRS0=Hw3E=DJ=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.1 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E133C46466
	for <containers@archiver.kernel.org>; Fri,  2 Oct 2020 19:25:55 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 86B0A2168B
	for <containers@archiver.kernel.org>; Fri,  2 Oct 2020 19:25:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="F0eXRuEW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86B0A2168B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by hemlock.osuosl.org (Postfix) with ESMTP id 34314873CA;
	Fri,  2 Oct 2020 19:25:54 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id oC-TT-R0qpPp; Fri,  2 Oct 2020 19:25:51 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by hemlock.osuosl.org (Postfix) with ESMTP id 7EADA87388;
	Fri,  2 Oct 2020 19:25:51 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 6FBB9C0889;
	Fri,  2 Oct 2020 19:25:51 +0000 (UTC)
Received: from hemlock.osuosl.org (smtp2.osuosl.org [140.211.166.133])
 by lists.linuxfoundation.org (Postfix) with ESMTP id B148EC0051
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 19:25:50 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by hemlock.osuosl.org (Postfix) with ESMTP id 9322E87396
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 19:25:50 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from hemlock.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id PBW+JXo+0W3Y
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 19:25:49 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from us-smtp-delivery-124.mimecast.com
 (us-smtp-delivery-124.mimecast.com [216.205.24.124])
 by hemlock.osuosl.org (Postfix) with ESMTPS id 5970587388
 for <containers@lists.linux-foundation.org>;
 Fri,  2 Oct 2020 19:25:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
 s=mimecast20190719; t=1601666748;
 h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
 in-reply-to:in-reply-to:references:references;
 bh=GKcXJAdZypWupEdq8nxdfbsZbI5HmERi4UOtlb/nGmA=;
 b=F0eXRuEW5VfIv0vppvMn4pfJc846CFRVksXcvsvS0w4ZzPNpwzrrFvOxQUxmf67DKnxn8g
 NJh1++Lkd52KppS5r7WEI3CAafgfgJpip5yZrfEUolBKChEjVDXzxJH+RsRWY0QRR7NQOb
 3t1sESndmaKDpgcq4SF3tNHzcpiHDsA=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-101-tSy1kGNKNv22Jv9U1jvLng-1; Fri, 02 Oct 2020 15:25:46 -0400
X-MC-Unique: tSy1kGNKNv22Jv9U1jvLng-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com
 [10.5.11.16])
 (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
 (No client certificate requested)
 by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 82A3A87308D;
 Fri,  2 Oct 2020 19:25:44 +0000 (UTC)
Received: from madcap2.tricolour.ca (unknown [10.10.110.18])
 by smtp.corp.redhat.com (Postfix) with ESMTPS id EF0725C1DA;
 Fri,  2 Oct 2020 19:25:28 +0000 (UTC)
Date: Fri, 2 Oct 2020 15:25:25 -0400
From: Richard Guy Briggs <rgb@redhat.com>
To: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH ghak90 V9 06/13] audit: add contid support for signalling
 the audit daemon
Message-ID: <20201002192525.GG2882171@madcap2.tricolour.ca>
References: <cover.1593198710.git.rgb@redhat.com>
 <f01f38dbb3190191e5914874322342700aecb9e1.1593198710.git.rgb@redhat.com>
 <CAHC9VhRPm4=_dVkZCu9iD5u5ixJOUnGNZ2wM9CL4kWwqv3GRnA@mail.gmail.com>
 <20200729190025.mueangq3os3r7ew6@madcap2.tricolour.ca>
 <CAHC9VhQoSH7Lza517WNr+6LaS7i890JPQfvisV6thLmnu01QOw@mail.gmail.com>
MIME-Version: 1.0
Content-Disposition: inline
In-Reply-To: <CAHC9VhQoSH7Lza517WNr+6LaS7i890JPQfvisV6thLmnu01QOw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Cc: nhorman@tuxdriver.com, linux-api@vger.kernel.org,
 containers@lists.linux-foundation.org, Dan Walsh <dwalsh@redhat.com>,
 LKML <linux-kernel@vger.kernel.org>, Ondrej Mosnacek <omosnace@redhat.com>,
 dhowells@redhat.com, Linux-Audit Mailing List <linux-audit@redhat.com>,
 netfilter-devel@vger.kernel.org, ebiederm@xmission.com, simo@redhat.com,
 netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 Eric Paris <eparis@parisplace.org>, sgrubb@redhat.com, mpatel@redhat.com
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On 2020-08-21 14:48, Paul Moore wrote:
> On Wed, Jul 29, 2020 at 3:00 PM Richard Guy Briggs <rgb@redhat.com> wrote:
> > On 2020-07-05 11:10, Paul Moore wrote:
> > > On Sat, Jun 27, 2020 at 9:22 AM Richard Guy Briggs <rgb@redhat.com> wrote:
> > > >
> > > > Add audit container identifier support to the action of signalling the
> > > > audit daemon.
> > > >
> > > > Since this would need to add an element to the audit_sig_info struct,
> > > > a new record type AUDIT_SIGNAL_INFO2 was created with a new
> > > > audit_sig_info2 struct.  Corresponding support is required in the
> > > > userspace code to reflect the new record request and reply type.
> > > > An older userspace won't break since it won't know to request this
> > > > record type.
> > > >
> > > > Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> > > > ---
> > > >  include/linux/audit.h       |  8 ++++
> > > >  include/uapi/linux/audit.h  |  1 +
> > > >  kernel/audit.c              | 95 ++++++++++++++++++++++++++++++++++++++++++++-
> > > >  security/selinux/nlmsgtab.c |  1 +
> > > >  4 files changed, 104 insertions(+), 1 deletion(-)
> > > >
> > > > diff --git a/include/linux/audit.h b/include/linux/audit.h
> > > > index 5eeba0efffc2..89cf7c66abe6 100644
> > > > --- a/include/linux/audit.h
> > > > +++ b/include/linux/audit.h
> > > > @@ -22,6 +22,13 @@ struct audit_sig_info {
> > > >         char            ctx[];
> > > >  };
> > > >
> > > > +struct audit_sig_info2 {
> > > > +       uid_t           uid;
> > > > +       pid_t           pid;
> > > > +       u32             cid_len;
> > > > +       char            data[];
> > > > +};
> > > > +
> > > >  struct audit_buffer;
> > > >  struct audit_context;
> > > >  struct inode;
> > > > @@ -105,6 +112,7 @@ struct audit_contobj {
> > > >         u64                     id;
> > > >         struct task_struct      *owner;
> > > >         refcount_t              refcount;
> > > > +       refcount_t              sigflag;
> > > >         struct rcu_head         rcu;
> > > >  };
> > >
> > > It seems like we need some protection in audit_set_contid() so that we
> > > don't allow reuse of an audit container ID when "refcount == 0 &&
> > > sigflag != 0", yes?
> >
> > We have it, see -ESHUTDOWN below.
> 
> That check in audit_set_contid() is checking ->refcount and not
> ->sigflag; ->sigflag is more important in this context, yes?

That contobj isn't findable until it is in the list with a positive
refcount.  If that contobj still exists and the refcount is zero, refuse
to increment it since it is dead.  The only reason it still exists is
the sigflag must be non-zero due to the signal not having been collected
yet or rcu hasn't released it yet after auditd exitted.

> > > > diff --git a/include/uapi/linux/audit.h b/include/uapi/linux/audit.h
> > > > index fd98460c983f..a56ad77069b9 100644
> > > > --- a/include/uapi/linux/audit.h
> > > > +++ b/include/uapi/linux/audit.h
> > > > @@ -72,6 +72,7 @@
> > > >  #define AUDIT_SET_FEATURE      1018    /* Turn an audit feature on or off */
> > > >  #define AUDIT_GET_FEATURE      1019    /* Get which features are enabled */
> > > >  #define AUDIT_CONTAINER_OP     1020    /* Define the container id and info */
> > > > +#define AUDIT_SIGNAL_INFO2     1021    /* Get info auditd signal sender */
> > > >
> > > >  #define AUDIT_FIRST_USER_MSG   1100    /* Userspace messages mostly uninteresting to kernel */
> > > >  #define AUDIT_USER_AVC         1107    /* We filter this differently */
> > > > diff --git a/kernel/audit.c b/kernel/audit.c
> > > > index a09f8f661234..54dd2cb69402 100644
> > > > --- a/kernel/audit.c
> > > > +++ b/kernel/audit.c
> > > > @@ -126,6 +126,8 @@ struct auditd_connection {
> > > >  kuid_t         audit_sig_uid = INVALID_UID;
> > > >  pid_t          audit_sig_pid = -1;
> > > >  u32            audit_sig_sid = 0;
> > > > +static struct audit_contobj *audit_sig_cid;
> > > > +static struct task_struct *audit_sig_atsk;
> > >
> > > This looks like a typo, or did you mean "atsk" for some reason?
> >
> > No, I meant atsk to refer specifically to the audit daemon task and not
> > any other random one that is doing the signalling.  I can change it is
> > there is a strong objection.
> 
> Esh, yeah, "atsk" looks too much like a typo ;)  At the very leask add
> a 'd' in there, e.g. "adtsk", but something better than that would be
> welcome.

Done.  I don't have a strong opinion.

> > > > @@ -2532,6 +2620,11 @@ int audit_set_contid(struct task_struct *task, u64 contid)
> > > >                         if (cont->id == contid) {
> > > >                                 /* task injection to existing container */
> > > >                                 if (current == cont->owner) {
> > > > +                                       if (!refcount_read(&cont->refcount)) {
> > > > +                                               rc = -ESHUTDOWN;
> > >
> > > Reuse -ENOTUNIQ; I'm not overly excited about providing a lot of
> > > detail here as these are global system objects.  If you must have a
> > > different errno (and I would prefer you didn't), use something like
> > > -EBUSY.
> >
> > I don't understand the issue of "global system objects" since the only
> > time this error would be issued is if its own contid were being reused
> > but it hadn't cleaned up its own references yet by either issuing an
> > AUDIT_SIGNAL_INFO* request or the targetted audit daemon hadn't cleaned
> > up yet.  EBUSY could be confused with already having spawned threads or
> > children, and ENOTUNIQ could indicate that another orchestrator/engine
> > had stolen its desired contid after we released it and wanted to reuse
> > it.
> 
> All the more reason for ENOTUNIQ.  The point is that the audit
> container ID is not available for use, and since the IDs are shared
> across the entire system I think we are better off having some
> ambiquity here with errnos.

Done.

> > This gets me thinking about making reservations for preferred
> > contids that are otherwise unavailable and making callbacks to indicate
> > when they become available, but that seems undesirably complex right
> > now.
> 
> That is definitely beyond the scope of this work, or rather *should*
> be beyond the scope of this work.

Good.

> paul moore

- RGB

--
Richard Guy Briggs <rgb@redhat.com>
Sr. S/W Engineer, Kernel Security, Base Operating Systems
Remote, Ottawa, Red Hat Canada
IRC: rgb, SunRaycer
Voice: +1.647.777.2635, Internal: (81) 32635

_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
